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

class CommunityCommandsViewModel {
  final CommunityFacade facade;
  final CommunityStateViewModel state;
  CommunityCommandsViewModel(this.facade, this.state);

  late final login = CommunityAction<LoginCredentials, AccountSession>((
    c,
  ) async {
    final result = await facade.login(c);
    if (result.isSuccess) state.setSession(result.successValueOrNull);
    return result;
  });
  late final register = CommunityAction<Registration, AccountSession>((
    r,
  ) async {
    final result = await facade.register(r);
    if (result.isSuccess) state.setSession(result.successValueOrNull);
    return result;
  });
  late final loadMembers = CommunityAction<void, List<CommunityMember>>((
    _,
  ) async {
    final account = state.session.value;
    final result = await facade.members();
    if (result.isSuccess && identical(state.session.value, account)) {
      state.members.value = result.successValueOrNull!;
    }
    return result;
  });
  late final updateProfile = CommunityAction<Student, void>(
    facade.updateProfile,
  );
  late final loadAssessment = CommunityAction<String, PopularityRatings?>(
    facade.assessment,
  );
  late final rate = CommunityAction<Assessment, void>(facade.rate);
  late final deleteAccount = CommunityAction<void, void>((_) async {
    final result = await facade.deleteAccount();
    if (result.isSuccess) state.setSession(null);
    return result;
  });

  late final logout = CommunityAction<void, void>((_) async {
    facade.logout();
    state.setSession(null);
    return const Success(null);
  });
}
