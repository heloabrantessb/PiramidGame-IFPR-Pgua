import '../../core/patterns/result.dart';
import '../../core/failure/failure.dart';
import '../entity/student_entity.dart';

abstract interface class IStudentFacadeUsecases {
  Future<Result<List<Student>, Failure>> getAllStudents();
  Future<Result<Student, Failure>> getStudentById(String id);
  Future<Result<void, Failure>> addStudent(Student student);
  Future<Result<void, Failure>> updateStudent(Student student);
  Future<Result<void, Failure>> deleteStudent(String id);
}