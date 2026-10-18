import '../../domain/facades/community_facade.dart';
import 'community_commands_viewmodel.dart';
import 'community_state_viewmodel.dart';

class CommunityViewModel {
  final state = CommunityStateViewModel();
  late final CommunityCommandsViewModel commands;
  CommunityViewModel(CommunityFacade facade) {
    commands = CommunityCommandsViewModel(facade, state);
  }
}
