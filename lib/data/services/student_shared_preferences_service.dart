import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/patterns/result.dart';
import '../../core/failure/failure.dart';
import '../../domain/entity/student_entity.dart';
import '../../domain/entity/student_mapper.dart';
import 'student_storage_interface.dart';

final class StudentSharedPreferencesService implements IStudentStorage {
  static const String _storageKey = 'students';

  @override
  Future<Result<List<Student>, Failure>> getStudents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return const Success([]);
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      final students = jsonList
          .map((item) => StudentMapper.fromMap(item as Map<String, dynamic>))
          .toList();

      return Success(students);
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao carregar estudantes do armazenamento local.'));
    }
  }

  @override
  Future<Result<Student, Failure>> createStudent(Student student) async {
    try {
      final result = await getStudents();
      
      return await result.fold(
        onSuccess: (students) async {
          // Verifica se o estudante já existe
          if (students.any((s) => s.id == student.id)) {
            return Error(InputFailure('Estudante com este ID já está cadastrado.'));
          }

          final updatedList = List<Student>.from(students)..add(student);
          final saved = await _saveList(updatedList);

          if (saved) {
            return Success(student);
          } else {
            return Error(ApiLocalFailure('Falha ao gravar estudante no armazenamento.'));
          }
        },
        onFailure: (failure) async => Error(failure),
      );
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao salvar estudante.'));
    }
  }

  @override
  Future<Result<Student, Failure>> updateStudent(Student student) async {
    try {
      final result = await getStudents();

      return await result.fold(
        onSuccess: (students) async {
          final index = students.indexWhere((s) => s.id == student.id);
          
          if (index == -1) {
            return Error(EmptyResultFailure('Estudante não encontrado para atualização.'));
          }

          final updatedList = List<Student>.from(students)..[index] = student;
          final saved = await _saveList(updatedList);

          if (saved) {
            return Success(student);
          } else {
            return Error(ApiLocalFailure('Falha ao atualizar dados no armazenamento.'));
          }
        },
        onFailure: (failure) async => Error(failure),
      );
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao atualizar dados do estudante.'));
    }
  }

  @override
  Future<Result<void, Failure>> deleteStudent(String id) async {
    try {
      final result = await getStudents();

      return await result.fold(
        onSuccess: (students) async {
          final index = students.indexWhere((s) => s.id == id);
          
          if (index == -1) {
            return Error(EmptyResultFailure('Estudante não encontrado para remoção.'));
          }

          final updatedList = List<Student>.from(students)..removeAt(index);
          final saved = await _saveList(updatedList);

          if (saved) {
            return const Success(null);
          } else {
            return Error(ApiLocalFailure('Falha ao remover estudante do armazenamento.'));
          }
        },
        onFailure: (failure) async => Error(failure),
      );
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao excluir estudante.'));
    }
  }

  @override
  Future<Result<Student, Failure>> getStudentById(String id) async {
    try {
      final result = await getStudents();

      return result.fold(
        onSuccess: (students) {
          final student = students.firstWhere(
            (s) => s.id == id,
            orElse: () => throw Exception('Not Found'),
          );
          return Success(student);
        },
        onFailure: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(EmptyResultFailure('Estudante não encontrado.'));
    }
  }

  // Método auxiliar privado para salvar a lista serializada no SharedPreferences
  Future<bool> _saveList(List<Student> students) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = students.map((s) => StudentMapper.toMap(s)).toList();
    final jsonString = json.encode(jsonList);
    return await prefs.setString(_storageKey, jsonString);
  }
}