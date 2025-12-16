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
    apiKey: 'AIzaSyC3Lqjjg6K1u4LEycMw138r77AtyuVs0es',
    appId: '1:164441790077:web:f4028a87920d3c4c14c314',
    messagingSenderId: '164441790077',
    projectId: 'gainz-49837',
    authDomain: 'gainz-49837.firebaseapp.com',
    storageBucket: 'gainz-49837.firebasestorage.app',
    measurementId: 'G-CMMRT6ZE1T',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBEGKYYIIqdoz-Z3Wl5SiXLvir-QrtBYls',
    appId: '1:164441790077:android:df5bab999e86197c14c314',
    messagingSenderId: '164441790077',
    projectId: 'gainz-49837',
    storageBucket: 'gainz-49837.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAgcvc6rUJsteUt90ngLHHEfMuMWVk2djA',
    appId: '1:164441790077:ios:83b0c6de78c9859414c314',
    messagingSenderId: '164441790077',
    projectId: 'gainz-49837',
    storageBucket: 'gainz-49837.firebasestorage.app',
    androidClientId:
        '164441790077-bveibjh33nh8eqi7qblkvkikpe04sn6r.apps.googleusercontent.com',
    iosClientId:
        '164441790077-kpo683ikt52f42inetps2edcuu2k08f5.apps.googleusercontent.com',
    iosBundleId: 'com.example.fitnessTrackerFrontend',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAgcvc6rUJsteUt90ngLHHEfMuMWVk2djA',
    appId: '1:164441790077:ios:83b0c6de78c9859414c314',
    messagingSenderId: '164441790077',
    projectId: 'gainz-49837',
    storageBucket: 'gainz-49837.firebasestorage.app',
    androidClientId:
        '164441790077-bveibjh33nh8eqi7qblkvkikpe04sn6r.apps.googleusercontent.com',
    iosClientId:
        '164441790077-kpo683ikt52f42inetps2edcuu2k08f5.apps.googleusercontent.com',
    iosBundleId: 'com.example.fitnessTrackerFrontend',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC3Lqjjg6K1u4LEycMw138r77AtyuVs0es',
    appId: '1:164441790077:web:d9823905e42a50f814c314',
    messagingSenderId: '164441790077',
    projectId: 'gainz-49837',
    authDomain: 'gainz-49837.firebaseapp.com',
    storageBucket: 'gainz-49837.firebasestorage.app',
    measurementId: 'G-J3J9BK1JTF',
  );
}
