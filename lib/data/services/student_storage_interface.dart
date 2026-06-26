import '../../core/patterns/result.dart';
import '../../core/failure/failure.dart';
import '../../domain/entity/student_entity.dart';

abstract interface class IStudentStorage {
  Future<Result<Student, Failure>> createStudent(Student student);
  Future<Result<Student, Failure>> updateStudent(Student student);
  Future<Result<void, Failure>> deleteStudent(String id);
  Future<Result<Student, Failure>> getStudentById(String id);
  Future<Result<List<Student>, Failure>> getStudents();
}