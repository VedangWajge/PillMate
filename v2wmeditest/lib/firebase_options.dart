import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Replace these values with your actual Firebase configuration
    return const FirebaseOptions(
      apiKey: "actual-api-key-from-firebase-console",
      appId: "actual-app-id-from-firebase-console",
      messagingSenderId: "actual-sender-id-from-firebase-console",
      projectId: "actual-project-id-from-firebase-console",
      storageBucket: "actual-storage-bucket-from-firebase-console",
      authDomain: "actual-auth-domain-from-firebase-console",
    );
  }
}
