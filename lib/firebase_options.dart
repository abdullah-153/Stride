import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'utils/secrets.dart';

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
    apiKey: ApiSecrets.firebaseWebApiKey,
    appId: ApiSecrets.firebaseWebAppId,
    messagingSenderId: ApiSecrets.firebaseWebMessagingSenderId,
    projectId: ApiSecrets.firebaseWebProjectId,
    authDomain: ApiSecrets.firebaseWebAuthDomain,
    storageBucket: ApiSecrets.firebaseWebStorageBucket,
    measurementId: ApiSecrets.firebaseWebMeasurementId,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: ApiSecrets.firebaseAndroidApiKey,
    appId: ApiSecrets.firebaseAndroidAppId,
    messagingSenderId: ApiSecrets.firebaseWebMessagingSenderId,
    projectId: ApiSecrets.firebaseWebProjectId,
    storageBucket: ApiSecrets.firebaseWebStorageBucket,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: ApiSecrets.firebaseIosApiKey,
    appId: ApiSecrets.firebaseIosAppId,
    messagingSenderId: ApiSecrets.firebaseWebMessagingSenderId,
    projectId: ApiSecrets.firebaseWebProjectId,
    storageBucket: ApiSecrets.firebaseWebStorageBucket,
    androidClientId: ApiSecrets.firebaseIosAndroidClientId,
    iosClientId: ApiSecrets.firebaseIosClientId,
    iosBundleId: ApiSecrets.firebaseIosBundleId,
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: ApiSecrets.firebaseIosApiKey,
    appId: ApiSecrets.firebaseIosAppId,
    messagingSenderId: ApiSecrets.firebaseWebMessagingSenderId,
    projectId: ApiSecrets.firebaseWebProjectId,
    storageBucket: ApiSecrets.firebaseWebStorageBucket,
    androidClientId: ApiSecrets.firebaseIosAndroidClientId,
    iosClientId: ApiSecrets.firebaseIosClientId,
    iosBundleId: ApiSecrets.firebaseIosBundleId,
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: ApiSecrets.firebaseWindowsApiKey,
    appId: ApiSecrets.firebaseWindowsAppId,
    messagingSenderId: ApiSecrets.firebaseWebMessagingSenderId,
    projectId: ApiSecrets.firebaseWebProjectId,
    authDomain: ApiSecrets.firebaseWebAuthDomain,
    storageBucket: ApiSecrets.firebaseWebStorageBucket,
    measurementId: ApiSecrets.firebaseWindowsMeasurementId,
  );
}
