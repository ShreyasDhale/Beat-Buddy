// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAhIEfkEqR5kqtkA-rD2xWlwDXA-CpNmII',
    appId: '1:596957292503:web:b723a35f04d7c2122e8d92',
    messagingSenderId: '596957292503',
    projectId: 'beat-buddy-3073a',
    authDomain: 'beat-buddy-3073a.firebaseapp.com',
    storageBucket: 'beat-buddy-3073a.appspot.com',
    measurementId: 'G-218SG2SE7G',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDJPvR7q00tYbdo-kZEUwJASFk5Hj5i-l4',
    appId: '1:596957292503:android:6c891301ef9bcf092e8d92',
    messagingSenderId: '596957292503',
    projectId: 'beat-buddy-3073a',
    storageBucket: 'beat-buddy-3073a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBhVRX9_U6tqEE_Wa8L3O9Rm2rX-q0lOn0',
    appId: '1:596957292503:ios:c2a057635c6e6a3c2e8d92',
    messagingSenderId: '596957292503',
    projectId: 'beat-buddy-3073a',
    storageBucket: 'beat-buddy-3073a.appspot.com',
    iosBundleId: 'com.example.beatBuddy',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBhVRX9_U6tqEE_Wa8L3O9Rm2rX-q0lOn0',
    appId: '1:596957292503:ios:6437379128de5a682e8d92',
    messagingSenderId: '596957292503',
    projectId: 'beat-buddy-3073a',
    storageBucket: 'beat-buddy-3073a.appspot.com',
    iosBundleId: 'com.example.beatBuddy.RunnerTests',
  );
}
