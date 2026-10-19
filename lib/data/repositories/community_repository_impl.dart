import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../domain/entity/community_entity.dart';
import '../../domain/entity/student_entity.dart';
import '../../domain/repositories/community_repository_interface.dart';
import '../services/firebase_auth_service.dart';
import '../services/community_firestore_service.dart';

class CommunityRepositoryImpl implements ICommunityRepository {
  final FirebaseAuthService auth;
  final CommunityFirestoreService service;
  CommunityRepositoryImpl(this.auth, this.service);
  Stream<AccountSession?>? _sessions;

  @override
  Stream<AccountSession?> get sessionChanges => _sessions ??= auth.auth
      .authStateChanges()
      .asyncMap<AccountSession?>((user) async {
        if (user == null) return null;
        final account = await service.account(user);
        return auth.auth.currentUser?.uid == user.uid ? account : null;
      })
      .asBroadcastStream();

  Future<Result<T, Failure>> _run<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on Failure catch (f) {
      return Error(f);
    } on FirebaseAuthException catch (e) {
      return Error(
        InputFailure(switch (e.code) {
          'invalid-credential' ||
          'wrong-password' ||
          'user-not-found' => 'E-mail ou senha incorretos.',
          'email-already-in-use' => 'Este e-mail já está cadastrado.',
          'weak-password' => 'Escolha uma senha mais forte.',
          'invalid-email' => 'Informe um e-mail válido.',
          'network-request-failed' =>
            'Sem conexão. Verifique a internet e tente novamente.',
          'too-many-requests' =>
            'Muitas tentativas. Aguarde e tente novamente.',
          'account-exists-with-different-credential' =>
            'Esta conta usa outro método de login.',
          'user-disabled' => 'Esta conta está desativada.',
          _ => 'Não foi possível autenticar. Tente novamente.',
        }),
      );
    } on GoogleSignInException catch (e) {
      return Error(
        InputFailure(
          e.code == GoogleSignInExceptionCode.canceled
              ? 'Login com Google cancelado.'
              : 'Não foi possível entrar com Google. Tente novamente.',
        ),
      );
    } catch (_) {
      return Error(
        ApiLocalFailure(
          'Não foi possível concluir a operação. Verifique sua conexão e tente novamente.',
        ),
      );
    }
  }

  @override
  Future<Result<AccountSession?, Failure>> restoreSession() => _run(() async {
    final user = await auth.auth.authStateChanges().first;
    return user == null ? null : service.account(user);
  });
  @override
  Future<Result<AccountSession, Failure>> register(LoginCredentials c) => _run(
    () async =>
        service.account((await auth.register(c.email, c.password)).user!),
  );
  @override
  Future<Result<AccountSession, Failure>> login(LoginCredentials c) => _run(
    () async => service.account((await auth.login(c.email, c.password)).user!),
  );
  @override
  Future<Result<AccountSession, Failure>> loginGoogle() =>
      _run(() async => service.account((await auth.loginGoogle()).user!));
  @override
  Future<Result<void, Failure>> logout() => _run(auth.logout);
  @override
  Future<Result<List<CommunityMember>, Failure>> members() =>
      _run(service.members);
  @override
  Future<Result<void, Failure>> createProfile(
    Student p, {
    bool linkToSelf = false,
  }) =>
      _run(() => service.saveProfile(p, create: true, linkToSelf: linkToSelf));
  @override
  Future<Result<void, Failure>> updateProfile(
    Student p, {
    bool linkToSelf = false,
  }) =>
      _run(() => service.saveProfile(p, create: false, linkToSelf: linkToSelf));
  @override
  Future<Result<void, Failure>> linkProfile(String id) =>
      _run(() => service.linkProfile(id));

  @override
  Future<Result<void, Failure>> deleteProfile(String id) =>
      _run(() => service.deleteProfile(id));
  @override
  Future<Result<PopularityRatings?, Failure>> assessment(
    String uid,
    String id,
  ) => _run(() => service.assessment(uid, id));
  @override
  Future<Result<void, Failure>> rate(String uid, Assessment a) =>
      _run(() => service.rate(uid, a));
}
