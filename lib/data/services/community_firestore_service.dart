import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/failure/failure.dart';
import '../../domain/entity/community_entity.dart';
import '../../domain/entity/student_entity.dart';

class CommunityFirestoreService {
  final FirebaseFirestore db;
  final FirebaseAuth auth;
  CommunityFirestoreService(this.db, this.auth);
  CollectionReference<Map<String, dynamic>> get people =>
      db.collection('pessoas');
  CollectionReference<Map<String, dynamic>> get votes =>
      db.collection('avaliacoes');
  CollectionReference<Map<String, dynamic>> get users =>
      db.collection('usuarios');

  String get actorUid {
    final user = auth.currentUser;
    if (user == null) throw InputFailure('Entre na sua conta para continuar.');
    return user.uid;
  }

  Future<AccountSession> account(User user) async {
    final ref = users.doc(user.uid);
    return db.runTransaction((txn) async {
      final existing = await txn.get(ref);
      final metadata = <String, dynamic>{
        'nome': user.displayName ?? '',
        'email': user.email ?? '',
        'foto': user.photoURL,
        'provider': user.providerData.isEmpty
            ? 'password'
            : user.providerData.first.providerId,
      };
      if (!existing.exists) metadata['pessoaId'] = null;
      txn.set(ref, metadata, SetOptions(merge: true));
      return AccountSession(
        user.uid,
        user.email ?? '',
        studentId: existing.data()?['pessoaId'] as String?,
      );
    });
  }

  Future<List<CommunityMember>> members() async {
    final uid = actorUid;
    final peopleSnapshot = await people.get();
    final votesSnapshot = await votes.get();
    final byPerson =
        <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};
    for (final doc in votesSnapshot.docs) {
      final id = doc.data()['pessoaId'] as String;
      (byPerson[id] ??= []).add(doc);
    }
    return peopleSnapshot.docs.map((doc) {
      final data = doc.data();
      final ratings = byPerson[doc.id] ?? [];
      final received = ratings.map((v) => _ratings(v.data())).toList();
      final personal = ratings.where((v) => v.data()['avaliadorUid'] == uid);
      final mine = personal.isEmpty ? null : personal.single.data();
      final averages = <String, double>{};
      if (received.isNotEmpty) {
        for (var i = 0; i < ratingLabels.length; i++) {
          averages[ratingLabels.keys.elementAt(i)] =
              received.fold<int>(
                0,
                (subtotal, r) => subtotal + ratingValues(r)[i],
              ) /
              received.length;
        }
      }
      return CommunityMember(
        Student(
          id: doc.id,
          nome: data['nome'] as String,
          apelido: data['apelido'] as String,
          curso: StudentCourses.values.byName(data['curso'] as String),
          ano: data['turma'] as int,
          data_nascimento: (data['dataNascimento'] as Timestamp)
              .toDate()
              .toUtc(),
          ratings: const PopularityRatings.empty(),
        ),
        received.length,
        received.isEmpty
            ? null
            : received.fold<int>(0, (subtotal, r) => subtotal + r.nivelLenda) /
                  received.length,
        averages,
        data['criadoPor'] as String,
        data['usuarioUid'] as String?,
        mine == null ? null : _ratings(mine),
        (mine?['dataAvaliacao'] as Timestamp?)?.toDate(),
      );
    }).toList();
  }

  Future<void> saveProfile(
    Student profile, {
    required bool create,
    required bool linkToSelf,
  }) async {
    final uid = actorUid;
    final ref = create ? people.doc() : people.doc(profile.id);
    final userRef = users.doc(uid);
    final voteRef = votes.doc('${uid}_${ref.id}');
    await db.runTransaction((txn) async {
      final user = await txn.get(userRef);
      final existing = await txn.get(ref);
      final ownVote = linkToSelf ? await txn.get(voteRef) : null;
      if (!create &&
          (!existing.exists || existing.data()?['criadoPor'] != uid)) {
        throw InputFailure('Você só pode editar pessoas cadastradas por você.');
      }
      final personId = user.data()?['pessoaId'];
      if (linkToSelf && personId != null && personId != ref.id) {
        throw InputFailure('Sua conta já está vinculada a outra pessoa.');
      }
      final linkedUid = existing.data()?['usuarioUid'] as String?;
      if (linkToSelf && linkedUid != null && linkedUid != uid) {
        throw InputFailure('Esta pessoa já está vinculada a outra conta.');
      }
      txn.set(ref, {
        'nome': profile.nome.trim(),
        'apelido': profile.apelido.trim(),
        'curso': profile.curso.name,
        'turma': profile.ano,
        'dataNascimento': Timestamp.fromDate(
          DateTime.utc(
            profile.data_nascimento.year,
            profile.data_nascimento.month,
            profile.data_nascimento.day,
          ),
        ),
        'criadoPor': create ? uid : existing.data()!['criadoPor'],
        'usuarioUid': linkToSelf ? uid : linkedUid,
      });
      if (linkToSelf) {
        txn.update(userRef, {'pessoaId': ref.id});
        // Um vínculo posterior também remove um eventual voto anterior do usuário.
        if (ownVote?.exists ?? false) txn.delete(voteRef);
      }
    });
  }

  Future<void> linkProfile(String personId) async {
    final uid = actorUid;
    final personRef = people.doc(personId);
    final userRef = users.doc(uid);
    final voteRef = votes.doc('${uid}_$personId');
    await db.runTransaction((txn) async {
      final person = await txn.get(personRef);
      final user = await txn.get(userRef);
      final oldVote = await txn.get(voteRef);
      if (!person.exists) throw InputFailure('Pessoa não encontrada.');
      if (person.data()?['usuarioUid'] != null ||
          user.data()?['pessoaId'] != null) {
        throw InputFailure('A pessoa ou sua conta já possui um vínculo.');
      }
      txn.update(personRef, {'usuarioUid': uid});
      txn.update(userRef, {'pessoaId': personId});
      if (oldVote.exists) txn.delete(voteRef);
    });
  }

  Future<void> deleteProfile(String personId) async {
    final uid = actorUid;
    final ref = people.doc(personId);
    await db.runTransaction((txn) async {
      final person = await txn.get(ref);
      if (!person.exists || person.data()?['criadoPor'] != uid) {
        throw InputFailure(
          'Você só pode remover pessoas cadastradas por você.',
        );
      }
      txn.delete(ref);
      final linked = person.data()?['usuarioUid'] as String?;
      if (linked != null) txn.update(users.doc(linked), {'pessoaId': null});
      // Votos históricos sem pessoa não entram nas listagens nem nos rankings.
    });
  }

  Future<PopularityRatings?> assessment(String actor, String targetId) async {
    if (actor != actorUid) throw InputFailure('Usuário avaliador inválido.');
    final vote = await votes.doc('${actor}_$targetId').get();
    return vote.exists ? _ratings(vote.data()!) : null;
  }

  Future<void> rate(String actor, Assessment assessment) async {
    if (actor != actorUid) throw InputFailure('Usuário avaliador inválido.');
    final ref = people.doc(assessment.targetId);
    final voteRef = votes.doc('${actor}_${assessment.targetId}');
    await db.runTransaction((txn) async {
      final person = await txn.get(ref);
      if (!person.exists) throw InputFailure('Pessoa não encontrada.');
      if (person.data()?['usuarioUid'] == actor) {
        throw InputFailure('Você não pode avaliar a si mesmo.');
      }
      final values = ratingValues(assessment.ratings);
      if (values.any((v) => v < 1 || v > 5)) {
        throw InputFailure('Informe notas entre 1 e 5.');
      }
      txn.set(voteRef, {
        'avaliadorUid': actor,
        'pessoaId': assessment.targetId,
        for (var i = 0; i < values.length; i++)
          ratingLabels.keys.elementAt(i): values[i],
        'pontuacaoTotal': assessment.ratings.nivelLenda,
        'dataAvaliacao': FieldValue.serverTimestamp(),
      });
    });
  }

  PopularityRatings _ratings(Map<String, dynamic> data) =>
      ratingsFromValues(ratingLabels.keys.map((k) => data[k] as int).toList());
}
