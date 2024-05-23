import 'dart:async';

import 'package:beat_buddy/Authantication/Authantication.dart';
import 'package:beat_buddy/Authantication/EmailAuth/Login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_pinput/new_pinput.dart';

class SignupUser extends StatefulWidget {
  const SignupUser({super.key});

  @override
  State<SignupUser> createState() => _SignupUserState();
}

class _SignupUserState extends State<SignupUser> {
  int start = 30;
  bool wait = false;
  late Timer timer;
  String buttonName = "Send";
  Auth auth = Auth();
  String verificationId = "";
  String smsCode = "";
  TextEditingController phoneController = TextEditingController();
  final pinController = TextEditingController();
  final focusNode = FocusNode();

  void init() {
    timer = Timer(Duration.zero, () {});
  }

  @override
  void initState() {
    super.initState();
    init();
  }

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
              Icon(Icons.phone),
              Text("Signin"),
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
                  const Logo(title: "Beat Buddy", subTitle: "Phone Login"),
                  textfield(
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 18),
                        child: Text("(+91)"),
                      ),
                      TextButton(
                          onPressed: wait
                              ? null
                              : () {
                                  if (phoneController.text.trim().length ==
                                      10) {
                                    setState(() {
                                      start = 30;
                                      wait = true;
                                      buttonName = "Resend";
                                    });
                                    auth.verifyPhoneNumber(
                                        "+91 ${phoneController.text.trim()}",
                                        context,
                                        setData,
                                        loader);
                                  } else {
                                    auth.showSnackBar(context,
                                        "Plese Enter a 10 digit Number");
                                  }
                                },
                          child: wait
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  buttonName,
                                  style: GoogleFonts.poppins(
                                      color:
                                          wait ? Colors.white : Colors.black),
                                )),
                      "Enter Your Phone Number"),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                        height: 1,
                        color: Colors.white70,
                      )),
                      Text(
                        " Enter 6 Digit Otp ",
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                          child: Container(
                        height: 1,
                        color: Colors.white70,
                      )),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  OtpField(),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      auth.signInWithPhoneNo(verificationId, smsCode, context,
                          phoneController.text.trim());
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize:
                          Size.fromWidth(MediaQuery.of(context).size.width),
                      textStyle: GoogleFonts.poppins(
                          fontSize: 20, fontWeight: FontWeight.w700),
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login_outlined),
                        SizedBox(
                          width: 5,
                        ),
                        Text("Login"),
                      ],
                    ),
                  ),
                  (start != 30 && start != 0)
                      ? RichText(
                          text: TextSpan(children: [
                          TextSpan(
                              text: "Send Otp Again in ",
                              style: GoogleFonts.poppins(
                                  color: Colors.yellow, fontSize: 17)),
                          TextSpan(
                              text: "00:$start ",
                              style: GoogleFonts.poppins(
                                  color: Colors.red, fontSize: 17)),
                          TextSpan(
                              text: "sec",
                              style: GoogleFonts.poppins(
                                  color: Colors.yellow, fontSize: 17)),
                        ]))
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (timer.isActive) {
      timer.cancel();
    }
    super.dispose();
  }

  void loader(bool isLoading) {
    setState(() {
      wait = isLoading;
    });
  }

  void setData(String varId) {
    setState(() {
      verificationId = varId;
    });
    StartTimer();
  }

  void StartTimer() {
    const onsec = Duration(seconds: 1);
    timer = Timer.periodic(onsec, (timer) {
      if (start == 0) {
        timer.cancel();
        wait = false;
      } else {
        setState(() {
          start--;
        });
      }
    });
  }

  Widget OtpField() {
    return Pinput(
      length: 6,
      controller: pinController,
      focusNode: focusNode,
      androidSmsAutofillMethod: AndroidSmsAutofillMethod.none,
      listenForMultipleSmsOnAndroid: true,

      // onClipboardFound: (value) {
      //   debugPrint('onClipboardFound: $value');
      //   pinController.setText(value);
      // },
      onCompleted: (pin) {
        debugPrint('onCompleted: $pin');
        setState(() {
          smsCode = pin;
        });
      },
      onChanged: (value) {
        debugPrint('onChanged: $value');
      },
      validator: (value) {
        return value == smsCode ? null : 'Pin is incorrect';
      },
      cursor: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 9),
            width: 22,
            height: 1,
          ),
        ],
      ),
    );
  }

  Widget textfield(Widget? prefixIcon, Widget? suffixIcon, String hint) {
    return TextFormField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          hintStyle: GoogleFonts.poppins(),
          fillColor: Colors.white,
          prefixIcon: prefixIcon,
          suffixStyle: GoogleFonts.poppins(),
          prefixStyle: GoogleFonts.poppins(),
          suffixIcon: suffixIcon,
          filled: true,
          hintText: hint),
      style: GoogleFonts.poppins(),
    );
  }
}
