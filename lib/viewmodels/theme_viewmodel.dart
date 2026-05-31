import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// VIEWMODEL — Gère le mode de thème (clair / sombre) et le persiste.
///
/// Au démarrage, le choix de l'utilisateur est restauré depuis
/// [SharedPreferences] ; à défaut, on suit le thème du système.
class ThemeViewModel extends ChangeNotifier {
  static const String _cle = 'theme_mode';

  ThemeMode _mode = ThemeMode.system;

  /// Mode courant (system / light / dark).
  ThemeMode get mode => _mode;

  /// Vrai si le thème sombre est actif.
  bool get estSombre => _mode == ThemeMode.dark;

  /// Restaure le choix persisté.
  Future<void> charger() async {
    final prefs = await SharedPreferences.getInstance();
    _mode = switch (prefs.getString(_cle)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  /// Bascule entre clair et sombre, puis mémorise le choix.
  Future<void> basculer() async {
    _mode = estSombre ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cle, estSombre ? 'dark' : 'light');
  }
}
