import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: '', // No Web API key — required only for web
      appId: '1:451939535752:android:45bf3c6fb595e89550483d',
      messagingSenderId: '451939535752',
      projectId: 'django-grocer-2025',
    );
  }
}
