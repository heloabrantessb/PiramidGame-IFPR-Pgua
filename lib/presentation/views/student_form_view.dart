import 'package:flutter/material.dart';
import '../../core/di/dependency_injection.dart';
import '../controllers/community_viewmodel.dart';
import 'profile_form.dart';

class StudentFormView extends StatelessWidget {
  const StudentFormView({super.key});
  @override
  Widget build(BuildContext context) {
    final vm = injector.get<CommunityViewModel>();
    final ownId = vm.state.session.value?.studentId;
    final members = vm.state.members.value.where((m) => m.student.id == ownId);
    return Scaffold(
      appBar: AppBar(title: const Text('Editar meu perfil')),
      body: members.isEmpty
          ? const Center(
              child: Text('Perfil não disponível. Volte e recarregue a lista.'),
            )
          : ProfileForm(initial: members.first.student),
    );
  }
}
