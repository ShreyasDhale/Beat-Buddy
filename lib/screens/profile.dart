import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  Map<String, dynamic> data = {};
  File? pickedImage;
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    getUserData();
    setState(() {
      pickedImage = null;
    });
  }

  void pickImage() async {
    try {
      XFile? selectedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (selectedImage != null) {
        File convertedFile = File(selectedImage.path);
        setState(() {
          pickedImage = convertedFile;
        });
      } else {
        setState(() {
          pickedImage = null;
        });
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> getUserData() async {
    final user = auth.currentUser;
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("Users")
        .doc(user?.uid)
        .get();
    setState(() {
      if (snapshot.data() != null) {
        data = snapshot.data() as Map<String, dynamic>;
        data.forEach((key, value) {
          if (value == null || (value is String && value.isEmpty)) {
            // Field is empty or null
            print('$key is empty');
          }
        });
        print(snapshot);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Profile Settings",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.deepPurple.shade800,
        ),
        body: Stack(
          alignment: Alignment.topCenter,
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 10.0),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        InkWell(
                          onTap: pickImage,
                          child: CircleAvatar(
                            radius: 80,
                            backgroundImage: const NetworkImage(
                                "https://cdn4.iconfinder.com/data/icons/documents-36/25/add-picture-1024.png"),
                            foregroundImage: data['profilePicUrl'] != null &&
                                    data['profilePicUrl'] != ""
                                ? NetworkImage(data['profilePicUrl'])
                                : null,
                          ),
                        ),
                        pickedImage != null
                            ? InkWell(
                                onTap: pickImage,
                                child: CircleAvatar(
                                  radius: 80,
                                  backgroundImage: const NetworkImage(
                                      "https://cdn4.iconfinder.com/data/icons/documents-36/25/add-picture-1024.png"),
                                  foregroundImage: pickedImage != null
                                      ? FileImage(pickedImage!)
                                      : null,
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 200,
                      child: buildDecoratedElevatedButton(context, () async {
                        if (pickedImage != null) {
                          setState(() {
                            uploading = true;
                          });
                          UploadTask uploadTask1 = FirebaseStorage.instance
                              .ref()
                              .child("Profile Pic")
                              .child(const Uuid().v1())
                              .putFile(pickedImage!);
                          TaskSnapshot taskSnapshot1 = await uploadTask1;
                          data["profilePicUrl"] =
                              await taskSnapshot1.ref.getDownloadURL();
                          FirebaseFirestore.instance
                              .collection("Users")
                              .doc(auth.currentUser?.uid)
                              .update(data);
                          setState(() {
                            uploading = false;
                            pickedImage = null;
                          });
                          getUserData();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                            "Please Select Image First",
                            style: GoogleFonts.poppins(),
                          )));
                        }
                      }, "Update Image", uploading),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (data['Name'] != null && data['Name'] != "")
                      listTile(const Icon(Icons.person), data['Name']),
                    if (data['Email'] != null && data['Email'] != "")
                      listTile(const Icon(Icons.email), data['Email']),
                    if (data['Phone'] != null && data['Phone'] != "")
                      listTile(const Icon(Icons.phone), "+91 ${data['Phone']}"),
                    if (data['Name'] == null ||
                        data['Name'] == "" ||
                        data['Phone'] == null ||
                        data['Phone'] == "" ||
                        data['Email'] == null ||
                        data['Email'] == "")
                      ElevatedButton(
                        onPressed: () {
                          showCompleteDialog(data);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          "Complete Profile",
                          style: GoogleFonts.poppins(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                  ],
                ),
              ),
            )
          ],
        ));
  }

  Future<void> showCompleteDialog(Map<String, dynamic> data) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Complete Profile'),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close))
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (data['Name'] == "")
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        data["Name"] = value;
                      });
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.grey,
                      ),
                      hintText: 'Name',
                      contentPadding: EdgeInsets.all(8.0),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              if (data['Email'] == "")
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        data["Email"] = value;
                      });
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.email,
                        color: Colors.grey,
                      ),
                      hintText: 'Email',
                      contentPadding: EdgeInsets.all(8.0),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              if (data['Phone'] == "")
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        data["Phone"] = value;
                      });
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.phone,
                        color: Colors.grey,
                      ),
                      hintText: 'Phone',
                      contentPadding: EdgeInsets.all(8.0),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              const SizedBox(height: 16.0),
              buildDecoratedElevatedButton(context, () async {
                if (data["Name"] != '' &&
                    data["Email"] != '' &&
                    data["Phone"] != '') {
                  FirebaseFirestore.instance
                      .collection("Users")
                      .doc(auth.currentUser?.uid)
                      .update(data);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                    "Details Updated",
                    style: GoogleFonts.poppins(),
                  )));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                    "Please Fill Out All Details",
                    style: GoogleFonts.poppins(),
                  )));
                }
              }, "Complete", false),
            ],
          ),
        );
      },
    );
  }

  Widget listTile(Widget leading, String data) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 2.0),
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.grey[200], // Background color
      ),
      margin: const EdgeInsets.all(8.0), // Adjust the margin as needed
      child: ListTile(
        title: Text(
          data,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: leading,
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          // Add onTap functionality if needed
          print('List Tile tapped!');
        },
      ),
    );
  }

  buildDecoratedElevatedButton(BuildContext context, Function onPressed,
      String buttonText, bool loading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
