import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'core/di/dependency_injection.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      throw UnsupportedError(
        'Este aplicativo está disponível para Android e iOS. '
        'Abra em um celular ou emulador compatível.',
      );
    }
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    setupDependencyInjection();
    await injector.get<ThemeController>().restore();
    runApp(const MyApp());
  } catch (error, stack) {
    debugPrint('Falha na inicialização: $error\n$stack');
    runApp(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error is UnsupportedError
                        ? error.message ?? 'Plataforma não suportada.'
                        : 'Não foi possível iniciar o aplicativo. '
                              'Verifique a configuração do Firebase e tente novamente.',
                    textAlign: TextAlign.center,
                  ),
                  if (error is! UnsupportedError) ...[
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: main,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends SignalWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'PiramidGame IFPR-Pgua',
    debugShowCheckedModeBanner: false,
    routerConfig: AppRouter.router,
    themeMode: injector.get<ThemeController>().themeMode.value,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
  );
}
