import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Pode ser substituído pelo arquivo gerado por `flutterfire configure`.
/// Também permite configurar Android/iOS com --dart-define-from-file.
class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform {
    final ios = defaultTargetPlatform == TargetPlatform.iOS;
    const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
    final appId = ios
        ? const String.fromEnvironment('FIREBASE_IOS_APP_ID')
        : const String.fromEnvironment('FIREBASE_ANDROID_APP_ID');
    // Sem defines, o SDK usa google-services.json / GoogleService-Info.plist.
    if (apiKey.isEmpty || appId.isEmpty) return null;
    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: const String.fromEnvironment(
        'FIREBASE_MESSAGING_SENDER_ID',
        defaultValue: '576112285706',
      ),
      projectId: const String.fromEnvironment(
        'FIREBASE_PROJECT_ID',
        defaultValue: 'piramidgame-ifpr',
      ),
      iosBundleId: ios ? 'com.example.piramidGame' : null,
    );
  }
}
