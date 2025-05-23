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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyAc6N5Rz9niJeL6ZIc2qcOueV6D-hG5r44',
    appId: '1:487633127051:web:2abe747069efbf433db68e',
    messagingSenderId: '487633127051',
    projectId: 'socialwelfareapp-1037d',
    authDomain: 'socialwelfareapp-1037d.firebaseapp.com',
    storageBucket: 'socialwelfareapp-1037d.firebasestorage.app',
    measurementId: 'G-T7YF5CB5QR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDve0TswNphSFAcP04m6wxtvdk3y_QnfdE',
    appId: '1:487633127051:android:ffbd5e7390e0227e3db68e',
    messagingSenderId: '487633127051',
    projectId: 'socialwelfareapp-1037d',
    storageBucket: 'socialwelfareapp-1037d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBhh1-XruC_UFhWKy_Chn6Jigp3T1lJtQM',
    appId: '1:487633127051:ios:c74b44487aa56a733db68e',
    messagingSenderId: '487633127051',
    projectId: 'socialwelfareapp-1037d',
    storageBucket: 'socialwelfareapp-1037d.firebasestorage.app',
    iosBundleId: 'com.example.socialwelfacedepartment',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBhh1-XruC_UFhWKy_Chn6Jigp3T1lJtQM',
    appId: '1:487633127051:ios:c74b44487aa56a733db68e',
    messagingSenderId: '487633127051',
    projectId: 'socialwelfareapp-1037d',
    storageBucket: 'socialwelfareapp-1037d.firebasestorage.app',
    iosBundleId: 'com.example.socialwelfacedepartment',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAc6N5Rz9niJeL6ZIc2qcOueV6D-hG5r44',
    appId: '1:487633127051:web:59f2d4dff5faa19d3db68e',
    messagingSenderId: '487633127051',
    projectId: 'socialwelfareapp-1037d',
    authDomain: 'socialwelfareapp-1037d.firebaseapp.com',
    storageBucket: 'socialwelfareapp-1037d.firebasestorage.app',
    measurementId: 'G-J8P65ML0DS',
  );
}
