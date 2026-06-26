import 'package:piramid_game/core/patterns/result.dart';
import 'package:piramid_game/core/failure/failure.dart';
import 'package:piramid_game/domain/entity/student_entity.dart';

abstract interface class IStudentRepository {
  Future<Result<Student, Failure>> create(Student student);
  Future<Result<Student, Failure>> update(Student student);
  Future<Result<void, Failure>> delete(String id);
  Future<Result<Student, Failure>> getById(String id);
  Future<Result<List<Student>, Failure>> getAll();
}