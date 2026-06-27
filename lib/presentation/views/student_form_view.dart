import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/dependency_injection.dart';
import '../../domain/entity/student_entity.dart';
import '../controllers/student_viewmodel.dart';

class StudentFormView extends StatefulWidget {
  final Student? initialStudent;

  const StudentFormView({super.key, this.initialStudent});

  @override
  State<StudentFormView> createState() => _StudentFormViewState();
}

class _StudentFormViewState extends State<StudentFormView> {
  late final StudentViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();

  // Campos cadastrais
  late final TextEditingController _nameController;
  late final TextEditingController _nicknameController;
  StudentCourses _selectedCourse = StudentCourses.info;
  int _selectedYear = 2026;
  DateTime? _selectedBirthDate;

  // Notas dos 15 critérios (Inicializa tudo com 1 se for cadastro novo)
  final Map<String, int> _ratings = {
    'resenha': 1,
    'presencaVip': 1,
    'aura': 1,
    'modoParceiro': 1,
    'carismaNatural': 1,
    'humorDeMilhoes': 1,
    'energiaDeGrupo': 1,
    'criatividadeCaotica': 1,
    'modoAtleta': 1,
    'talentoDePalco': 1,
    'dripEscolar': 1,
    'coracaoDeDorama': 1,
    'queridinhoDosProfessores': 1,
    'cerebroTurbo': 1,
    'caosControlado': 1,
  };

  @override
  void initState() {
    super.initState();
    _viewModel = injector.get<StudentViewModel>();

    // Inicializa os campos com valores do estudante caso seja edição
    final student = widget.initialStudent;
    if (student != null) {
      _nameController = TextEditingController(text: student.nome);
      _nicknameController = TextEditingController(text: student.apelido);
      _selectedCourse = student.curso;
      _selectedYear = student.ano;
      _selectedBirthDate = student.data_nascimento;

      // Carrega as notas salvas
      _ratings['resenha'] = student.ratings.resenha;
      _ratings['presencaVip'] = student.ratings.presencaVip;
      _ratings['aura'] = student.ratings.aura;
      _ratings['modoParceiro'] = student.ratings.modoParceiro;
      _ratings['carismaNatural'] = student.ratings.carismaNatural;
      _ratings['humorDeMilhoes'] = student.ratings.humorDeMilhoes;
      _ratings['energiaDeGrupo'] = student.ratings.energiaDeGrupo;
      _ratings['criatividadeCaotica'] = student.ratings.criatividadeCaotica;
      _ratings['modoAtleta'] = student.ratings.modoAtleta;
      _ratings['talentoDePalco'] = student.ratings.talentoDePalco;
      _ratings['dripEscolar'] = student.ratings.dripEscolar;
      _ratings['coracaoDeDorama'] = student.ratings.coracaoDeDorama;
      _ratings['queridinhoDosProfessores'] = student.ratings.queridinhoDosProfessores;
      _ratings['cerebroTurbo'] = student.ratings.cerebroTurbo;
      _ratings['caosControlado'] = student.ratings.caosControlado;
    } else {
      _nameController = TextEditingController();
      _nicknameController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  // --- COMPONENTE DATE PICKER ---
  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2005),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  // --- SUBMETER FORMULÁRIO ---
  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione a data de nascimento!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final popularityRatings = PopularityRatings(
      resenha: _ratings['resenha']!,
      presencaVip: _ratings['presencaVip']!,
      aura: _ratings['aura']!,
      modoParceiro: _ratings['modoParceiro']!,
      carismaNatural: _ratings['carismaNatural']!,
      humorDeMilhoes: _ratings['humorDeMilhoes']!,
      energiaDeGrupo: _ratings['energiaDeGrupo']!,
      criatividadeCaotica: _ratings['criatividadeCaotica']!,
      modoAtleta: _ratings['modoAtleta']!,
      talentoDePalco: _ratings['talentoDePalco']!,
      dripEscolar: _ratings['dripEscolar']!,
      coracaoDeDorama: _ratings['coracaoDeDorama']!,
      queridinhoDosProfessores: _ratings['queridinhoDosProfessores']!,
      cerebroTurbo: _ratings['cerebroTurbo']!,
      caosControlado: _ratings['caosControlado']!,
    );

    final student = Student(
      id: widget.initialStudent?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nome: _nameController.text.trim(),
      curso: _selectedCourse,
      ano: _selectedYear,
      apelido: _nicknameController.text.trim(),
      data_nascimento: _selectedBirthDate!,
      ratings: popularityRatings,
    );

    if (widget.initialStudent != null) {
      _viewModel.commands.updateStudent(student);
    } else {
      _viewModel.commands.addStudent(student);
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.initialStudent != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Aluno' : 'Cadastrar Aluno'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // CARD DE DADOS CADASTRAIS
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.12)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perfil do Aluno',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Nome
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome Completo *',
                        prefixIcon: Icon(Icons.person_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'O nome é obrigatório!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Apelido
                    TextFormField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(
                        labelText: 'Apelido (Vulgo)',
                        prefixIcon: Icon(Icons.alternate_email_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Curso & Ano (Lado a Lado)
                    Row(
                      children: [
                        // Curso
                        Expanded(
                          child: DropdownButtonFormField<StudentCourses>(
                            value: _selectedCourse,
                            decoration: const InputDecoration(
                              labelText: 'Curso',
                              border: OutlineInputBorder(),
                            ),
                            items: StudentCourses.values
                                .map((course) => DropdownMenuItem(
                                      value: course,
                                      child: Text(course.displayOptionsName),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedCourse = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Ano / Turma (1998 a 2026)
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedYear,
                            decoration: const InputDecoration(
                              labelText: 'Turma (Ano)',
                              border: OutlineInputBorder(),
                            ),
                            items: List.generate(29, (index) => 1998 + index)
                                .map((year) => DropdownMenuItem(
                                      value: year,
                                      child: Text(year.toString()),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedYear = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Data de nascimento (DatePicker)
                    InkWell(
                      onTap: () => _selectBirthDate(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_month_rounded, color: theme.colorScheme.primary),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedBirthDate == null
                                      ? 'Data de Nascimento *'
                                      : "${_selectedBirthDate!.day.toString().padLeft(2, '0')}/${_selectedBirthDate!.month.toString().padLeft(2, '0')}/${_selectedBirthDate!.year}",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: _selectedBirthDate == null 
                                        ? theme.hintColor 
                                        : theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // SEÇÃO DE CRITÉRIOS DE POPULARIDADE (STAR RATINGS)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.12)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Critérios de Popularidade (Star Rating)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Avalie o aluno de 1 a 5 estrelas em cada critério:',
                      style: theme.textTheme.bodySmall,
                    ),
                    const Divider(height: 24),
                    
                    _buildStarField('resenha', '1. Resenha'),
                    _buildStarField('presencaVip', '2. Presença VIP'),
                    _buildStarField('aura', '3. Aura'),
                    _buildStarField('modoParceiro', '4. Modo Parceiro'),
                    _buildStarField('carismaNatural', '5. Carisma Natural'),
                    _buildStarField('humorDeMilhoes', '6. Humor de Milhões'),
                    _buildStarField('energiaDeGrupo', '7. Energia de Grupo'),
                    _buildStarField('criatividadeCaotica', '8. Criatividade Caótica'),
                    _buildStarField('modoAtleta', '9. Modo Atleta'),
                    _buildStarField('talentoDePalco', '10. Talento de Palco'),
                    _buildStarField('dripEscolar', '11. Drip Escolar'),
                    _buildStarField('coracaoDeDorama', '12. Coração de Dorama'),
                    _buildStarField('queridinhoDosProfessores', '13. Queridinho dos Profs'),
                    _buildStarField('cerebroTurbo', '14. Cérebro Turbo'),
                    _buildStarField('caosControlado', '15. Caos Controlado'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // BOTÃO DE SALVAR
            ElevatedButton.icon(
              onPressed: _submitForm,
              icon: const Icon(Icons.save_rounded),
              label: Text(isEditing ? 'Salvar Alterações' : 'Confirmar Cadastro'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Helper para renderizar campo de estrela
  Widget _buildStarField(String key, String label) {
    final theme = Theme.of(context);
    final rating = _ratings[key] ?? 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Row(
            children: List.generate(
              5,
              (index) {
                final starValue = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _ratings[key] = starValue;
                    });
                  },
                  child: Icon(
                    Icons.star_rounded,
                    size: 28,
                    color: starValue <= rating ? Colors.amber : theme.colorScheme.outline.withOpacity(0.3),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
