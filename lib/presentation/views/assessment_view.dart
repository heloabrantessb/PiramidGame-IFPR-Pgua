import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/di/dependency_injection.dart';
import '../../domain/entity/community_entity.dart';
import '../controllers/community_viewmodel.dart';

class AssessmentView extends SignalStatefulWidget {
  final String targetId;
  const AssessmentView({super.key, required this.targetId});
  @override
  State<AssessmentView> createState() => _AssessmentViewState();
}

class _AssessmentViewState extends State<AssessmentView> {
  final _vm = injector.get<CommunityViewModel>();
  List<int> _values = List.filled(15, 1);
  bool _loading = true;
  bool _loadFailed = false;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    if (_vm.state.members.value.isEmpty) {
      final members = await _vm.commands.loadMembers.executeWith(null);
      if (!mounted) return;
      if (members.isFailure) {
        setState(() {
          _loading = false;
          _loadFailed = true;
          _error = members.failureValueOrNull!.msg;
        });
        return;
      }
    }
    final result = await _vm.commands.loadAssessment.executeWith(
      widget.targetId,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _loadFailed = result.isFailure;
      if (result.isFailure) {
        _error = result.failureValueOrNull!.msg;
      } else if (result.successValueOrNull != null) {
        _values = ratingValues(result.successValueOrNull!);
      }
    });
  }

  Future<void> _save() async {
    if (_saving || _vm.commands.rate.isExecuting.value) return;
    setState(() {
      _error = null;
      _saving = true;
    });
    final result = await _vm.commands.rate.executeWith(
      Assessment(widget.targetId, ratingsFromValues(_values)),
    );
    if (!mounted) return;
    if (result.isFailure) {
      setState(() {
        _error = result.failureValueOrNull!.msg;
        _saving = false;
      });
      return;
    }
    await _vm.commands.loadMembers.executeWith(null);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final busy = _vm.commands.rate.isExecuting.value || _saving;
    final members = _vm.state.members.value.where(
      (m) => m.student.id == widget.targetId,
    );
    final self =
        widget.targetId == _vm.state.session.value?.studentId ||
        members.any((m) => m.linkedUserId == _vm.state.session.value?.uid);
    final available = !self && members.isNotEmpty;
    return PopScope(
      canPop: !busy,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            available
                ? 'Avaliar ${members.first.student.nome}'
                : 'Avaliação indisponível',
          ),
        ),
        body: !available
            ? const Center(
                child: Text('Você só pode avaliar outras pessoas cadastradas.'),
              )
            : _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text(
                    'Uma avaliação por pessoa. Ao salvar novamente, suas notas anteriores são substituídas.',
                  ),
                  const SizedBox(height: 16),
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    TextButton(
                      onPressed: busy ? null : _load,
                      child: const Text('Recarregar avaliação'),
                    ),
                  ],
                  if (!_loadFailed) ...[
                    for (var i = 0; i < ratingLabels.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ratingLabels.values.elementAt(i)),
                            Wrap(
                              children: List.generate(
                                5,
                                (star) => IconButton(
                                  tooltip:
                                      '${star + 1} estrela${star == 0 ? '' : 's'}',
                                  onPressed: busy
                                      ? null
                                      : () => setState(
                                          () => _values[i] = star + 1,
                                        ),
                                  icon: Icon(
                                    star < _values[i]
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      'Total desta avaliação: ${_values.fold(0, (a, b) => a + b)} / 75',
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: busy ? null : _save,
                      child: Text(busy ? 'Salvando…' : 'Salvar avaliação'),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
