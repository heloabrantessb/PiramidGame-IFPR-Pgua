import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../entity/community_entity.dart';
import '../entity/student_entity.dart';

abstract interface class ICommunityRepository {
  Future<Result<AccountSession, Failure>> register(Registration registration);
  Future<Result<AccountSession, Failure>> login(LoginCredentials credentials);
  Future<Result<List<CommunityMember>, Failure>> members();
  Future<Result<void, Failure>> deleteAccount(String studentId);
  Future<Result<void, Failure>> updateProfile(Student profile);
  Future<Result<PopularityRatings?, Failure>> assessment(
    String actorId,
    String targetId,
  );
  Future<Result<void, Failure>> rate(String actorId, Assessment assessment);
}
