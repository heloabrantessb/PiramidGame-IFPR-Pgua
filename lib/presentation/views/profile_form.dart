import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/di/dependency_injection.dart';
import '../controllers/community_commands_viewmodel.dart';
import '../../domain/entity/student_entity.dart';
import '../controllers/community_viewmodel.dart';

class ProfileForm extends SignalStatefulWidget {
  final Student? initial;
  final bool initiallyLinked;
  final bool canLink;
  const ProfileForm({
    super.key,
    this.initial,
    this.initiallyLinked = false,
    this.canLink = true,
  });
  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _form = GlobalKey<FormState>();
  final _vm = injector.get<CommunityViewModel>();
  late final _name = TextEditingController(text: widget.initial?.nome);
  late final _nickname = TextEditingController(text: widget.initial?.apelido);
  late bool _linkToSelf = widget.initiallyLinked;
  late StudentCourses _course = widget.initial?.curso ?? StudentCourses.info;
  late int _year = widget.initial?.ano ?? 2026;
  late DateTime? _birth = widget.initial?.data_nascimento;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _nickname]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_saving || _vm.commands.saveProfile.isExecuting.value) {
      return;
    }
    if (!_form.currentState!.validate()) return;
    if (_birth == null) {
      setState(() => _error = 'Selecione a data de nascimento.');
      return;
    }
    setState(() {
      _error = null;
      _saving = true;
    });
    final profile = Student(
      id: widget.initial?.id ?? '',
      nome: _name.text.trim(),
      apelido: _nickname.text.trim(),
      curso: _course,
      ano: _year,
      data_nascimento: _birth!,
      ratings: widget.initial?.ratings ?? const PopularityRatings.empty(),
    );
    final result = await _vm.commands.saveProfile.executeWith(
      ProfileSubmission(
        profile,
        create: widget.initial == null,
        linkToSelf: _linkToSelf,
      ),
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
    final busy = _vm.commands.saveProfile.isExecuting.value || _saving;
    return PopScope(
      canPop: !busy,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  widget.initial == null ? 'Cadastrar pessoa' : 'Editar pessoa',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Cadastrar uma pessoa não cria uma conta de acesso. As avaliações são independentes do cadastro.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _name,
                  enabled: !busy,
                  decoration: const InputDecoration(labelText: 'Nome *'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Informe seu nome.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nickname,
                  enabled: !busy,
                  decoration: const InputDecoration(labelText: 'Apelido'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<StudentCourses>(
                  initialValue: _course,
                  decoration: const InputDecoration(labelText: 'Curso'),
                  items: StudentCourses.values
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.displayOptionsName),
                        ),
                      )
                      .toList(),
                  onChanged: busy ? null : (c) => setState(() => _course = c!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _year,
                  decoration: const InputDecoration(labelText: 'Turma/ano'),
                  items: List.generate(29, (i) => 1998 + i)
                      .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                      .toList(),
                  onChanged: busy ? null : (y) => setState(() => _year = y!),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    _birth == null
                        ? 'Selecionar nascimento *'
                        : 'Nascimento: ${_birth!.day}/${_birth!.month}/${_birth!.year}',
                  ),
                  onPressed: busy
                      ? null
                      : () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _birth ?? DateTime(2005),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null && mounted) {
                            setState(() => _birth = date);
                          }
                        },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Este é meu perfil'),
                  subtitle: const Text(
                    'Vincula esta pessoa à sua conta e bloqueia a autoavaliação.',
                  ),
                  value: _linkToSelf,
                  onChanged:
                      busy ||
                          !widget.canLink ||
                          widget.initiallyLinked ||
                          (_vm.state.session.value?.studentId != null &&
                              _vm.state.session.value?.studentId !=
                                  widget.initial?.id)
                      ? null
                      : (value) => setState(() => _linkToSelf = value ?? false),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: busy ? null : _save,
                  child: Text(busy ? 'Salvando…' : 'Salvar pessoa'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
