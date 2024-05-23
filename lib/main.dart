import 'dart:io';

import 'package:beat_buddy/Authantication/EmailAuth/Login.dart';
import 'package:beat_buddy/Screens/Splash.dart';
import 'package:beat_buddy/firebase_options.dart';
import 'package:beat_buddy/screens/home_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

enum ScreenType { login, offline }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).onError((error, stackTrace) {
    debugPrint("****************** $error ***********************");
    return Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }).whenComplete(() => debugPrint("*** Initilized ***"));
  runApp(const MainApp());
  if (Platform.isAndroid) {
    requestPermission();
  }
}

void requestPermission() async {
  try {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
      Permission.audio,
      Permission.contacts,
    ].request();
    print(statuses);
  } on Exception catch (e) {
    Fluttertoast.showToast(msg: e.toString());
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Connectivity _connectivity;
  late ConnectivityResult _connectionStatus;
  ScreenType _currentScreenType = ScreenType.login;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _updateConnectionStatus(ConnectivityResult.none);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
      if (_connectionStatus == ConnectivityResult.none) {
        _currentScreenType = ScreenType.offline;
      } else {
        _currentScreenType = ScreenType.login;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Beat Buddy",
        debugShowCheckedModeBanner: false,
        home: SplashScreen(currentScreenType: _currentScreenType));
  }
}

class CheckUserLoggedIn extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CheckUserLoggedIn({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const EmailLogin();
          }
        }
      },
    );
  }
}
