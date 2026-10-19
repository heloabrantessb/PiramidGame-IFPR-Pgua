import 'dart:async';
import '../../domain/facades/community_facade.dart';
import 'community_commands_viewmodel.dart';
import 'community_state_viewmodel.dart';

class CommunityViewModel {
  final state = CommunityStateViewModel();
  late final CommunityCommandsViewModel commands;
  late final StreamSubscription _sessionSubscription;
  CommunityViewModel(CommunityFacade facade) {
    commands = CommunityCommandsViewModel(facade, state);
    _sessionSubscription = facade.sessionChanges.listen(
      state.setSession,
      onError: (Object _) {
        state.authenticationError.value =
            'Não foi possível verificar sua sessão. Tente novamente.';
      },
    );
  }
  void dispose() {
    _sessionSubscription.cancel();
    state.dispose();
  }
}
