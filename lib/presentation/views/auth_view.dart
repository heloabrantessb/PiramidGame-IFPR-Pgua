import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_router.dart';
import '../../domain/entity/community_entity.dart';
import '../controllers/community_viewmodel.dart';

class LoginView extends SignalStatefulWidget {
  final bool registration;
  const LoginView({super.key, this.registration = false});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  final _vm = injector.get<CommunityViewModel>();
  String? _error;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit({bool google = false}) async {
    if (_busy) return;
    if (!google &&
        widget.registration &&
        _password.text != _confirmation.text) {
      setState(() => _error = 'As senhas não coincidem.');
      return;
    }
    setState(() => _error = null);
    final credentials = LoginCredentials(_email.text, _password.text);
    final result = google
        ? await _vm.commands.loginGoogle.executeWith(null)
        : widget.registration
        ? await _vm.commands.register.executeWith(credentials)
        : await _vm.commands.login.executeWith(credentials);
    if (mounted && result.isFailure) {
      setState(() => _error = result.failureValueOrNull!.msg);
    }
  }

  bool get _busy =>
      _vm.commands.login.isExecuting.value ||
      _vm.commands.register.isExecuting.value ||
      _vm.commands.loginGoogle.isExecuting.value;

  @override
  Widget build(BuildContext context) {
    final busy = _busy;
    return PopScope(
      canPop: !busy,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.registration ? 'Criar conta' : 'PiramidGame • Entrar',
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  widget.registration
                      ? 'Sua conta no campus'
                      : 'Entre para participar do ranking',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Suas avaliações acompanham sua conta em outros aparelhos. Você pode avaliar outras pessoas, mas nunca a si mesmo.',
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
                        autofillHints: [
                          widget.registration
                              ? AutofillHints.newPassword
                              : AutofillHints.password,
                        ],
                        onSubmitted: (_) => busy ? null : _submit(),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          helperText: widget.registration
                              ? 'Entre 8 e 128 caracteres'
                              : null,
                        ),
                      ),
                      if (widget.registration) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _confirmation,
                          enabled: !busy,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Confirmar senha',
                          ),
                        ),
                      ],
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
                  onPressed: busy ? null : _submit,
                  child: Text(
                    busy
                        ? 'Aguarde…'
                        : widget.registration
                        ? 'Criar conta e entrar'
                        : 'Entrar',
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: busy ? null : () => _submit(google: true),
                  icon: const Icon(Icons.account_circle_outlined),
                  label: const Text('Entrar com Google'),
                ),
                TextButton(
                  onPressed: busy
                      ? null
                      : () => context.go(
                          widget.registration
                              ? AppPaths.login
                              : AppPaths.register,
                        ),
                  child: Text(
                    widget.registration
                        ? 'Já tenho uma conta'
                        : 'Criar minha conta',
                  ),
                ),
                TextButton(
                  onPressed: busy ? null : () => context.push(AppPaths.about),
                  child: const Text('Sobre o App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});
  @override
  Widget build(BuildContext context) => const LoginView(registration: true);
}
