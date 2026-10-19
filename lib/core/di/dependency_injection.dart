import 'package:auto_injector/auto_injector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/community_repository_impl.dart';
import '../../data/services/firebase_auth_service.dart';
import '../../data/services/community_firestore_service.dart';
import '../../data/services/local_preferences_service.dart';
import '../../domain/facades/community_facade.dart';
import '../../domain/repositories/community_repository_interface.dart';
import '../../domain/usecase/community_usecases.dart';
import '../../presentation/controllers/community_viewmodel.dart';
import '../theme/theme_controller.dart';

final injector = AutoInjector();

void setupDependencyInjection() {
  injector.addSingleton<FirebaseAuthService>(
    () => FirebaseAuthService(FirebaseAuth.instance),
  );
  injector.addSingleton<CommunityFirestoreService>(
    () => CommunityFirestoreService(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    ),
  );
  injector.addSingleton<LocalPreferencesService>(LocalPreferencesService.new);
  injector.addSingleton<ICommunityRepository>(CommunityRepositoryImpl.new);
  injector.addSingleton<CommunityUseCases>(CommunityUseCases.new);
  injector.addSingleton<CommunityFacade>(CommunityFacade.new);
  injector.addSingleton<CommunityViewModel>(CommunityViewModel.new);
  injector.addSingleton<ThemeController>(ThemeController.new);
  injector.commit();
}
