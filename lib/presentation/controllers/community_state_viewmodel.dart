import 'package:flutter/foundation.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../domain/entity/community_entity.dart';

class CommunityStateViewModel extends ChangeNotifier {
  final session = signal<AccountSession?>(null);
  final members = signal<List<CommunityMember>>([]);
  void setSession(AccountSession? account) {
    members.value = [];
    session.value = account;
    notifyListeners();
  }
}
