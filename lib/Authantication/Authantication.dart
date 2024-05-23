import 'dart:io';

import 'package:beat_buddy/Authantication/EmailAuth/Login.dart';
import 'package:beat_buddy/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;

class Auth {
  Auth();
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference Users = FirebaseFirestore.instance.collection("Users");

  Future<File> compressImage(File originalImage) async {
    // Read the original image
    List<int> imageBytes = await originalImage.readAsBytes();
    Uint8List uint8List = Uint8List.fromList(imageBytes);

    // Decode the image
    img.Image image = img.decodeImage(uint8List) as img.Image;

    // Compress the image
    img.Image compressedImage =
        img.copyResize(image, width: 800); // You can adjust the width as needed

    // Save the compressed image to a new file
    File compressedImageFile = File(originalImage.path)
      ..writeAsBytesSync(img.encodeJpg(compressedImage,
          quality: 85)); // You can adjust the quality as needed

    return compressedImageFile;
  }

  void emailSignIn(String email, String pass, BuildContext context) async {
    if (email == '' || pass == '') {
      Fluttertoast.showToast(msg: "Please Enter All Details");
    } else {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: pass);
        if (userCredential.user != null) {
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(context,
              CupertinoPageRoute(builder: (context) => const HomeScreen()));
        }
      } on FirebaseAuthException catch (ex) {
        showSnackBar(context, ex.code);
      }
    }
  }

  void emailSignup(
      String uname,
      String email,
      String phone,
      String pass1,
      String pass2,
      File? profilePic,
      BuildContext context,
      Function changeStatus) async {
    String profileUrl = "";
    if (email == '' ||
        pass1 == '' ||
        pass2 == '' ||
        uname == '' ||
        phone == '') {
      showSnackBar(context, "All Details are required");
    } else if (pass1 != pass2) {
      showSnackBar(context, "Passwords dosent match");
    } else {
      try {
        changeStatus(true);
        if (await userExists(phone)) {
          showSnackBar(context, "Phone Number Exists");
          changeStatus(false);
        } else {
          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: pass1);
          if (userCredential.user != null) {
            if (profilePic != null) {
              File compressed = await compressImage(profilePic);
              UploadTask uploadTask1 = FirebaseStorage.instance
                  .ref()
                  .child("Profile Pic")
                  .child(const Uuid().v1())
                  .putFile(compressed);
              TaskSnapshot taskSnapshot1 = await uploadTask1;
              profileUrl = await taskSnapshot1.ref.getDownloadURL();
            }
            Users.doc(userCredential.user!.uid).set({
              "Phone": phone,
              "profilePicUrl": profileUrl,
              "Name": uname,
              "Email": email
            });
            changeStatus(false);
            showSnackBar(context, "User Created SuccessFully");
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const EmailLogin()),
                (rout) => false);
          }
        }
      } on FirebaseAuthException catch (ex) {
        changeStatus(false);
        showSnackBar(context, ex.code);
      }
    }
  }

  Future<bool> userExists(String phoneNumber) async {
    QuerySnapshot snapshot =
        await Users.where("Phone", isEqualTo: phoneNumber).get();
    if (snapshot.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> verifyPhoneNumber(String phoneNumber, BuildContext context,
      Function setData, Function loader) async {
    verificationCompleted(phoneAuthCredential) {
      showSnackBar(context, "Verification Compleated");
    }

    verificationFailed(error) {
      showSnackBar(context, "Verification Faild with error : ${error.code}");
      print("******************************************** ${error.toString()}");
      loader(false);
    }

    codeSent(verificationId, forceResendingToken) {
      showSnackBar(context, "Code Sent");
      setData(verificationId);
    }

    codeAutoRetrievalTimeout(verificationId) {
      showSnackBar(context, "Code Auto Retrival Timeout");
    }

    try {
      auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint(e.message);
      debugPrint(stackTrace.toString());
      showSnackBar(context, e.message.toString());
      loader(false);
    }
  }

  void signInWithPhoneNo(String verificationId, String smsCode,
      BuildContext context, String phoneNumber) async {
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);
      UserCredential user = await auth.signInWithCredential(credential);
      await userExists(phoneNumber)
          ? null
          : Users.doc(user.user!.uid).set({
              "Phone": phoneNumber,
              "profilePicUrl": "",
              "Name": "",
              "Email": ""
            });
      showSnackBar(context, "User Logedin SuccessFully");
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false);
    } on FirebaseAuthException catch (e, stackTrace) {
      showSnackBar(context, e.code);
      debugPrint(stackTrace.toString());
    }
  }

  void showSnackBar(BuildContext context, String text) {
    final snackbar = SnackBar(
      content: Text(text),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
