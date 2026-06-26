import 'package:piramid_game/core/patterns/result.dart';
import 'package:piramid_game/core/failure/failure.dart';
import '../services/student_storage_interface.dart';
import 'student_repository_interface.dart';
import '../../domain/entity/student_entity.dart';

final class StudentRepositoryImpl implements IStudentRepository {
  final IStudentStorage _localStorage;

  StudentRepositoryImpl({
    required IStudentStorage localstorage,
  }) : _localStorage = localstorage;

  @override
  Future<Result<Student, Failure>> create(Student student) async {
    return await _localStorage.createStudent(student);
  }

  @override
  Future<Result<Student, Failure>> update(Student student) async {
    return await _localStorage.updateStudent(student);
  }

  @override
  Future<Result<void, Failure>> delete(String id) async {
    return await _localStorage.deleteStudent(id);
  }

  @override
  Future<Result<Student, Failure>> getById(String id) async {
    return await _localStorage.getStudentById(id);
  }

  @override
  Future<Result<List<Student>, Failure>> getAll() async {
    return await _localStorage.getStudents();
  }
}