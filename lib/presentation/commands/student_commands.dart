import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart';
import '../../domain/entity/student_entity.dart';
import '../../domain/facades/student_facade_usecases_interface.dart';

final class GetAllStudentsCommand extends Command<List<Student>, Failure> {
  final IStudentFacadeUsecases _studentFacade;

  GetAllStudentsCommand(this._studentFacade);

  @override
  Future<Result<List<Student>, Failure>> execute() async {
    return await _studentFacade.getAllStudents();
  }
}

final class GetStudentByIdCommand extends ParameterizedCommand<Student, Failure, String> {
  final IStudentFacadeUsecases _studentFacade;

  GetStudentByIdCommand(this._studentFacade);

  @override
  Future<Result<Student, Failure>> execute() async {
    if (parameter == null || parameter!.isEmpty) {
      return Error(InputFailure('ID do estudante inválido para busca.'));
    }
    return await _studentFacade.getStudentById(parameter!);
  }
}

final class AddStudentCommand extends ParameterizedCommand<void, Failure, Student> {
  final IStudentFacadeUsecases _studentFacade;

  AddStudentCommand(this._studentFacade);

  @override
  Future<Result<void, Failure>> execute() async {
    if (parameter == null) {
      return Error(InputFailure('Dados do estudante inválidos para cadastro.'));
    }
    return await _studentFacade.addStudent(parameter!);
  }
}

final class UpdateStudentCommand extends ParameterizedCommand<void, Failure, Student> {
  final IStudentFacadeUsecases _studentFacade;

  UpdateStudentCommand(this._studentFacade);

  @override
  Future<Result<void, Failure>> execute() async {
    if (parameter == null) {
      return Error(InputFailure('Dados do estudante inválidos para atualização.'));
    }
    return await _studentFacade.updateStudent(parameter!);
  }
}

final class DeleteStudentCommand extends ParameterizedCommand<void, Failure, String> {
  final IStudentFacadeUsecases _studentFacade;

  DeleteStudentCommand(this._studentFacade);

  @override
  Future<Result<void, Failure>> execute() async {
    if (parameter == null || parameter!.isEmpty) {
      return Error(InputFailure('ID do estudante inválido para exclusão.'));
    }
    return await _studentFacade.deleteStudent(parameter!);
  }
}