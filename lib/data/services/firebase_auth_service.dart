import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth auth;
  Future<void>? _googleInitialization;
  FirebaseAuthService(this.auth);

  Future<UserCredential> register(String email, String password) =>
      auth.createUserWithEmailAndPassword(email: email, password: password);
  Future<UserCredential> login(String email, String password) =>
      auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> loginGoogle() async {
    final google = GoogleSignIn.instance;
    _googleInitialization ??= google.initialize(
      clientId: const String.fromEnvironment('GOOGLE_IOS_CLIENT_ID').isEmpty
          ? Firebase.app().options.iosClientId
          : const String.fromEnvironment('GOOGLE_IOS_CLIENT_ID'),
      serverClientId:
          const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID').isEmpty
          ? null
          : const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
    );
    try {
      await _googleInitialization;
    } catch (_) {
      _googleInitialization = null;
      rethrow;
    }
    final account = await google.authenticate();
    final token = account.authentication.idToken;
    if (token == null) {
      throw StateError('O Google não retornou uma credencial válida.');
    }
    return auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: token),
    );
  }

  Future<void> logout() async {
    // Encerra a sessão Firebase mesmo se o provedor Google estiver indisponível.
    await auth.signOut();
    if (_googleInitialization != null) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        /* Firebase já saiu. */
      }
    }
  }
}
