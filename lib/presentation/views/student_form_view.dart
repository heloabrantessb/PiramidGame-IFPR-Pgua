import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/di/dependency_injection.dart';
import '../controllers/community_viewmodel.dart';
import 'profile_form.dart';

class StudentFormView extends SignalStatefulWidget {
  final String? personId;
  const StudentFormView({super.key, this.personId});
  @override
  State<StudentFormView> createState() => _StudentFormViewState();
}

class _StudentFormViewState extends State<StudentFormView> {
  final _vm = injector.get<CommunityViewModel>();
  String? _error;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    if (widget.personId != null && _vm.state.members.value.isEmpty) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await _vm.commands.loadMembers.executeWith(null);
    if (mounted) {
      setState(() {
        _loading = false;
        _error = result.failureValueOrNull?.msg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.personId != null;
    final matches = _vm.state.members.value.where(
      (m) => m.student.id == widget.personId,
    );
    final member = matches.isEmpty ? null : matches.first;
    final allowed =
        !editing || member?.createdBy == _vm.state.session.value?.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Editar pessoa' : 'Cadastrar pessoa'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !allowed || _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error ?? 'Pessoa indisponível para edição.'),
                  if (_error != null)
                    TextButton(
                      onPressed: _load,
                      child: const Text('Tentar novamente'),
                    ),
                ],
              ),
            )
          : ProfileForm(
              initial: member?.student,
              canLink: member?.linkedUserId == null,
              initiallyLinked:
                  member?.linkedUserId == _vm.state.session.value?.uid,
            ),
    );
  }
}
