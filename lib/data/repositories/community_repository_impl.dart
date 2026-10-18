import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../domain/entity/community_entity.dart';
import '../../domain/entity/student_entity.dart';
import '../../domain/repositories/community_repository_interface.dart';
import '../security/password_hasher.dart';
import '../services/community_sqlite_service.dart';

class CommunityRepositoryImpl implements ICommunityRepository {
  final CommunitySqliteService service;
  final PasswordHasher hasher;
  CommunityRepositoryImpl(this.service, this.hasher);

  Future<Result<T, Failure>> _run<T>(
    Future<T> Function() action,
    String error,
  ) async {
    try {
      return Success(await action());
    } catch (_) {
      return Error(ApiLocalFailure(error));
    }
  }

  @override
  Future<Result<AccountSession, Failure>> register(Registration r) async {
    try {
      if (await service.credentials(r.email) != null) {
        return Error(InputFailure('Este e-mail já está cadastrado.'));
      }
      final password = await hasher.hash(r.password);
      await service.register(r, password);
      return Success(AccountSession(r.profile.id, r.email));
    } catch (_) {
      return Error(
        ApiLocalFailure(
          'Não foi possível criar a conta. Verifique o e-mail e tente novamente.',
        ),
      );
    }
  }

  @override
  Future<Result<AccountSession, Failure>> login(LoginCredentials c) async {
    try {
      final row = await service.credentials(c.email);
      // Também deriva uma chave para e-mails ausentes, sem revelar contas pelo erro.
      final digest = row == null
          ? PasswordDigest(
              'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
              'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
              hasher.iterations,
            )
          : PasswordDigest(
              row['password_hash'] as String,
              row['salt'] as String,
              row['iterations'] as int,
            );
      final valid = await hasher.verify(c.password, digest);
      if (row == null || !valid) {
        return Error(InputFailure('E-mail ou senha incorretos.'));
      }
      return Success(
        AccountSession(row['student_id'] as String, row['email'] as String),
      );
    } catch (_) {
      return Error(
        ApiLocalFailure('Não foi possível entrar. Tente novamente.'),
      );
    }
  }

  @override
  Future<Result<List<CommunityMember>, Failure>> members() =>
      _run(service.members, 'Não foi possível carregar os usuários.');

  @override
  Future<Result<void, Failure>> deleteAccount(String studentId) => _run(
    () => service.deleteAccount(studentId),
    'Não foi possível excluir sua conta.',
  );

  @override
  Future<Result<void, Failure>> updateProfile(Student profile) => _run(
    () => service.updateProfile(profile),
    'Não foi possível salvar o perfil.',
  );

  @override
  Future<Result<PopularityRatings?, Failure>> assessment(
    String actorId,
    String targetId,
  ) => _run(
    () => service.assessment(actorId, targetId),
    'Não foi possível carregar sua avaliação.',
  );

  @override
  Future<Result<void, Failure>> rate(String actorId, Assessment assessment) =>
      _run(
        () => service.rate(actorId, assessment),
        'Não foi possível salvar a avaliação.',
      );
}
