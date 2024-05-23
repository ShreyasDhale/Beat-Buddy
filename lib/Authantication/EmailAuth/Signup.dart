import 'dart:io';

import 'package:beat_buddy/Authantication/Authantication.dart';
import 'package:beat_buddy/Authantication/EmailAuth/Login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class EmailSignUp extends StatefulWidget {
  const EmailSignUp({super.key});

  @override
  State<EmailSignUp> createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State<EmailSignUp> {
  Auth auth = Auth();

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController pass1Controller = TextEditingController();
  TextEditingController pass2Controller = TextEditingController();
  File? profilePic;
  bool obscureText1 = true;
  bool obscureText2 = true;
  bool creating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade900,
        titleTextStyle: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 80.0),
          child: Row(
            children: [
              Icon(Icons.person_3_rounded),
              Text("Signup"),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Colors.deepPurple.shade200,
              Colors.deepPurple.shade800
            ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
          ),
          SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      InkWell(
                        onTap: pickImage,
                        child: CircleAvatar(
                          radius: 70,
                          backgroundImage: const NetworkImage(
                              "https://cdn4.iconfinder.com/data/icons/documents-36/25/add-picture-1024.png"),
                          foregroundImage: profilePic != null
                              ? FileImage(profilePic!)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        hintStyle: GoogleFonts.poppins(),
                        fillColor: Colors.white,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 22),
                          child: Icon(Icons.person),
                        ),
                        suffixStyle: GoogleFonts.poppins(),
                        prefixStyle: GoogleFonts.poppins(),
                        suffixIcon: null,
                        filled: true,
                        hintText: "Enter Your Name"),
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        hintStyle: GoogleFonts.poppins(),
                        fillColor: Colors.white,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 22),
                          child: Icon(Icons.email),
                        ),
                        suffixStyle: GoogleFonts.poppins(),
                        prefixStyle: GoogleFonts.poppins(),
                        suffixIcon: null,
                        filled: true,
                        hintText: "Enter Your Email"),
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        hintStyle: GoogleFonts.poppins(),
                        fillColor: Colors.white,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 15),
                          child: Text(
                            "(+91)",
                            style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                        ),
                        suffixIcon: null,
                        filled: true,
                        hintText: "Enter Your Phone Number"),
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: pass1Controller,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        hintStyle: GoogleFonts.poppins(),
                        fillColor: Colors.white,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 22),
                          child: Icon(Icons.lock),
                        ),
                        suffixStyle: GoogleFonts.poppins(),
                        prefixStyle: GoogleFonts.poppins(),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscureText1 = !obscureText1;
                              });
                            },
                            icon: Icon(
                              obscureText1
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            )),
                        filled: true,
                        hintText: "Create Password"),
                    style: GoogleFonts.poppins(),
                    obscureText: obscureText1,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: pass2Controller,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        hintStyle: GoogleFonts.poppins(),
                        fillColor: Colors.white,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 22),
                          child: Icon(Icons.lock_open),
                        ),
                        suffixStyle: GoogleFonts.poppins(),
                        prefixStyle: GoogleFonts.poppins(),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscureText2 = !obscureText2;
                              });
                            },
                            icon: Icon(
                              obscureText2
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            )),
                        filled: true,
                        hintText: "Confirm Password"),
                    obscureText: obscureText2,
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      auth.emailSignup(
                          nameController.text.trim(),
                          emailController.text.trim(),
                          phoneController.text.trim(),
                          pass1Controller.text.trim(),
                          pass2Controller.text.trim(),
                          profilePic,
                          context, (bool value) {
                        setState(() {
                          creating = value;
                        });
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      maximumSize:
                          Size.fromWidth(MediaQuery.of(context).size.width),
                      fixedSize: const Size.fromHeight(60),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: creating
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text("Sign Up"),
                  ),
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const EmailLogin()));
                          },
                          child: Text(
                            "Already Have an Account?",
                            style: GoogleFonts.poppins(
                                fontSize: 20, color: Colors.white),
                          )),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void pickImage() async {
    try {
      XFile? selectedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (selectedImage != null) {
        File convertedFile = File(selectedImage.path);
        setState(() {
          profilePic = convertedFile;
        });
        Fluttertoast.showToast(
            msg: "Image Selected", backgroundColor: Colors.green);
      } else {
        Fluttertoast.showToast(msg: "No Image Selected !!");
        setState(() {
          profilePic = null;
        });
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.code)));
    }
  }
}
