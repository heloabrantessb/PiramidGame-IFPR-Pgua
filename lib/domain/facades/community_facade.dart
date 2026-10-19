import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../entity/community_entity.dart';
import '../entity/student_entity.dart';
import '../usecase/community_usecases.dart';

class CommunityFacade {
  final CommunityUseCases useCases;
  CommunityFacade(this.useCases);
  Stream<AccountSession?> get sessionChanges => useCases.sessionChanges;
  Future<Result<AccountSession?, Failure>> restoreSession() =>
      useCases.restoreSession();
  Future<Result<AccountSession, Failure>> register(LoginCredentials c) =>
      useCases.register(c);
  Future<Result<AccountSession, Failure>> login(LoginCredentials c) =>
      useCases.login(c);
  Future<Result<AccountSession, Failure>> loginGoogle() =>
      useCases.loginGoogle();
  Future<Result<void, Failure>> logout() => useCases.logout();
  Future<Result<List<CommunityMember>, Failure>> members() =>
      useCases.members();
  List<CommunityMember> personalRanking(List<CommunityMember> members) =>
      useCases.personalRanking(members);
  Future<Result<void, Failure>> saveProfile(
    Student p, {
    required bool create,
    bool linkToSelf = false,
  }) => useCases.saveProfile(p, create: create, linkToSelf: linkToSelf);
  Future<Result<void, Failure>> linkProfile(String id) =>
      useCases.linkProfile(id);
  Future<Result<void, Failure>> deleteProfile(String id) =>
      useCases.deleteProfile(id);
  Future<Result<PopularityRatings?, Failure>> assessment(String id) =>
      useCases.assessment(id);
  Future<Result<void, Failure>> rate(Assessment a) => useCases.rate(a);
  Future<Result<bool, Failure>> readDarkTheme() => useCases.readDarkTheme();
  Future<Result<void, Failure>> saveDarkTheme(bool dark) =>
      useCases.saveDarkTheme(dark);
}
