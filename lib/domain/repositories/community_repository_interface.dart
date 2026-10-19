import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../entity/community_entity.dart';
import '../entity/student_entity.dart';

abstract interface class ICommunityRepository {
  Stream<AccountSession?> get sessionChanges;
  Future<Result<AccountSession?, Failure>> restoreSession();
  Future<Result<AccountSession, Failure>> register(
    LoginCredentials credentials,
  );
  Future<Result<AccountSession, Failure>> login(LoginCredentials credentials);
  Future<Result<AccountSession, Failure>> loginGoogle();
  Future<Result<void, Failure>> logout();
  Future<Result<List<CommunityMember>, Failure>> members();
  Future<Result<void, Failure>> createProfile(
    Student profile, {
    bool linkToSelf = false,
  });
  Future<Result<void, Failure>> updateProfile(
    Student profile, {
    bool linkToSelf = false,
  });
  Future<Result<void, Failure>> linkProfile(String personId);
  Future<Result<void, Failure>> deleteProfile(String personId);
  Future<Result<PopularityRatings?, Failure>> assessment(
    String actorUid,
    String targetId,
  );
  Future<Result<void, Failure>> rate(String actorUid, Assessment assessment);
  Future<Result<bool, Failure>> readDarkTheme();
  Future<Result<void, Failure>> saveDarkTheme(bool dark);
}
