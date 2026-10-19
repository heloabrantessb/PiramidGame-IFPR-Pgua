import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart';
import '../../domain/entity/community_entity.dart';
import '../../domain/entity/student_entity.dart';
import '../../domain/facades/community_facade.dart';
import 'community_state_viewmodel.dart';

final class CommunityAction<P, T> extends ParameterizedCommand<T, Failure, P> {
  final Future<Result<T, Failure>> Function(P) action;
  CommunityAction(this.action);
  @override
  Future<Result<T, Failure>> execute() => action(parameter as P);
}

class ProfileSubmission {
  final Student profile;
  final bool create;
  final bool linkToSelf;
  const ProfileSubmission(
    this.profile, {
    required this.create,
    this.linkToSelf = false,
  });
}

class CommunityCommandsViewModel {
  final CommunityFacade facade;
  final CommunityStateViewModel state;
  CommunityCommandsViewModel(this.facade, this.state);

  Future<Result<AccountSession, Failure>> _authenticate(
    Future<Result<AccountSession, Failure>> Function() action,
  ) async {
    final result = await action();
    if (result.isSuccess) state.setSession(result.successValueOrNull);
    return result;
  }

  late final restoreSession = CommunityAction<void, AccountSession?>((_) async {
    final result = await facade.restoreSession();
    if (result.isSuccess) {
      state.setSession(result.successValueOrNull);
    } else {
      state.authenticationError.value = result.failureValueOrNull!.msg;
    }
    return result;
  });
  late final login = CommunityAction<LoginCredentials, AccountSession>(
    (c) => _authenticate(() => facade.login(c)),
  );
  late final register = CommunityAction<LoginCredentials, AccountSession>(
    (c) => _authenticate(() => facade.register(c)),
  );
  late final loginGoogle = CommunityAction<void, AccountSession>(
    (_) => _authenticate(facade.loginGoogle),
  );
  late final loadMembers = CommunityAction<void, List<CommunityMember>>((
    _,
  ) async {
    final uid = state.session.value?.uid;
    final restored = await facade.restoreSession();
    if (restored.isSuccess && restored.successValueOrNull?.uid == uid) {
      state.setSession(restored.successValueOrNull);
    }
    final result = await facade.members();
    if (result.isSuccess && state.session.value?.uid == uid) {
      state.members.value = result.successValueOrNull!;
      state.personalRanking.value = facade.personalRanking(
        result.successValueOrNull!,
      );
    }
    return result;
  });
  late final saveProfile = CommunityAction<ProfileSubmission, void>((p) async {
    final result = await facade.saveProfile(
      p.profile,
      create: p.create,
      linkToSelf: p.linkToSelf,
    );
    if (result.isSuccess) await restoreSession.executeWith(null);
    return result;
  });
  late final linkProfile = CommunityAction<String, void>((id) async {
    final result = await facade.linkProfile(id);
    if (result.isSuccess) await restoreSession.executeWith(null);
    return result;
  });

  late final deleteProfile = CommunityAction<String, void>((id) async {
    final result = await facade.deleteProfile(id);
    if (result.isSuccess) await restoreSession.executeWith(null);
    return result;
  });
  late final loadAssessment = CommunityAction<String, PopularityRatings?>(
    facade.assessment,
  );
  late final rate = CommunityAction<Assessment, void>(facade.rate);
  late final logout = CommunityAction<void, void>((_) async {
    final result = await facade.logout();
    if (result.isSuccess) state.setSession(null);
    return result;
  });
}
