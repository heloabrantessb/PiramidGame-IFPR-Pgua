enum StudentCourses {
  info,
  mec,
  mamb,
  prod,
  tads,
  tga,
}

class StudentEntity {
  final String id;
  final String nome;
  final StudentCourses curso;
  final int ano;
  final String apelido;
  final DateTime data_nascimento;

  StudentEntity({
    required this.id,
    required this.nome,
    required this.curso,
    required this.ano,
    required this.apelido,
    required this.data_nascimento,
  });
}