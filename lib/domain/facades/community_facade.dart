import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../entity/community_entity.dart';
import '../entity/student_entity.dart';
import '../usecase/community_usecases.dart';

class CommunityFacade {
  final CommunityUseCases useCases;
  CommunityFacade(this.useCases);
  Future<Result<AccountSession, Failure>> register(Registration r) =>
      useCases.register(r);
  Future<Result<AccountSession, Failure>> login(LoginCredentials c) =>
      useCases.login(c);
  Future<Result<List<CommunityMember>, Failure>> members() =>
      useCases.members();
  Future<Result<void, Failure>> updateProfile(Student p) =>
      useCases.updateProfile(p);
  Future<Result<PopularityRatings?, Failure>> assessment(String id) =>
      useCases.assessment(id);
  Future<Result<void, Failure>> rate(Assessment a) => useCases.rate(a);
  Future<Result<void, Failure>> deleteAccount() => useCases.deleteAccount();
  void logout() => useCases.logout();
}
