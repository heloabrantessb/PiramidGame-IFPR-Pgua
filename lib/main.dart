import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'core/di/dependency_injection.dart';
import 'core/routes/app_router.dart';
import 'core/theme/theme_controller.dart';

void main() {
  // Garante a inicialização dos bindings do Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Configura a injeção de dependência (auto_injector)
  setupDependencyInjection();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Busca o ThemeController de forma singleton do contêiner de DI
    final themeController = injector.get<ThemeController>();

    // O MaterialApp escuta reativamente o sinal de alternância de tema
    return MaterialApp.router(
      title: 'PiramidGame IFPR-Pgua',
      debugShowCheckedModeBanner: false,
      
      // Rotas gerenciadas pelo go_router
      routerConfig: AppRouter.router,

      // Configuração de temas claros e escuros personalizados
      themeMode: themeController.themeMode.watch(context),
      
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD0BCFF),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
    );
  }
}
