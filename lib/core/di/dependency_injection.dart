import 'package:auto_injector/auto_injector.dart';
import '../../data/repositories/community_repository_impl.dart';
import '../../data/security/password_hasher.dart';
import '../../data/services/app_database.dart';
import '../../data/services/community_sqlite_service.dart';
import '../../domain/facades/community_facade.dart';
import '../../domain/repositories/community_repository_interface.dart';
import '../../domain/usecase/community_usecases.dart';
import '../../presentation/controllers/community_viewmodel.dart';
import '../theme/theme_controller.dart';

final injector = AutoInjector();

void setupDependencyInjection() {
  injector.addSingleton<ThemeController>(ThemeController.new);
  injector.addSingleton<CommunitySqliteService>(
    () => CommunitySqliteService(AppDatabase.open),
  );
  injector.addSingleton<PasswordHasher>(() => const PasswordHasher());
  injector.addSingleton<ICommunityRepository>(CommunityRepositoryImpl.new);
  injector.addSingleton<CommunityUseCases>(CommunityUseCases.new);
  injector.addSingleton<CommunityFacade>(CommunityFacade.new);
  injector.addSingleton<CommunityViewModel>(CommunityViewModel.new);
  injector.commit();
}
