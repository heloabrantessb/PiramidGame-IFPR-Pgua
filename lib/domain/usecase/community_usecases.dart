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

  Stream<AccountSession?> get sessionChanges =>
      repository.sessionChanges.map((s) {
        _session = s;
        return s;
      });

  Future<Result<AccountSession?, Failure>> restoreSession() async {
    final epoch = _sessionEpoch;
    final result = await repository.restoreSession();
    if (result.isSuccess && epoch == _sessionEpoch) {
      _session = result.successValueOrNull;
    }
    return result;
  }

  Future<Result<AccountSession, Failure>> register(LoginCredentials c) async {
    if (c.password.length < 8 || c.password.length > 128) {
      return Error(InputFailure('A senha deve ter entre 8 e 128 caracteres.'));
    }
    return _authenticate(c, register: true);
  }

  Future<Result<AccountSession, Failure>> login(LoginCredentials c) =>
      _authenticate(c);
  Future<Result<AccountSession, Failure>> loginGoogle() => _authenticate(null);

  Future<Result<AccountSession, Failure>> _authenticate(
    LoginCredentials? c, {
    bool register = false,
  }) async {
    if (_session != null) return Error(InputFailure('Você já está conectado.'));
    if (_authenticating) {
      return Error(InputFailure('Aguarde a autenticação em andamento.'));
    }
    if (c != null &&
        (!_validEmail(c.email.trim()) ||
            c.password.isEmpty ||
            c.password.length > 128)) {
      return Error(InputFailure('Informe e-mail e senha válidos.'));
    }
    _authenticating = true;
    final epoch = _sessionEpoch;
    try {
      final credentials = c == null
          ? null
          : LoginCredentials(c.email.trim().toLowerCase(), c.password);
      final result = credentials == null
          ? await repository.loginGoogle()
          : register
          ? await repository.register(credentials)
          : await repository.login(credentials);
      if (epoch != _sessionEpoch) {
        await repository.logout();
        return Error(InputFailure('Autenticação cancelada. Entre novamente.'));
      }
      if (result.isSuccess) _session = result.successValueOrNull;
      return result;
    } finally {
      _authenticating = false;
    }
  }

  Future<Result<void, Failure>> logout() async {
    _sessionEpoch++;
    final result = await repository.logout();
    if (result.isSuccess) _session = null;
    return result;
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
          ..sort((a, b) => _compare(a.score, b.score, a, b));
        return Success(sorted);
      },
    );
  }

  List<CommunityMember> personalRanking(List<CommunityMember> members) =>
      members.where((m) => m.personalRatings != null).toList()..sort(
        (a, b) => _compare(
          a.personalRatings!.nivelLenda.toDouble(),
          b.personalRatings!.nivelLenda.toDouble(),
          a,
          b,
        ),
      );

  int _compare(
    double? aScore,
    double? bScore,
    CommunityMember a,
    CommunityMember b,
  ) {
    final score = (bScore ?? -1).compareTo(aScore ?? -1);
    return score != 0
        ? score
        : a.student.nome.toLowerCase().compareTo(b.student.nome.toLowerCase());
  }

  Future<Result<void, Failure>> saveProfile(
    Student p, {
    required bool create,
    bool linkToSelf = false,
  }) async {
    if (_session == null) {
      return Error(InputFailure('Entre para cadastrar ou editar pessoas.'));
    }
    final problem = validateProfile(p);
    if (problem != null) return Error(InputFailure(problem));
    if (!create) {
      final allowed = await _checkOwner(p.id);
      if (allowed != null) return Error(allowed);
    }
    if (linkToSelf &&
        _session!.studentId != null &&
        _session!.studentId != p.id) {
      return Error(InputFailure('Sua conta já está vinculada a outra pessoa.'));
    }
    final result = create
        ? await repository.createProfile(p, linkToSelf: linkToSelf)
        : await repository.updateProfile(p, linkToSelf: linkToSelf);
    if (result.isSuccess && linkToSelf) await restoreSession();
    return result;
  }

  Future<Failure?> _checkOwner(String id) async {
    final result = await repository.members();
    if (result.isFailure) return result.failureValueOrNull;
    final matches = result.successValueOrNull!.where((m) => m.student.id == id);
    if (matches.isEmpty) return InputFailure('Pessoa não encontrada.');
    if (matches.single.createdBy != _session?.uid) {
      return InputFailure('Você só pode alterar pessoas cadastradas por você.');
    }
    return null;
  }

  Future<Result<void, Failure>> linkProfile(String personId) async {
    if (_session == null) {
      return Error(InputFailure('Entre para vincular seu perfil.'));
    }
    if (_session!.studentId != null) {
      return Error(InputFailure('Sua conta já possui um perfil vinculado.'));
    }
    final result = await repository.linkProfile(personId);
    if (result.isSuccess) await restoreSession();
    return result;
  }

  Future<Result<void, Failure>> deleteProfile(String personId) async {
    if (_session == null) {
      return Error(InputFailure('Entre para remover uma pessoa.'));
    }
    final denied = await _checkOwner(personId);
    if (denied != null) return Error(denied);
    final result = await repository.deleteProfile(personId);
    if (result.isSuccess) await restoreSession();
    return result;
  }

  Future<Result<PopularityRatings?, Failure>> assessment(
    String targetId,
  ) async {
    final error = _assessmentError(targetId);
    if (error != null) return Error(InputFailure(error));
    return repository.assessment(_session!.uid, targetId);
  }

  Future<Result<void, Failure>> rate(Assessment assessment) async {
    final error = _assessmentError(assessment.targetId);
    if (error != null) return Error(InputFailure(error));
    if (ratingValues(assessment.ratings).any((v) => v < 1 || v > 5)) {
      return Error(InputFailure('Todas as notas devem estar entre 1 e 5.'));
    }
    return repository.rate(_session!.uid, assessment);
  }

  String? _assessmentError(String targetId) {
    if (_session == null) return 'Entre na sua conta para avaliar pessoas.';
    if (targetId == _session!.studentId) {
      return 'Você não pode avaliar a si mesmo.';
    }
    if (targetId.isEmpty) return 'Pessoa inválida.';
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
    final date = DateTime(
      p.data_nascimento.year,
      p.data_nascimento.month,
      p.data_nascimento.day,
    );
    final now = DateTime.now();
    if (date.isBefore(DateTime(1900)) ||
        date.isAfter(DateTime(now.year, now.month, now.day))) {
      return 'Selecione uma data de nascimento válida.';
    }
    return null;
  }
}
