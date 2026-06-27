import '../../core/patterns/result.dart';
import '../../core/failure/failure.dart';
import '../entity/student_entity.dart';
import '../usecase/student_usecase_interface.dart';
import 'student_facade_usecases_interface.dart';

final class StudentFacadeUseCasesImpl implements IStudentFacadeUsecases {
  final IGetAllStudentsUseCase _getAllStudentsUseCase;
  final IGetStudentByIdUseCase _getStudentByIdUseCase;
  final IAddStudentUseCase _addStudentUseCase;
  final IUpdateStudentUseCase _updateStudentUseCase;
  final IDeleteStudentUseCase _deleteStudentUseCase;

  StudentFacadeUseCasesImpl(
    this._getAllStudentsUseCase,
    this._getStudentByIdUseCase,
    this._addStudentUseCase,
    this._updateStudentUseCase,
    this._deleteStudentUseCase,
  );

  @override
  Future<Result<List<Student>, Failure>> getAllStudents() {
    return _getAllStudentsUseCase(null);
  }

  @override
  Future<Result<Student, Failure>> getStudentById(String id) {
    return _getStudentByIdUseCase(id);
  }

  @override
  Future<Result<void, Failure>> addStudent(Student student) {
    return _addStudentUseCase(student);
  }

  @override
  Future<Result<void, Failure>> updateStudent(Student student) {
    return _updateStudentUseCase(student);
  }

  @override
  Future<Result<void, Failure>> deleteStudent(String id) {
    return _deleteStudentUseCase(id);
  }
}