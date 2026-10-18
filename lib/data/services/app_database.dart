import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as mobile;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../domain/entity/community_entity.dart';

class AppDatabase {
  static Future<Database>? _opening;

  static Future<Database> open() => _opening ??= _open();

  static Future<Database> _open() async {
    try {
      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      } else {
        databaseFactory = mobile.databaseFactorySqflitePlugin;
      }
      return await openDatabase(
        join(await getDatabasesPath(), 'piramid_game.db'),
        version: 3,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: create,
        onUpgrade: upgrade,
      );
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  static Future<void> create(Database db, int version) async {
    await db.execute('''CREATE TABLE students (
      id TEXT PRIMARY KEY, nome TEXT NOT NULL, curso TEXT NOT NULL,
      ano INTEGER NOT NULL, apelido TEXT NOT NULL,
      data_nascimento TEXT NOT NULL,
      ${ratingLabels.keys.map((k) => '$k INTEGER NOT NULL').join(', ')}
    )''');
    await _createAccounts(db);
  }

  static Future<void> upgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Preserva os perfis legados. Eles não viram contas sem credenciais.
    if (oldVersion < 3) await _createAccounts(db);
  }

  static Future<void> _createAccounts(Database db) async {
    await db.execute('''CREATE TABLE accounts (
      student_id TEXT PRIMARY KEY REFERENCES students(id) ON DELETE CASCADE,
      email TEXT NOT NULL COLLATE NOCASE UNIQUE,
      password_hash TEXT NOT NULL, salt TEXT NOT NULL,
      iterations INTEGER NOT NULL CHECK(iterations > 0)
    )''');
    await db.execute('''CREATE TABLE assessments (
      rater_id TEXT NOT NULL REFERENCES accounts(student_id) ON DELETE CASCADE,
      target_id TEXT NOT NULL REFERENCES accounts(student_id) ON DELETE CASCADE,
      ${ratingLabels.keys.map((k) => '$k INTEGER NOT NULL CHECK($k BETWEEN 1 AND 5)').join(', ')},
      PRIMARY KEY (rater_id, target_id),
      CHECK(rater_id <> target_id)
    )''');
    await db.execute(
      'CREATE INDEX assessments_target ON assessments(target_id)',
    );
  }
}
