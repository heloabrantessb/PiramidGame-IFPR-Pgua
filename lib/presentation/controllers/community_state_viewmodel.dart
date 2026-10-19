import 'package:flutter/foundation.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../domain/entity/community_entity.dart';

class CommunityStateViewModel extends ChangeNotifier {
  final session = signal<AccountSession?>(null);
  final members = signal<List<CommunityMember>>([]);
  final personalRanking = signal<List<CommunityMember>>([]);
  final authenticationReady = signal(false);
  final authenticationError = signal<String?>(null);
  void setSession(AccountSession? account) {
    final authChanged =
        !authenticationReady.value || session.value?.uid != account?.uid;
    if (session.value?.uid != account?.uid) {
      members.value = [];
      personalRanking.value = [];
    }
    session.value = account;
    authenticationReady.value = true;
    authenticationError.value = null;
    if (authChanged) notifyListeners();
  }
}
