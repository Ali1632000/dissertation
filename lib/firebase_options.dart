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
    apiKey: 'AIzaSyCj73yQr8w9ERdKf5uwn_QF8zfZkXMZTyI',
    appId: '1:1002484767701:web:323cc6e2a38ce17d8cbb5c',
    messagingSenderId: '1002484767701',
    projectId: 'aitodolist',
    authDomain: 'aitodolist.firebaseapp.com',
    storageBucket: 'aitodolist.appspot.com',
    measurementId: 'G-JM6Z5NNS75',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBZ0EcyjoS1j5ISXXVlJeQBTfQY5XfmZyg',
    appId: '1:1002484767701:android:e2c9b4fbf57bffb98cbb5c',
    messagingSenderId: '1002484767701',
    projectId: 'aitodolist',
    storageBucket: 'aitodolist.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBx38jwJ_ksR0bzEFa1uWpPzFAfHNNSAEE',
    appId: '1:1002484767701:ios:8c829d33fa73bea88cbb5c',
    messagingSenderId: '1002484767701',
    projectId: 'aitodolist',
    storageBucket: 'aitodolist.appspot.com',
    iosBundleId: 'com.example.todolist',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBx38jwJ_ksR0bzEFa1uWpPzFAfHNNSAEE',
    appId: '1:1002484767701:ios:091f482ffbbcbab08cbb5c',
    messagingSenderId: '1002484767701',
    projectId: 'aitodolist',
    storageBucket: 'aitodolist.appspot.com',
    iosBundleId: 'com.example.todolist.RunnerTests',
  );
}
