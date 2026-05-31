import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repositories/etudiant_repository.dart';
import 'viewmodels/etudiant_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'views/etudiant_list_view.dart';

void main() {
  // Nécessaire avant d'utiliser des plugins (SharedPreferences) au démarrage.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MonApplication());
}

class MonApplication extends StatelessWidget {
  const MonApplication({super.key});

  @override
  Widget build(BuildContext context) {
    // On injecte les ViewModels au sommet de l'arbre via Provider.
    // `..charger()` déclenche le chargement des données persistées au démarrage.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EtudiantViewModel(EtudiantRepository())..charger(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeViewModel()..charger(),
        ),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVM, _) => MaterialApp(
          title: 'Gestion des étudiants',
          debugShowCheckedModeBanner: false,
          themeMode: themeVM.mode,
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          home: const EtudiantListView(),
        ),
      ),
    );
  }

  /// Thème commun (clair / sombre) basé sur une couleur de marque indigo.
  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
      ),
      cardTheme: const CardThemeData(
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}
