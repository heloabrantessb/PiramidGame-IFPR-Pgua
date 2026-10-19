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

  Future<void> _logout() async {
    if (_vm.commands.logout.isExecuting.value) return;
    final result = await _vm.commands.logout.executeWith(null);
    if (mounted && result.isFailure) {
      setState(() => _error = result.failureValueOrNull!.msg);
    }
  }

  bool _self(CommunityMember m) =>
      m.linkedUserId == _vm.state.session.value?.uid ||
      m.student.id == _vm.state.session.value?.studentId;

  void _details(CommunityMember member) {
    final s = member.student;
    final self = _self(member);
    final creator = member.createdBy == _vm.state.session.value?.uid;
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
                    : 'Nível Lenda Global: ${member.score!.toStringAsFixed(1)} / 75',
              ),
              Text('Avaliações recebidas: ${member.assessmentCount}'),
              for (final entry in member.averageRatings.entries)
                Text(
                  '${ratingLabels[entry.key]}: ${entry.value.toStringAsFixed(1)} / 5',
                ),
              if (member.personalRatings != null) ...[
                const Divider(),
                Text(
                  'Minha avaliação: ${member.personalRatings!.nivelLenda} / 75',
                ),
                if (member.assessmentDate != null)
                  Text(
                    'Avaliada em: ${member.assessmentDate!.day}/${member.assessmentDate!.month}/${member.assessmentDate!.year}',
                  ),
              ],
              if (self)
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
          if (member.linkedUserId == null &&
              _vm.state.session.value?.studentId == null)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _link(member);
              },
              child: const Text('Este sou eu'),
            ),
          if (creator) ...[
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.push('${AppPaths.studentForm}?id=${s.id}');
              },
              child: const Text('Editar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _remove(member);
              },
              child: const Text('Remover'),
            ),
          ],
          if (!self)
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.push('/assess/${s.id}');
              },
              child: Text(
                member.personalRatings == null
                    ? 'Avaliar'
                    : 'Alterar avaliação',
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _link(CommunityMember member) async {
    if (_vm.commands.linkProfile.isExecuting.value) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Este é seu perfil?'),
        content: Text(
          'Vincular ${member.student.nome} à sua conta? Você não poderá avaliar esta pessoa. Uma avaliação anterior feita por você será removida.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Vincular'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await _vm.commands.linkProfile.executeWith(
      member.student.id,
    );
    if (!mounted) return;
    if (result.isFailure) {
      setState(() => _error = result.failureValueOrNull!.msg);
    } else {
      await _load();
    }
  }

  Future<void> _remove(CommunityMember member) async {
    if (_vm.commands.deleteProfile.isExecuting.value) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover pessoa?'),
        content: Text(
          '${member.student.nome} será removido das listas e dos rankings. Esta ação não pode ser desfeita. A conta de acesso não será excluída.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await _vm.commands.deleteProfile.executeWith(
      member.student.id,
    );
    if (!mounted) return;
    if (result.isFailure) {
      setState(() => _error = result.failureValueOrNull!.msg);
    } else {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = _vm.state.members.value;
    final personal = _vm.state.personalRanking.value;
    final people = List<CommunityMember>.of(members)
      ..sort(
        (a, b) => a.student.nome.toLowerCase().compareTo(
          b.student.nome.toLowerCase(),
        ),
      );
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PiramidGame'),
          actions: [
            IconButton(
              tooltip: 'Alternar tema',
              onPressed: () async {
                final result = await _theme.toggleCommand.call();
                if (mounted && result.isFailure) {
                  setState(() => _error = result.failureValueOrNull!.msg);
                }
              },
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
              onPressed: _vm.commands.logout.isExecuting.value ? null : _logout,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pessoas'),
              Tab(text: 'Pessoal'),
              Tab(text: 'Global'),
            ],
          ),
        ),
        body: Column(
          children: [
            if (_vm.commands.loadMembers.isExecuting.value)
              const LinearProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(
              child: TabBarView(
                children: [
                  _list(people, kind: 'people'),
                  _list(personal, kind: 'personal'),
                  _list(members, kind: 'global'),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push(AppPaths.studentForm),
          icon: const Icon(Icons.person_add_alt),
          label: const Text('Cadastrar pessoa'),
        ),
      ),
    );
  }

  Widget _list(List<CommunityMember> members, {required String kind}) {
    final personal = kind == 'personal';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(switch (kind) {
            'personal' =>
              'Ranking pessoal: na sua opinião, quem tem o maior Nível Lenda? Somente suas avaliações são consideradas.',
            'global' =>
              'Ranking global: média das avaliações recebidas de todos os usuários, de 15 a 75 pontos.',
            _ =>
              'Pessoas disponíveis para avaliação. Elas não precisam ter uma conta de acesso.',
          }),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: members.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          personal
                              ? 'Você ainda não avaliou nenhuma pessoa.'
                              : 'Nenhuma pessoa cadastrada.',
                        ),
                      ),
                      TextButton(
                        onPressed: _load,
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
                      final self = _self(member);
                      final score = personal
                          ? member.personalRatings?.nivelLenda.toDouble()
                          : member.score;
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: kind == 'people'
                                ? const Icon(Icons.person_outline)
                                : Text(score == null ? '—' : '${index + 1}º'),
                          ),
                          title: Text(
                            '${member.student.nome}${self ? ' (você)' : ''}',
                          ),
                          subtitle: Text(
                            '${member.student.curso.displayOptionsName} • ${member.student.ano}\n'
                            '${score == null ? 'Sem avaliações' : '${score.toStringAsFixed(1)} pts${personal ? '' : ' • ${member.assessmentCount} avaliação(ões)'}'}',
                          ),
                          isThreeLine: true,
                          onTap: () => _details(member),
                          trailing: self
                              ? const Icon(Icons.person)
                              : IconButton(
                                  tooltip: 'Avaliar pessoa',
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
    );
  }
}
