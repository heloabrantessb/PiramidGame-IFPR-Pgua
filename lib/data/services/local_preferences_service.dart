import 'package:shared_preferences/shared_preferences.dart';

class LocalPreferencesService {
  Future<bool> readDarkTheme() async =>
      (await SharedPreferences.getInstance()).getBool('dark_theme') ?? false;
  Future<void> saveDarkTheme(bool dark) async {
    if (!await (await SharedPreferences.getInstance()).setBool(
      'dark_theme',
      dark,
    )) {
      throw StateError('Não foi possível salvar a preferência de tema.');
    }
  }
}
