import 'package:piramid_game/core/generics/result_type.dart';
import 'package:piramid_game/domain/entity/student_entity.dart';

abstract interface class IStudentRepository {
  Future<Result<StudentEntity>> create(StudentEntity student);
  Future<Result<StudentEntity>> update(StudentEntity student);
  Future<Result<void>> delete(String id);
  Future<Result<StudentEntity>> getById(String id);
  Future<Result<List<StudentEntity>>> getAll();
}