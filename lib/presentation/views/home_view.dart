import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/theme_controller.dart';
import '../../domain/entity/community_entity.dart';
import '../controllers/community_viewmodel.dart';

class HomeView extends SignalStatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _vm = injector.get<CommunityViewModel>();
  final _theme = injector.get<ThemeController>();
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_vm.commands.loadMembers.isExecuting.value) return;
    final result = await _vm.commands.loadMembers.executeWith(null);
    if (mounted) setState(() => _error = result.failureValueOrNull?.msg);
  }

  void _details(CommunityMember member) {
    final s = member.student;
    final own = s.id == _vm.state.session.value?.studentId;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.nome),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (s.apelido.isNotEmpty) Text('Apelido: ${s.apelido}'),
              Text('Curso: ${s.curso.displayOptionsName}'),
              Text('Turma: ${s.ano}'),
              Text(
                'Nascimento: ${s.data_nascimento.day}/${s.data_nascimento.month}/${s.data_nascimento.year}',
              ),
              Text(
                member.score == null
                    ? 'Ainda sem avaliações.'
                    : 'Nível Lenda: ${member.score!.toStringAsFixed(1)} / 75',
              ),
              Text('Avaliações recebidas: ${member.assessmentCount}'),
              for (final entry in member.averageRatings.entries)
                Text(
                  '${ratingLabels[entry.key]}: ${entry.value.toStringAsFixed(1)} / 5',
                ),
              if (own)
                const Text(
                  'Este é seu perfil. Você não pode avaliar a si mesmo.',
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
          if (own)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _deleteAccount();
              },
              child: const Text('Excluir minha conta'),
            ),
          if (!own)
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.push('/assess/${s.id}');
              },
              child: const Text('Avaliar'),
            ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    if (_vm.commands.deleteAccount.isExecuting.value) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir minha conta?'),
        content: const Text(
          'Seu perfil, suas credenciais e as avaliações feitas e recebidas serão removidos deste aparelho. Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir conta'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await _vm.commands.deleteAccount.executeWith(null);
    if (mounted && result.isFailure) {
      setState(() => _error = result.failureValueOrNull!.msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = _vm.state.members.value;
    final own = _vm.state.session.value?.studentId;
    final loading = _vm.commands.loadMembers.isExecuting.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking do campus'),
        actions: [
          IconButton(
            tooltip: 'Alternar tema',
            onPressed: _theme.toggleTheme,
            icon: Icon(
              _theme.isLightMode.value ? Icons.dark_mode : Icons.light_mode,
            ),
          ),
          IconButton(
            tooltip: 'Sobre o App',
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.push(AppPaths.about),
          ),
          IconButton(
            tooltip: 'Sair da conta',
            icon: const Icon(Icons.logout),
            onPressed: () => _vm.commands.logout.executeWith(null),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Nível Lenda = média dos totais recebidos (15 a 75). Cada conta avalia outra apenas uma vez e pode atualizar suas notas.',
            ),
          ),
          if (loading) const LinearProgressIndicator(),
          if (_error != null)
            Padding(padding: const EdgeInsets.all(12), child: Text(_error!)),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: members.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('Nenhum usuário disponível.'),
                        ),
                        TextButton(
                          onPressed: loading ? null : _load,
                          child: const Text('Recarregar'),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        final self = member.student.id == own;
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                member.score == null ? '—' : '${index + 1}º',
                              ),
                            ),
                            title: Text(
                              '${member.student.nome}${self ? ' (você)' : ''}',
                            ),
                            subtitle: Text(
                              '${member.student.curso.displayOptionsName} • ${member.student.ano}\n'
                              '${member.score == null ? 'Sem avaliações' : '${member.score!.toStringAsFixed(1)} pts • ${member.assessmentCount} avaliação(ões)'}',
                            ),
                            isThreeLine: true,
                            onTap: () => _details(member),
                            trailing: self
                                ? const Icon(Icons.person)
                                : IconButton(
                                    tooltip: 'Avaliar usuário',
                                    icon: const Icon(Icons.star_outline),
                                    onPressed: () => context.push(
                                      '/assess/${member.student.id}',
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: members.any((m) => m.student.id == own)
            ? () => context.push(AppPaths.studentForm)
            : null,
        icon: const Icon(Icons.edit),
        label: const Text('Meu perfil'),
      ),
    );
  }
}
