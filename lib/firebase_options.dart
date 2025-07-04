// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyANqe0gfK9-uP1OasOBp0Z5BGSmNJD_utY',
    appId: '1:74998519528:web:8f3db7446e8016a17a9b5d',
    messagingSenderId: '74998519528',
    projectId: 'friends-cc2a9',
    authDomain: 'friends-cc2a9.firebaseapp.com',
    storageBucket: 'friends-cc2a9.appspot.com',
    measurementId: 'G-3P4XJ9K02V',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCg-5Kmm6a9D64koQ1tBqeYxLH5Lvjp91Q',
    appId: '1:74998519528:android:e26ff583ef4663d77a9b5d',
    messagingSenderId: '74998519528',
    projectId: 'friends-cc2a9',
    storageBucket: 'friends-cc2a9.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAvRi37-sQJTIbsRPC1r7nggU6U4bhUeyw',
    appId: '1:74998519528:ios:dab6627b8268def87a9b5d',
    messagingSenderId: '74998519528',
    projectId: 'friends-cc2a9',
    storageBucket: 'friends-cc2a9.appspot.com',
    androidClientId: '74998519528-orcfck0ogr370jb15p42d02k6bq9hq1q.apps.googleusercontent.com',
    iosClientId: '74998519528-i3f3povu2bi0qv7hp3ggs1kcb14c1o7a.apps.googleusercontent.com',
    iosBundleId: 'com.mighty.taxirider2',
  );
}
