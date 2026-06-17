import '../../core/patterns/result.dart';
import '../entity/student_entity.dart';
import '../usecase/student_usecase_interface.dart';
import 'student_facade_usecases_interface.dart';

final class StudentFacadeUseCasesImpl implements IStudentFacadeUsecases {

  final IStudentUseCase _getStudentsUsecase;
  final IStudentUseCase _getStudentByIdUsecase;
  final IStudentUseCase _addStudentUsecase;
  final IStudentUseCase _updateStudentUsecase;
  final IStudentUseCase _deleteStudentUsecase;

  StudentFacadeUseCasesImpl(
    this._getStudentsUsecase,
    this._getStudentByIdUsecase,
    this._addStudentUsecase,
    this._updateStudentUsecase,
    this._deleteStudentUsecase,
  );

  @override
  Future<Result<List<StudentEntity>, Failure>> getAllStudents() {
    return _getStudentsUsecase();
  }

  @override
  Future<Result<StudentEntity, Failure>> getStudentById(String id) {
    return _getStudentByIdUsecase();
  }

  @override
  Future<Result<void, Failure>> addStudent(StudentEntity student) {
    return _addStudentUsecase();
  }

  @override
  Future<Result<void, Failure>> updateStudent(StudentEntity student) {
    return _updateStudentUsecase();
  }

  @override
  Future<Result<void, Failure>> deleteStudent(String id) {
    return _deleteStudentUsecase();
  }
}