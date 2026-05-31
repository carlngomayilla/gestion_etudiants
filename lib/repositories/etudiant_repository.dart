import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/etudiant.dart';

/// REPOSITORY — Source de données des étudiants.
///
/// Les données vivent en mémoire (lectures synchrones et rapides) et sont
/// **persistées** sur le disque via [SharedPreferences] (au format JSON).
/// Cette classe isole l'accès aux données : pour passer à une vraie base
/// (SQLite, API REST, Firebase…), il suffit de réimplémenter ces méthodes
/// sans toucher au ViewModel ni aux Vues.
class EtudiantRepository {
  static const String _cleStockage = 'etudiants_v1';

  final List<Etudiant> _etudiants = [];
  SharedPreferences? _prefs;

  /// Données de démonstration tant que rien n'a encore été persisté.
  EtudiantRepository() {
    _etudiants.addAll(_donneesDemo());
  }

  /// Charge les données persistées. À appeler une fois au démarrage.
  ///
  /// - Si des données existent déjà : elles remplacent les données de démo.
  /// - Sinon : les données de démo initiales sont persistées.
  Future<void> charger() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final brut = prefs.getString(_cleStockage);
    if (brut != null) {
      final liste = (jsonDecode(brut) as List)
          .map((m) => Etudiant.fromMap(m as Map<String, dynamic>))
          .toList();
      _etudiants
        ..clear()
        ..addAll(liste);
    } else {
      await _sauvegarder(); // persiste les données de démo initiales
    }
  }

  /// Retourne une copie de la liste (la liste interne reste protégée).
  List<Etudiant> getAll() => List.unmodifiable(_etudiants);

  void ajouter(Etudiant etudiant) {
    _etudiants.add(etudiant);
    unawaited(_sauvegarder());
  }

  void modifier(Etudiant etudiant) {
    final index = _etudiants.indexWhere((e) => e.id == etudiant.id);
    if (index != -1) {
      _etudiants[index] = etudiant;
      unawaited(_sauvegarder());
    }
  }

  void supprimer(String id) {
    _etudiants.removeWhere((e) => e.id == id);
    unawaited(_sauvegarder());
  }

  /// Indique si un matricule est déjà utilisé.
  ///
  /// La comparaison est insensible à la casse. [exclureId] permet d'ignorer
  /// l'étudiant en cours de modification (sinon il entrerait en conflit avec
  /// lui-même).
  bool matriculeExiste(String matricule, {String? exclureId}) {
    final m = matricule.trim().toLowerCase();
    return _etudiants.any(
      (e) => e.id != exclureId && e.matricule.trim().toLowerCase() == m,
    );
  }

  /// Sauvegarde la liste au format JSON.
  ///
  /// No-op tant que la persistance n'a pas été initialisée par [charger]
  /// (utile pour les tests unitaires qui ne touchent pas au disque).
  Future<void> _sauvegarder() async {
    final prefs = _prefs;
    if (prefs == null) return;
    final brut = jsonEncode(_etudiants.map((e) => e.toMap()).toList());
    await prefs.setString(_cleStockage, brut);
  }

  /// Compteur global garantissant des identifiants uniques même si plusieurs
  /// étudiants sont créés dans la même microseconde (l'horloge système peut
  /// avoir une résolution grossière sur Windows / le web).
  static int _sequence = 0;

  /// Génère un identifiant unique : horloge + numéro de séquence.
  static String _genererId() =>
      'etu_${DateTime.now().microsecondsSinceEpoch}_${_sequence++}';

  /// Exposé pour que le ViewModel puisse créer de nouveaux identifiants.
  String nouvelId() => _genererId();

  /// Quelques étudiants de démonstration au premier lancement.
  static List<Etudiant> _donneesDemo() => [
        Etudiant(
          id: _genererId(),
          nom: 'Diop',
          prenom: 'Awa',
          matricule: 'ETU-001',
          email: 'awa.diop@univ.sn',
          filiere: 'Informatique',
          niveau: 'L3',
        ),
        Etudiant(
          id: _genererId(),
          nom: 'Ndiaye',
          prenom: 'Moussa',
          matricule: 'ETU-002',
          email: 'moussa.ndiaye@univ.sn',
          filiere: 'Génie Civil',
          niveau: 'M1',
        ),
        Etudiant(
          id: _genererId(),
          nom: 'Fall',
          prenom: 'Mariama',
          matricule: 'ETU-003',
          email: 'mariama.fall@univ.sn',
          filiere: 'Informatique',
          niveau: 'L1',
        ),
        Etudiant(
          id: _genererId(),
          nom: 'Ba',
          prenom: 'Cheikh',
          matricule: 'ETU-004',
          email: 'cheikh.ba@univ.sn',
          filiere: 'Mathématiques',
          niveau: 'M2',
        ),
      ];
}
