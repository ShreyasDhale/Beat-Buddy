import 'package:beat_buddy/Authantication/Authantication.dart';
import 'package:beat_buddy/Authantication/EmailAuth/ForgotPass.dart';
import 'package:beat_buddy/Authantication/EmailAuth/Signup.dart';
import 'package:beat_buddy/Authantication/PhoneAuth/Signup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmailLogin extends StatefulWidget {
  const EmailLogin({super.key});

  @override
  State<EmailLogin> createState() => _EmailLoginState();
}

class _EmailLoginState extends State<EmailLogin> {
  Auth auth = Auth();
  TextEditingController emailController = TextEditingController();
  TextEditingController pass1Controller = TextEditingController();
  bool obscureText = true;
  bool creating = false;
  String subTitle = "Lets Go";
  String title = "Beat Buddy";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade900,
        titleTextStyle: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person),
            Text("Signin"),
          ],
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
                  Logo(title: title, subTitle: subTitle),
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
                                obscureText = !obscureText;
                              });
                            },
                            icon: Icon(
                              obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            )),
                        filled: true,
                        hintText: "Enter Your Password"),
                    style: GoogleFonts.poppins(),
                    obscureText: obscureText,
                  ),
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ForgotPassword()));
                          },
                          child: Text(
                            "Forgot Password ?",
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      auth.emailSignIn(emailController.text.trim(),
                          pass1Controller.text.trim(), context);
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
                        : const Text("Sign In"),
                  ),
                  const SizedBox(
                    height: 10,
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

class Logo extends StatelessWidget {
  const Logo({
    super.key,
    required this.title,
    required this.subTitle,
  });

  final String title;
  final String subTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 80,
          foregroundImage: AssetImage("Assets/Images/IconImage.png"),
        ),
        Text(
          title,
          style: GoogleFonts.rubikBeastly(color: Colors.white, fontSize: 40),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              subTitle,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 30),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
              child: Icon(
                Icons.arrow_circle_right,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
