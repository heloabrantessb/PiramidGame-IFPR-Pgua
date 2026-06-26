import '../../domain/facades/student_facade_usecases_interface.dart';
import '../commands/student_commands.dart';
import 'student_commands_viewmodel.dart';
import 'student_state_viewmodel.dart';

/// ViewModel Principal que une o estado e as ações (comandos) de Estudantes
class StudentViewModel {
  late final StudentStateViewModel _state;
  late final StudentCommandsViewModel _commands;

  /// Expõe o estado reativo da UI
  StudentStateViewModel get state => _state;

  /// Expõe as ações e gatilhos de execução dos comandos
  StudentCommandsViewModel get commands => _commands;

  /// Construtor que inicializa a estrutura do MVVM tradicional de três partes.
  /// Recebe a Facade de Casos de Uso do domínio por injeção.
  StudentViewModel(IStudentFacadeUsecases facade) {
    _state = StudentStateViewModel();
    
    _commands = StudentCommandsViewModel(
      state: _state,
      getAllStudentsCommand: GetAllStudentsCommand(facade),
      getStudentByIdCommand: GetStudentByIdCommand(facade),
      addStudentCommand: AddStudentCommand(facade),
      updateStudentCommand: UpdateStudentCommand(facade),
      deleteStudentCommand: DeleteStudentCommand(facade),
    );
  }
}
