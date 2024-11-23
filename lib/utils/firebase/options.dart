import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:household_manager/utils/firebase/secret_config.dart'; // Import the secret config

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: SecretConfig.webApiKey,
    appId: SecretConfig.webAppId,
    messagingSenderId: SecretConfig.webMessagingSenderId,
    projectId: 'household-manager-pv292',
    authDomain: 'household-manager-pv292.firebaseapp.com',
    storageBucket: 'household-manager-pv292.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: SecretConfig.androidApiKey,
    appId: SecretConfig.androidAppId,
    messagingSenderId: SecretConfig.androidMessagingSenderId,
    projectId: 'household-manager-pv292',
    storageBucket: 'household-manager-pv292.firebasestorage.app',
  );
}
