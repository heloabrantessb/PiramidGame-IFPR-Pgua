import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import '../../core/patterns/result.dart';
import '../../core/failure/failure.dart';
import '../../domain/entity/student_entity.dart';
import '../../domain/entity/mappers/student_mapper.dart';
import 'student_storage_interface.dart';

final class StudentSqliteService implements IStudentStorage {
  static const String _tableName = 'students';

  Future<Database> get database => AppDatabase.open();

  @override
  Future<Result<List<Student>, Failure>> getStudents() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(_tableName);

      if (maps.isEmpty) {
        return const Success([]);
      }

      final students = maps.map((map) => StudentMapper.fromSqliteMap(map)).toList();
      return Success(students);
    } catch (e, s) {
      print('[SQLITE ERROR - getStudents]: $e\n$s');
      return Error(ApiLocalFailure('Erro ao carregar estudantes do banco de dados: $e'));
    }
  }

  @override
  Future<Result<Student, Failure>> createStudent(Student student) async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> existing = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [student.id],
      );

      if (existing.isNotEmpty) {
        return Error(InputFailure('Estudante com este ID já está cadastrado.'));
      }

      final id = await db.insert(
        _tableName,
        StudentMapper.toSqliteMap(student),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      if (id > 0) {
        return Success(student);
      } else {
        return Error(ApiLocalFailure('Falha ao gravar estudante no banco de dados.'));
      }
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao salvar estudante: $e'));
    }
  }

  @override
  Future<Result<Student, Failure>> updateStudent(Student student) async {
    try {
      final db = await database;

      final count = await db.update(
        _tableName,
        StudentMapper.toSqliteMap(student),
        where: 'id = ?',
        whereArgs: [student.id],
      );

      if (count > 0) {
        return Success(student);
      } else {
        return Error(EmptyResultFailure('Estudante não encontrado para atualização.'));
      }
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao atualizar dados do estudante: $e'));
    }
  }

  @override
  Future<Result<void, Failure>> deleteStudent(String id) async {
    try {
      final db = await database;

      final count = await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count > 0) {
        return const Success(null);
      } else {
        return Error(EmptyResultFailure('Estudante não encontrado para remoção.'));
      }
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao excluir estudante: $e')); 
    }
  }

  @override
  Future<Result<Student, Failure>> getStudentById(String id) async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Success(StudentMapper.fromSqliteMap(maps.first));
      } else {
         return Error(EmptyResultFailure('Estudante não encontrado.'));
      }
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao buscar estudante: $e'));
    }
  } 
}
