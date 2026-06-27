import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/theme_controller.dart';
import '../../domain/entity/student_entity.dart';
import '../controllers/student_state_viewmodel.dart';
import '../controllers/student_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  late final StudentViewModel _viewModel;
  late final ThemeController _themeController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _viewModel = injector.get<StudentViewModel>();
    _themeController = injector.get<ThemeController>();
    _tabController = TabController(length: 2, vsync: this);

    // Dispara a busca inicial de estudantes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.commands.fetchStudents();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Registra observers para mostrar snackbars de sucesso e erro
    _setupEffectObservers(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PiramidGame IFPR'),
        actions: [
          // Alternador de Tema Claro/Escuro reativo
          IconButton(
            icon: Icon(
              _themeController.isLightMode.watch(context)
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
            ),
            tooltip: 'Alternar Tema',
            onPressed: () => _themeController.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Sobre o App',
            onPressed: () => context.push(AppPaths.about),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
          tabs: const [
            Tab(
              icon: Icon(Icons.emoji_events_rounded),
              text: 'Ranking Geral',
            ),
            Tab(
              icon: Icon(Icons.people_alt_rounded),
              text: 'Alunos',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRankingTab(context),
          _buildStudentsTab(context),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppPaths.studentForm, extra: null),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Cadastrar Aluno'),
      ),
    );
  }

  // Configura observadores reativos (effects) para escutar eventos globais de sucesso e erro
  void _setupEffectObservers(BuildContext context) {
    // Observer para mensagens de erro
    effect(() {
      final msg = _viewModel.state.message.value;
      if (msg != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          _viewModel.state.clearMessage();
        });
      }
    });

    // Observer para eventos de sucesso
    effect(() {
      final success = _viewModel.state.successEvent.value;
      if (success != null) {
        String msg = '';
        switch (success) {
          case StudentSuccessEvent.created:
            msg = 'Estudante cadastrado com sucesso!';
            break;
          case StudentSuccessEvent.updated:
            msg = 'Estudante atualizado com sucesso!';
            break;
          case StudentSuccessEvent.deleted:
            msg = 'Estudante removido com sucesso!';
            break;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          _viewModel.state.clearSuccessEvent();
        });
      }
    });
  }

  // --- ABA DE RANKING ---
  Widget _buildRankingTab(BuildContext context) {
    final ranking = _viewModel.state.ranking.watch(context);
    final theme = Theme.of(context);

    if (ranking.isEmpty) {
      return _buildEmptyState(context, 'Nenhum aluno no topo do Olimpo ainda.\nCadastre o primeiro para ver o ranking!');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: ranking.length,
      itemBuilder: (context, index) {
        final student = ranking[index];
        final isPodium = index < 3;
        
        Color podiumColor = theme.colorScheme.surfaceVariant;
        Widget? podiumBadge;

        if (index == 0) {
          podiumColor = const Color(0xFFFFD700).withOpacity(0.15); // Ouro
          podiumBadge = const Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 28);
        } else if (index == 1) {
          podiumColor = const Color(0xFFC0C0C0).withOpacity(0.15); // Prata
          podiumBadge = const Icon(Icons.workspace_premium, color: Color(0xFFC0C0C0), size: 28);
        } else if (index == 2) {
          podiumColor = const Color(0xFFCD7F32).withOpacity(0.15); // Bronze
          podiumBadge = const Icon(Icons.workspace_premium, color: Color(0xFFCD7F32), size: 28);
        }

        return Card(
          elevation: isPodium ? 2 : 0,
          color: isPodium ? podiumColor : theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isPodium 
                  ? theme.colorScheme.primary.withOpacity(0.3) 
                  : theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: SizedBox(
              width: 40,
              child: Center(
                child: podiumBadge ?? Text(
                  '${index + 1}º',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            title: Text(
              student.nome,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${student.curso.displayOptionsName} • Turma ${student.ano}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${student.ratings.nivelLenda} pts',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'Nível Lenda',
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.secondary),
                ),
              ],
            ),
            onTap: () => _showStudentDetails(context, student),
          ),
        );
      },
    );
  }

  // --- ABA DE ALUNOS ---
  Widget _buildStudentsTab(BuildContext context) {
    final students = _viewModel.state.students.watch(context);
    final theme = Theme.of(context);

    if (students.isEmpty) {
      return _buildEmptyState(context, 'Nenhum estudante cadastrado no campus.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.12)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              student.nome,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (student.apelido.isNotEmpty)
                  Text(
                    '"${student.apelido}"',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                const SizedBox(height: 2),
                Text('${student.curso.displayName} • ${student.ano}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                  onPressed: () => context.push(AppPaths.studentForm, extra: student),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                  onPressed: () => _confirmDelete(context, student),
                ),
              ],
            ),
            onTap: () => _showStudentDetails(context, student),
          ),
        );
      },
    );
  }

  // --- DETALHES DO ESTUDANTE (DIALOG) ---
  void _showStudentDetails(BuildContext context, Student student) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.all(16),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Text(student.nome[0].toUpperCase()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.nome,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (student.apelido.isNotEmpty)
                    Text(
                      'Vulgo: ${student.apelido}',
                      style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                    ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(),
                Text('Curso: ${student.curso.displayName}', style: theme.textTheme.bodyMedium),
                Text('Turma: Ano ${student.ano}', style: theme.textTheme.bodyMedium),
                Text('Nível Lenda Geral: ${student.ratings.nivelLenda} pontos', 
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                const SizedBox(height: 12),
                const Text('Critérios de Popularidade:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildRatingItem(context, 'Resenha', student.ratings.resenha),
                _buildRatingItem(context, 'Presença VIP', student.ratings.presencaVip),
                _buildRatingItem(context, 'Aura', student.ratings.aura),
                _buildRatingItem(context, 'Modo Parceiro', student.ratings.modoParceiro),
                _buildRatingItem(context, 'Carisma Natural', student.ratings.carismaNatural),
                _buildRatingItem(context, 'Humor de Milhões', student.ratings.humorDeMilhoes),
                _buildRatingItem(context, 'Energia de Grupo', student.ratings.energiaDeGrupo),
                _buildRatingItem(context, 'Criatividade Caótica', student.ratings.criatividadeCaotica),
                _buildRatingItem(context, 'Modo Atleta', student.ratings.modoAtleta),
                _buildRatingItem(context, 'Talento de Palco', student.ratings.talentoDePalco),
                _buildRatingItem(context, 'Drip Escolar', student.ratings.dripEscolar),
                _buildRatingItem(context, 'Coração de Dorama', student.ratings.coracaoDeDorama),
                _buildRatingItem(context, 'Queridinho dos Profs', student.ratings.queridinhoDosProfessores),
                _buildRatingItem(context, 'Cérebro Turbo', student.ratings.cerebroTurbo),
                _buildRatingItem(context, 'Caos Controlado', student.ratings.caosControlado),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingItem(BuildContext context, String label, int rating) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                Icons.star_rounded,
                size: 20,
                color: index < rating ? Colors.amber : theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CONFIRMAÇÃO DE EXCLUSÃO ---
  void _confirmDelete(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Remoção'),
        content: Text('Tem certeza que deseja remover ${student.nome} do ranking? Esta ação é irreversível.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _viewModel.commands.deleteStudent(student.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  // --- ESTADO VAZIO ---
  Widget _buildEmptyState(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline_rounded, size: 64, color: theme.colorScheme.secondary.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
