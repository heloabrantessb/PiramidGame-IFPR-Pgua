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
    Future<Result<StudentEntity, Failure>> create(StudentEntity student) async {
        return await _localStorage.createStudent(student);
    }

    @override
    Future<Result<StudentEntity, Failure>> update(StudentEntity student) async {
        return await _localStorage.updateStudent(student);
    }

    @override
    Future<Result<void, Failure>> delete(String id) async {
        return await _localStorage.deleteStudent(id);
    }

    @override
    Future<Result<StudentEntity, Failure>> getById(String id) async {
        return await _localStorage.getStudentById(id);
    }   

    @override
    Future<Result<List<StudentEntity>, Failure>> getAll() async {
        return await _localStorage.getStudents();
    }
}