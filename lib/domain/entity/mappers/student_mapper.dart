import '../student_entity.dart';

class StudentMapper {
  static Map<String, dynamic> toMap(Student student) {
    return {
      'id': student.id,
      'nome': student.nome,
      'curso': student.curso.name,
      'ano': student.ano,
      'apelido': student.apelido,
      'data_nascimento': student.data_nascimento.toIso8601String(),
      'avaliacoes': _ratingsToMap(student.ratings),
    };
  }

  static Student fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as String,
      nome: map['nome'] as String,
      curso: StudentCourses.values.byName(map['curso'] as String),
      ano: map['ano'] as int,
      apelido: map['apelido'] as String,
      data_nascimento: DateTime.parse(map['data_nascimento'] as String),
      ratings: _ratingsFromMap(map['avaliacoes'] as Map<String, dynamic>),
    );
  }

  static Map<String, dynamic> _ratingsToMap(PopularityRatings ratings) {
    return {
      'resenha': ratings.resenha,
      'presencaVip': ratings.presencaVip,
      'aura': ratings.aura,
      'modoParceiro': ratings.modoParceiro,
      'carismaNatural': ratings.carismaNatural,
      'humorDeMilhoes': ratings.humorDeMilhoes,
      'energiaDeGrupo': ratings.energiaDeGrupo,
      'criatividadeCaotica': ratings.criatividadeCaotica,
      'modoAtleta': ratings.modoAtleta,
      'talentoDePalco': ratings.talentoDePalco,
      'dripEscolar': ratings.dripEscolar,
      'coracaoDeDorama': ratings.coracaoDeDorama,
      'queridinhoDosProfessores': ratings.queridinhoDosProfessores,
      'cerebroTurbo': ratings.cerebroTurbo,
      'caosControlado': ratings.caosControlado,
    };
  }

  static PopularityRatings _ratingsFromMap(Map<String, dynamic> map) {
    return PopularityRatings(
      resenha: map['resenha'] as int,
      presencaVip: map['presencaVip'] as int,
      aura: map['aura'] as int,
      modoParceiro: map['modoParceiro'] as int,
      carismaNatural: map['carismaNatural'] as int,
      humorDeMilhoes: map['humorDeMilhoes'] as int,
      energiaDeGrupo: map['energiaDeGrupo'] as int,
      criatividadeCaotica: map['criatividadeCaotica'] as int,
      modoAtleta: map['modoAtleta'] as int,
      talentoDePalco: map['talentoDePalco'] as int,
      dripEscolar: map['dripEscolar'] as int,
      coracaoDeDorama: map['coracaoDeDorama'] as int,
      queridinhoDosProfessores: map['queridinhoDosProfessores'] as int,
      cerebroTurbo: map['cerebroTurbo'] as int,
      caosControlado: map['caosControlado'] as int,
    );
  }
}
