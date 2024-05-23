import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageHandler {
  static void _showSnackBar(BuildContext context, String msg, Color color) {
    final snackBar = SnackBar(
      content: Text(
        msg,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      duration: const Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showError(BuildContext context, String msg) {
    _showSnackBar(context, msg, Colors.red);
  }

  static void showSuccess(BuildContext context, String msg) {
    _showSnackBar(context, msg, Colors.green);
  }

  static void showAction(BuildContext context, String msg) {
    _showSnackBar(context, msg, Colors.deepOrange);
  }
}
