import 'package:equatable/equatable.dart';

enum StudentCourses {
  info,
  mec,
  mamb,
  prod,
  tads,
  tga;

  String get displayName{
    switch (this) {
      case StudentCourses.info:
        return 'Técnico em Informática';
      case StudentCourses.mec:
        return 'Técnico em Mecânica';
      case StudentCourses.mamb:
        return 'Técnico em Meio Ambiente';
      case StudentCourses.prod:
        return 'Técnico em Produção Cultural';
      case StudentCourses.tads:
        return 'Tecnólogo em Análise e Desenvolvimento de Sistemas';
      case StudentCourses.tga:
        return 'Tecnólogo em Gestão Ambiental';
    }
  }

  String get displayOptionsName{
    switch (this) {
      case StudentCourses.info:
        return 'INFO';
      case StudentCourses.mec:
        return 'MEC';
      case StudentCourses.mamb:
        return 'MAMB';
      case StudentCourses.prod:
        return 'PROD';
      case StudentCourses.tads:
        return 'TADS';
      case StudentCourses.tga:
        return 'TGA';
    }
  }
}

class PopularityRatings extends Equatable {
  final int resenha;
  final int presencaVip;
  final int aura;
  final int modoParceiro;
  final int carismaNatural;
  final int humorDeMilhoes;
  final int energiaDeGrupo;
  final int criatividadeCaotica;
  final int modoAtleta;
  final int talentoDePalco;
  final int dripEscolar;
  final int coracaoDeDorama;
  final int queridinhoDosProfessores;
  final int cerebroTurbo;
  final int caosControlado;

  const PopularityRatings({
    required this.resenha,
    required this.presencaVip,
    required this.aura,
    required this.modoParceiro,
    required this.carismaNatural,
    required this.humorDeMilhoes,
    required this.energiaDeGrupo,
    required this.criatividadeCaotica,
    required this.modoAtleta,
    required this.talentoDePalco,
    required this.dripEscolar,
    required this.coracaoDeDorama,
    required this.queridinhoDosProfessores,
    required this.cerebroTurbo,
    required this.caosControlado,
  })  : assert(resenha >= 1 && resenha <= 5),
        assert(presencaVip >= 1 && presencaVip <= 5),
        assert(aura >= 1 && aura <= 5),
        assert(modoParceiro >= 1 && modoParceiro <= 5),
        assert(carismaNatural >= 1 && carismaNatural <= 5),
        assert(humorDeMilhoes >= 1 && humorDeMilhoes <= 5),
        assert(energiaDeGrupo >= 1 && energiaDeGrupo <= 5),
        assert(criatividadeCaotica >= 1 && criatividadeCaotica <= 5),
        assert(modoAtleta >= 1 && modoAtleta <= 5),
        assert(talentoDePalco >= 1 && talentoDePalco <= 5),
        assert(dripEscolar >= 1 && dripEscolar <= 5),
        assert(coracaoDeDorama >= 1 && coracaoDeDorama <= 5),
        assert(queridinhoDosProfessores >= 1 && queridinhoDosProfessores <= 5),
        assert(cerebroTurbo >= 1 && cerebroTurbo <= 5),
        assert(caosControlado >= 1 && caosControlado <= 5);

  const PopularityRatings.empty()
      : resenha = 1,
        presencaVip = 1,
        aura = 1,
        modoParceiro = 1,
        carismaNatural = 1,
        humorDeMilhoes = 1,
        energiaDeGrupo = 1,
        criatividadeCaotica = 1,
        modoAtleta = 1,
        talentoDePalco = 1,
        dripEscolar = 1,
        coracaoDeDorama = 1,
        queridinhoDosProfessores = 1,
        cerebroTurbo = 1,
        caosControlado = 1;

  int get nivelLenda =>
      resenha +
      presencaVip +
      aura +
      modoParceiro +
      carismaNatural +
      humorDeMilhoes +
      energiaDeGrupo +
      criatividadeCaotica +
      modoAtleta +
      talentoDePalco +
      dripEscolar +
      coracaoDeDorama +
      queridinhoDosProfessores +
      cerebroTurbo +
      caosControlado;

  @override
  List<Object?> get props => [
        resenha,
        presencaVip,
        aura,
        modoParceiro,
        carismaNatural,
        humorDeMilhoes,
        energiaDeGrupo,
        criatividadeCaotica,
        modoAtleta,
        talentoDePalco,
        dripEscolar,
        coracaoDeDorama,
        queridinhoDosProfessores,
        cerebroTurbo,
        caosControlado,
      ];
}

class Student extends Equatable {
  final String id;
  final String nome;
  final StudentCourses curso;
  final int ano;
  final String apelido;
  final DateTime data_nascimento;
  final PopularityRatings ratings;

  const Student({
    required this.id,
    required this.nome,
    required this.curso,
    required this.ano,
    required this.apelido,
    required this.data_nascimento,
    required this.ratings,
  });

  Student copyWith({
    String? id,
    String? nome,
    StudentCourses? curso,
    int? ano,
    String? apelido,
    DateTime? data_nascimento,
    PopularityRatings? ratings,
  }) {
    return Student(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      curso: curso ?? this.curso,
      ano: ano ?? this.ano,
      apelido: apelido ?? this.apelido,
      data_nascimento: data_nascimento ?? this.data_nascimento,
      ratings: ratings ?? this.ratings,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        curso,
        ano,
        apelido,
        data_nascimento,
        ratings,
      ];
}