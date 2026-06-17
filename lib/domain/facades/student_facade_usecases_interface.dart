import 'package:piramid_game/core/patterns/result.dart';
import 'package:piramid_game/domain/entity/student_entity.dart';
import 'package:piramid_game/domain/errors/failures.dart';

abstract interface class IStudentFacadeUsecases {
  Future<Result<List<StudentEntity>, Failure>> getAllStudents();
  Future<Result<StudentEntity, Failure>> getStudentById(String id);
  Future<Result<void, Failure>> addStudent(StudentEntity student);
  Future<Result<void, Failure>> updateStudent(StudentEntity student);
  Future<Result<void, Failure>> deleteStudent(String id);
}