import 'package:sqflite/sqflite.dart';
import '../../domain/entity/community_entity.dart';
import '../../domain/entity/student_entity.dart';
import '../../domain/entity/mappers/student_mapper.dart';
import '../security/password_hasher.dart';

class CommunitySqliteService {
  final Future<Database> Function() openDatabase;
  CommunitySqliteService(this.openDatabase);

  Future<void> register(
    Registration registration,
    PasswordDigest password,
  ) async {
    final db = await openDatabase();
    await db.transaction((txn) async {
      await txn.insert(
        'students',
        StudentMapper.toSqliteMap(registration.profile),
      );
      await txn.insert('accounts', {
        'student_id': registration.profile.id,
        'email': registration.email,
        'password_hash': password.hash,
        'salt': password.salt,
        'iterations': password.iterations,
      });
    });
  }

  Future<Map<String, Object?>?> credentials(String email) async {
    final db = await openDatabase();
    final rows = await db.query(
      'accounts',
      where: 'email = ?',
      whereArgs: [email],
    );
    return rows.isEmpty ? null : rows.single;
  }

  Future<List<CommunityMember>> members() async {
    final db = await openDatabase();
    final sum = ratingLabels.keys.map((k) => 'a.$k').join(' + ');
    final averages = ratingLabels.keys
        .map((k) => 'AVG(a.$k) AS average_$k')
        .join(', ');
    final rows = await db.rawQuery('''SELECT s.*, $averages,
      COUNT(a.rater_id) AS assessment_count, AVG($sum) AS score
      FROM students s INNER JOIN accounts u ON u.student_id = s.id
      LEFT JOIN assessments a ON a.target_id = s.id GROUP BY s.id''');
    return rows
        .map(
          (row) => CommunityMember(
            StudentMapper.fromSqliteMap(row),
            row['assessment_count'] as int,
            (row['score'] as num?)?.toDouble(),
            {
              for (final k in ratingLabels.keys)
                if (row['average_$k'] != null)
                  k: (row['average_$k'] as num).toDouble(),
            },
          ),
        )
        .toList();
  }

  Future<void> deleteAccount(String studentId) async {
    final db = await openDatabase();
    final count = await db.delete(
      'students',
      where: 'id = ? AND EXISTS (SELECT 1 FROM accounts WHERE student_id = ?)',
      whereArgs: [studentId, studentId],
    );
    if (count != 1) throw StateError('Conta não encontrada.');
  }

  Future<void> updateProfile(Student profile) async {
    final db = await openDatabase();
    // Perfil e notas recebidas são independentes.
    final values = StudentMapper.toSqliteMap(profile)
      ..remove('id')
      ..removeWhere((key, _) => ratingLabels.containsKey(key));
    final count = await db.update(
      'students',
      values,
      where: 'id = ? AND EXISTS (SELECT 1 FROM accounts WHERE student_id = ?)',
      whereArgs: [profile.id, profile.id],
    );
    if (count != 1) throw StateError('Perfil não encontrado.');
  }

  Future<PopularityRatings?> assessment(String actorId, String targetId) async {
    final db = await openDatabase();
    final rows = await db.query(
      'assessments',
      where: 'rater_id = ? AND target_id = ?',
      whereArgs: [actorId, targetId],
    );
    if (rows.isEmpty) return null;
    return ratingsFromValues(
      ratingLabels.keys.map((k) => rows.single[k] as int).toList(),
    );
  }

  Future<void> rate(String actorId, Assessment assessment) async {
    final db = await openDatabase();
    final values = ratingValues(assessment.ratings);
    final data = <String, Object?>{
      'rater_id': actorId,
      'target_id': assessment.targetId,
      for (var i = 0; i < values.length; i++)
        ratingLabels.keys.elementAt(i): values[i],
    };
    await db.transaction((txn) async {
      final updated = await txn.update(
        'assessments',
        data,
        where: 'rater_id = ? AND target_id = ?',
        whereArgs: [actorId, assessment.targetId],
      );
      if (updated == 0) await txn.insert('assessments', data);
    });
  }
}
