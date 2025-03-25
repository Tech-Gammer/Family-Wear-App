import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAs6Fd3lvhCaMUaSx21NC7SfgG1Cme6K10',
    appId: '1:40683971702:android:0c877be5cca1f966142b57',
    messagingSenderId: '40683971702',
    projectId: 'familywear-b3028',
    storageBucket: 'familywear-b3028.appspot.com', // Corrected
    databaseURL: 'https://familywear-b3028.firebaseio.com', // Added
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAs6Fd3lvhCaMUaSx21NC7SfgG1Cme6K10',
    appId: '1:40683971702:ios:exampleiosappid', // Replace with correct iOS App ID
    messagingSenderId: '40683971702',
    projectId: 'familywear-b3028',
    storageBucket: 'familywear-b3028.appspot.com', // Corrected
    iosBundleId: 'com.example.familyWearApplication',
    databaseURL: 'https://familywear-b3028.firebaseio.com', // Added
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAs6Fd3lvhCaMUaSx21NC7SfgG1Cme6K10',
    appId: '1:40683971702:ios:examplemacosappid', // Replace with correct macOS App ID
    messagingSenderId: '40683971702',
    projectId: 'familywear-b3028',
    storageBucket: 'familywear-b3028.appspot.com', // Corrected
    iosBundleId: 'com.example.familyWearApplication',
    databaseURL: 'https://familywear-b3028.firebaseio.com', // Added
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyAs6Fd3lvhCaMUaSx21NC7SfgG1Cme6K10",
    authDomain: "familywear-b3028.firebaseapp.com",
    projectId: "familywear-b3028",
    storageBucket: "familywear-b3028.appspot.com", // Corrected
    messagingSenderId: "40683971702",
    appId: "1:40683971702:web:f26af6f66917630e142b57",
    measurementId: "G-MEASUREMENT_ID", // Optional but recommended for analytics
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAs6Fd3lvhCaMUaSx21NC7SfgG1Cme6K10',
    appId: '1:40683971702:windows:examplewindowsappid', // Replace with correct Windows App ID
    messagingSenderId: '40683971702',
    projectId: 'familywear-b3028',
    storageBucket: 'familywear-b3028.appspot.com', // Corrected
    databaseURL: 'https://familywear-b3028.firebaseio.com', // Added
  );
}
