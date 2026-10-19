import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../failure/failure.dart';
import '../patterns/command.dart';
import '../patterns/result.dart';
import '../../domain/facades/community_facade.dart';

class ThemeController {
  final CommunityFacade facade;
  ThemeController(this.facade);
  final themeMode = signal<ThemeMode>(ThemeMode.light);
  late final isLightMode = computed(() => themeMode.value == ThemeMode.light);
  Future<void> restore() async {
    final result = await facade.readDarkTheme();
    if (result.isSuccess) {
      themeMode.value = result.successValueOrNull!
          ? ThemeMode.dark
          : ThemeMode.light;
    }
  }

  late final toggleCommand = ToggleThemeCommand(() async {
    final dark = isLightMode.value;
    final result = await facade.saveDarkTheme(dark);
    if (result.isSuccess) {
      themeMode.value = dark ? ThemeMode.dark : ThemeMode.light;
    }
    return result;
  });
}

final class ToggleThemeCommand extends Command<void, Failure> {
  final Future<Result<void, Failure>> Function() action;
  ToggleThemeCommand(this.action);
  @override
  Future<Result<void, Failure>> execute() => action();
}
