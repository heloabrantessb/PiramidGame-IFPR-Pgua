import 'package:auto_injector/auto_injector.dart';
import '../../data/repositories/student_repository_impl.dart';
import '../../data/repositories/student_repository_interface.dart';
import '../../data/services/student_shared_preferences_service.dart';
import '../../data/services/student_storage_interface.dart';
import '../../domain/facades/student_facade_usecases_impl.dart';
import '../../domain/facades/student_facade_usecases_interface.dart';
import '../../domain/usecase/student_usecase_impl.dart';
import '../../domain/usecase/student_usecase_interface.dart';
import '../../presentation/controllers/student_viewmodel.dart';
import '../theme/theme_controller.dart';

final injector = AutoInjector();

void setupDependencyInjection() {
  // Core
  injector.addSingleton<ThemeController>(ThemeController.new);

  // Data Services & Repositories
  injector.addSingleton<IStudentStorage>(StudentSharedPreferencesService.new);
  injector.addSingleton<IStudentRepository>(StudentRepositoryImpl.new);

  // Domain Use Cases
  injector.addSingleton<IGetAllStudentsUseCase>(GetAllStudentsUseCaseImpl.new);
  injector.addSingleton<IGetStudentByIdUseCase>(GetStudentByIdUseCaseImpl.new);
  injector.addSingleton<IAddStudentUseCase>(AddStudentUseCaseImpl.new);
  injector.addSingleton<IUpdateStudentUseCase>(UpdateStudentUseCaseImpl.new);
  injector.addSingleton<IDeleteStudentUseCase>(DeleteStudentUseCaseImpl.new);

  // Domain Facade
  injector.addSingleton<IStudentFacadeUsecases>(StudentFacadeUseCasesImpl.new);

  // Presentation ViewModels
  injector.addSingleton<StudentViewModel>(StudentViewModel.new);

  injector.commit();
}
