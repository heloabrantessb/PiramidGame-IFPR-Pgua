import 'student_entity.dart';

class AccountSession {
  final String uid;
  final String email;
  final String? studentId;
  const AccountSession(this.uid, this.email, {this.studentId});
}

class CommunityMember {
  final Student student;
  final int assessmentCount;
  final double? score;
  final String createdBy;
  final String? linkedUserId;
  final PopularityRatings? personalRatings;
  final DateTime? assessmentDate;
  final Map<String, double> averageRatings;
  const CommunityMember(
    this.student,
    this.assessmentCount,
    this.score, [
    this.averageRatings = const {},
    this.createdBy = '',
    this.linkedUserId,
    this.personalRatings,
    this.assessmentDate,
  ]);
}

class Registration {
  final Student profile;
  final String email;
  final String password;
  const Registration(this.profile, this.email, this.password);
}

class LoginCredentials {
  final String email;
  final String password;
  const LoginCredentials(this.email, this.password);
}

class Assessment {
  final String targetId;
  final PopularityRatings ratings;
  const Assessment(this.targetId, this.ratings);
}

// Ordem compartilhada pelo armazenamento e pelos componentes de avaliação.
const ratingLabels = <String, String>{
  'resenha': 'Resenha',
  'presencaVip': 'Presença VIP',
  'aura': 'Aura',
  'modoParceiro': 'Modo Parceiro',
  'carismaNatural': 'Carisma Natural',
  'humorDeMilhoes': 'Humor de Milhões',
  'energiaDeGrupo': 'Energia de Grupo',
  'criatividadeCaotica': 'Criatividade Caótica',
  'modoAtleta': 'Modo Atleta',
  'talentoDePalco': 'Talento de Palco',
  'dripEscolar': 'Drip Escolar',
  'coracaoDeDorama': 'Coração de Dorama',
  'queridinhoDosProfessores': 'Queridinho dos Professores',
  'cerebroTurbo': 'Cérebro Turbo',
  'caosControlado': 'Caos Controlado',
};

List<int> ratingValues(PopularityRatings r) => [
  r.resenha,
  r.presencaVip,
  r.aura,
  r.modoParceiro,
  r.carismaNatural,
  r.humorDeMilhoes,
  r.energiaDeGrupo,
  r.criatividadeCaotica,
  r.modoAtleta,
  r.talentoDePalco,
  r.dripEscolar,
  r.coracaoDeDorama,
  r.queridinhoDosProfessores,
  r.cerebroTurbo,
  r.caosControlado,
];

PopularityRatings ratingsFromValues(List<int> v) {
  if (v.length != 15 || v.any((n) => n < 1 || n > 5)) {
    throw ArgumentError('Informe 15 notas entre 1 e 5.');
  }
  return PopularityRatings(
    resenha: v[0],
    presencaVip: v[1],
    aura: v[2],
    modoParceiro: v[3],
    carismaNatural: v[4],
    humorDeMilhoes: v[5],
    energiaDeGrupo: v[6],
    criatividadeCaotica: v[7],
    modoAtleta: v[8],
    talentoDePalco: v[9],
    dripEscolar: v[10],
    coracaoDeDorama: v[11],
    queridinhoDosProfessores: v[12],
    cerebroTurbo: v[13],
    caosControlado: v[14],
  );
}
