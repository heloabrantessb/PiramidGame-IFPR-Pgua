import '../../core/generics/result_type.dart';
import '../../domain/entity/student_entity.dart';

abstract interface class IStudentStorage {
  Future<Result<StudentEntity, Failure>> createStudent(StudentEntity student);
  Future<Result<StudentEntity, Failure>> updateStudent(StudentEntity student);
  Future<Result<void, Failure>> deleteStudent(String id);
  Future<Result<StudentEntity, Failure>> getStudentById(String id);
  Future<Result<List<StudentEntity>, Failure>> getStudents();
}