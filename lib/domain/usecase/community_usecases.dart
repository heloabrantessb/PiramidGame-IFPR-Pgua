import 'dart:math';
import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../entity/community_entity.dart';
import '../entity/student_entity.dart';
import '../repositories/community_repository_interface.dart';

class CommunityUseCases {
  final ICommunityRepository repository;
  AccountSession? _session;
  bool _authenticating = false;
  int _sessionEpoch = 0;
  AccountSession? get session => _session;
  CommunityUseCases(this.repository);

  Future<Result<AccountSession, Failure>> register(Registration r) async {
    if (_session != null) {
      return Error(InputFailure('Saia da conta antes de cadastrar outra.'));
    }
    final problem = validateProfile(r.profile);
    if (problem != null) return Error(InputFailure(problem));
    final email = r.email.trim().toLowerCase();
    if (!_validEmail(email)) {
      return Error(InputFailure('Informe um e-mail válido.'));
    }
    if (r.password.length < 8 || r.password.length > 128) {
      return Error(InputFailure('A senha deve ter entre 8 e 128 caracteres.'));
    }
    // Identidade gerada pelo domínio; nunca reutiliza identificadores de perfis legados.
    final random = Random.secure();
    final id = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final profile = r.profile.copyWith(
      id: id,
      ratings: const PopularityRatings.empty(),
    );
    return _authenticate(
      () => repository.register(Registration(profile, email, r.password)),
    );
  }

  Future<Result<AccountSession, Failure>> login(LoginCredentials c) async {
    if (_session != null) return Error(InputFailure('Você já está conectado.'));
    final email = c.email.trim().toLowerCase();
    if (!_validEmail(email) || c.password.isEmpty || c.password.length > 128) {
      return Error(InputFailure('E-mail ou senha incorretos.'));
    }
    return _authenticate(
      () => repository.login(LoginCredentials(email, c.password)),
    );
  }

  Future<Result<AccountSession, Failure>> _authenticate(
    Future<Result<AccountSession, Failure>> Function() action,
  ) async {
    if (_authenticating) {
      return Error(InputFailure('Aguarde a autenticação em andamento.'));
    }
    _authenticating = true;
    final epoch = _sessionEpoch;
    try {
      final result = await action();
      if (epoch != _sessionEpoch) {
        return Error(InputFailure('Autenticação cancelada. Entre novamente.'));
      }
      if (result.isSuccess) _session = result.successValueOrNull;
      return result;
    } finally {
      _authenticating = false;
    }
  }

  void logout() {
    _session = null;
    _sessionEpoch++;
  }

  Future<Result<List<CommunityMember>, Failure>> members() async {
    if (_session == null) {
      return Error(InputFailure('Entre na sua conta para continuar.'));
    }
    final result = await repository.members();
    return result.fold(
      onFailure: (f) => Error(f),
      onSuccess: (members) {
        final sorted = List<CommunityMember>.of(members)
          ..sort((a, b) {
            final score = (b.score ?? -1).compareTo(a.score ?? -1);
            return score != 0
                ? score
                : a.student.nome.toLowerCase().compareTo(
                    b.student.nome.toLowerCase(),
                  );
          });
        return Success(sorted);
      },
    );
  }

  Future<Result<void, Failure>> deleteAccount() async {
    final account = _session;
    if (account == null) {
      return Error(InputFailure('Entre para excluir sua conta.'));
    }
    final result = await repository.deleteAccount(account.studentId);
    if (result.isSuccess) logout();
    return result;
  }

  Future<Result<void, Failure>> updateProfile(Student profile) async {
    if (_session == null || _session!.studentId != profile.id) {
      return Error(InputFailure('Você só pode editar seu próprio perfil.'));
    }
    final problem = validateProfile(profile);
    if (problem != null) return Error(InputFailure(problem));
    return repository.updateProfile(profile);
  }

  Future<Result<PopularityRatings?, Failure>> assessment(
    String targetId,
  ) async {
    final error = _assessmentError(targetId);
    if (error != null) return Error(InputFailure(error));
    return repository.assessment(_session!.studentId, targetId);
  }

  Future<Result<void, Failure>> rate(Assessment assessment) async {
    final error = _assessmentError(assessment.targetId);
    if (error != null) return Error(InputFailure(error));
    if (ratingValues(assessment.ratings).any((v) => v < 1 || v > 5)) {
      return Error(InputFailure('Todas as notas devem estar entre 1 e 5.'));
    }
    return repository.rate(_session!.studentId, assessment);
  }

  String? _assessmentError(String targetId) {
    if (_session == null) return 'Entre na sua conta para avaliar usuários.';
    if (targetId == _session!.studentId) {
      return 'Você não pode avaliar a si mesmo.';
    }
    if (targetId.isEmpty) return 'Usuário inválido.';
    return null;
  }

  static bool _validEmail(String email) =>
      email.length <= 254 &&
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);

  static String? validateProfile(Student p) {
    if (p.nome.trim().isEmpty) return 'O nome é obrigatório.';
    if (p.ano < 1998 || p.ano > 2026) {
      return 'Selecione uma turma entre 1998 e 2026.';
    }
    final now = DateTime.now();
    if (p.data_nascimento.isBefore(DateTime(1900)) ||
        p.data_nascimento.isAfter(now)) {
      return 'Selecione uma data de nascimento válida.';
    }
    return null;
  }
}
