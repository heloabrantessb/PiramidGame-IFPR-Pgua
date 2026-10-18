import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_router.dart';
import '../../domain/entity/community_entity.dart';
import '../controllers/community_viewmodel.dart';
import 'profile_form.dart';

class LoginView extends SignalStatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _vm = injector.get<CommunityViewModel>();
  String? _error;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_vm.commands.login.isExecuting.value) return;
    setState(() => _error = null);
    final result = await _vm.commands.login.executeWith(
      LoginCredentials(_email.text, _password.text),
    );
    if (!mounted) return;
    if (result.isFailure) {
      setState(() => _error = result.failureValueOrNull!.msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _vm.commands.login.isExecuting.value;
    return Scaffold(
      appBar: AppBar(title: const Text('PiramidGame • Entrar')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Entre para participar do ranking',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'Contas e avaliações ficam salvas apenas neste aparelho. Você pode avaliar outros usuários, mas nunca o próprio perfil.',
              ),
              const SizedBox(height: 24),
              AutofillGroup(
                child: Column(
                  children: [
                    TextField(
                      controller: _email,
                      enabled: !busy,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.username],
                      decoration: const InputDecoration(labelText: 'E-mail'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _password,
                      enabled: !busy,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => busy ? null : _login(),
                      decoration: const InputDecoration(labelText: 'Senha'),
                    ),
                  ],
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: busy ? null : _login,
                child: Text(busy ? 'Entrando…' : 'Entrar'),
              ),
              TextButton(
                onPressed: busy ? null : () => context.go(AppPaths.register),
                child: const Text('Criar minha conta'),
              ),
              TextButton(
                onPressed: busy ? null : () => context.push(AppPaths.about),
                child: const Text('Sobre o App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterView extends SignalWidget {
  const RegisterView({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Criar conta'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed:
            injector
                .get<CommunityViewModel>()
                .commands
                .register
                .isExecuting
                .value
            ? null
            : () => context.go(AppPaths.login),
      ),
    ),
    body: const ProfileForm(registration: true),
  );
}
