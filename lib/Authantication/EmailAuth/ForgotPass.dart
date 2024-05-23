import 'package:beat_buddy/Authantication/Authantication.dart';
import 'package:beat_buddy/Authantication/EmailAuth/Login.dart';
import 'package:beat_buddy/Authantication/EmailAuth/Signup.dart';
import 'package:beat_buddy/Authantication/PhoneAuth/Signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class ForgotPassword extends StatelessWidget {
  ForgotPassword({super.key});
  Auth auth = Auth();
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade900,
        titleTextStyle: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: Row(
            children: [
              Icon(Icons.person),
              Text("Reset Password"),
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
                  const Logo(title: "Beat Buddy", subTitle: "Password Reset"),
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
                  ElevatedButton(
                    onPressed: () {
                      try {
                        FirebaseAuth.instance.sendPasswordResetEmail(
                            email: emailController.text.trim());
                        auth.showSnackBar(
                            context, "Sent Password reset Link to the mail");
                      } on FirebaseAuthException catch (e) {
                        auth.showSnackBar(context, e.code);
                      }
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
                    child: const Text("Send Email"),
                  ),
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const EmailLogin()),
                                (route) => false);
                          },
                          child: Text(
                            "Login",
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        " Other Sign in Methods ",
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupUser()));
                    },
                    style: ElevatedButton.styleFrom(
                      maximumSize:
                          Size.fromWidth(MediaQuery.of(context).size.width),
                      fixedSize: const Size.fromHeight(60),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text("Use Phone"),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EmailSignUp()));
                    },
                    style: ElevatedButton.styleFrom(
                      maximumSize:
                          Size.fromWidth(MediaQuery.of(context).size.width),
                      fixedSize: const Size.fromHeight(60),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.email,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text("Regester Using Email"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
