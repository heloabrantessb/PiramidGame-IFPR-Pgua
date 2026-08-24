import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../core/patterns/result.dart';
import '../../core/failure/failure.dart';
import '../../domain/entity/student_entity.dart';
import '../../domain/entity/mappers/student_mapper.dart';
import 'student_storage_interface.dart';

final class StudentSqliteService implements IStudentStorage {
  static Database? _database;
  static const String _tableName = 'students';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'piramid_game.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS $_tableName');
        await _onCreate(db, newVersion);
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        curso TEXT NOT NULL,
        ano INTEGER NOT NULL,
        apelido TEXT NOT NULL,
        data_nascimento TEXT NOT NULL,
        resenha INTEGER NOT NULL,
        presencaVip INTEGER NOT NULL,
        aura INTEGER NOT NULL,
        modoParceiro INTEGER NOT NULL,
        carismaNatural INTEGER NOT NULL,
        humorDeMilhoes INTEGER NOT NULL,
        energiaDeGrupo INTEGER NOT NULL,
        criatividadeCaotica INTEGER NOT NULL,
        modoAtleta INTEGER NOT NULL,
        talentoDePalco INTEGER NOT NULL,
        dripEscolar INTEGER NOT NULL,
        coracaoDeDorama INTEGER NOT NULL,
        queridinhoDosProfessores INTEGER NOT NULL,
        cerebroTurbo INTEGER NOT NULL,
        caosControlado INTEGER NOT NULL
      )
    ''');
  }

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
    } catch (e, s) {
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
