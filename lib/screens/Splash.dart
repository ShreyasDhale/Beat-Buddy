import 'package:beat_buddy/Screens/NoInternet.dart';
import 'package:beat_buddy/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key, required this.currentScreenType})
      : super(key: key);
  final ScreenType currentScreenType;

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward(); // Start the animation
    loadScreens();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> loadScreens() async {
    await Future.delayed(const Duration(seconds: 4));
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) =>
            widget.currentScreenType == ScreenType.login
                ? CheckUserLoggedIn()
                : const NoInternet()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _animation,
                child: Image.asset(
                  "Assets/Images/IconImage.png",
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _animation,
                child: Text("Beat Buddy",
                    style: GoogleFonts.rubikBeastly(
                      fontSize: 40,
                      color: Colors.white.withOpacity(1),
                      fontWeight: FontWeight.w100,
                    )),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 20,
                width: 20,
                child: RotationTransition(
                  turns: _animation,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
