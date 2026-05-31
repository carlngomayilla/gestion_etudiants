import 'package:flutter/foundation.dart';

import '../models/etudiant.dart';
import '../repositories/etudiant_repository.dart';

/// Critères de tri disponibles pour la liste des étudiants.
enum TriEtudiant {
  nomAsc('Nom (A → Z)'),
  nomDesc('Nom (Z → A)'),
  matricule('Matricule'),
  filiere('Filière');

  const TriEtudiant(this.libelle);

  /// Texte affiché dans le menu de tri.
  final String libelle;
}

/// VIEWMODEL — Le cœur de l'architecture MVVM.
///
/// Il contient l'état et la logique métier (ajouter / modifier / supprimer /
/// rechercher / trier / filtrer) et notifie les Vues via [ChangeNotifier]
/// (`notifyListeners`). Les Vues n'accèdent JAMAIS directement au Repository :
/// elles passent toujours par ce ViewModel.
class EtudiantViewModel extends ChangeNotifier {
  final EtudiantRepository _repository;

  EtudiantViewModel(this._repository);

  String _recherche = '';
  String? _filiereFiltre; // null = toutes les filières
  TriEtudiant _tri = TriEtudiant.nomAsc;

  /// Texte de recherche courant.
  String get recherche => _recherche;

  /// Filière sélectionnée comme filtre (null si « Toutes »).
  String? get filiereFiltre => _filiereFiltre;

  /// Critère de tri courant.
  TriEtudiant get tri => _tri;

  /// Liste affichée : tous les étudiants, filtrés (recherche + filière) puis triés.
  List<Etudiant> get etudiants {
    var liste = _repository.getAll();

    // 1. Filtre par filière.
    if (_filiereFiltre != null) {
      liste = liste.where((e) => e.filiere == _filiereFiltre).toList();
    }

    // 2. Filtre par recherche texte.
    if (_recherche.trim().isNotEmpty) {
      final q = _recherche.toLowerCase();
      liste = liste.where((e) {
        return e.nomComplet.toLowerCase().contains(q) ||
            e.matricule.toLowerCase().contains(q) ||
            e.filiere.toLowerCase().contains(q) ||
            e.email.toLowerCase().contains(q) ||
            e.niveau.toLowerCase().contains(q);
      }).toList();
    }

    // 3. Tri.
    final triee = [...liste];
    switch (_tri) {
      case TriEtudiant.nomAsc:
        triee.sort((a, b) =>
            a.nomComplet.toLowerCase().compareTo(b.nomComplet.toLowerCase()));
      case TriEtudiant.nomDesc:
        triee.sort((a, b) =>
            b.nomComplet.toLowerCase().compareTo(a.nomComplet.toLowerCase()));
      case TriEtudiant.matricule:
        triee.sort((a, b) => a.matricule.compareTo(b.matricule));
      case TriEtudiant.filiere:
        triee.sort((a, b) {
          final f = a.filiere.toLowerCase().compareTo(b.filiere.toLowerCase());
          return f != 0
              ? f
              : a.nomComplet.toLowerCase().compareTo(b.nomComplet.toLowerCase());
        });
    }
    return triee;
  }

  /// Retourne l'étudiant correspondant à [id] (sans tenir compte des filtres),
  /// ou `null` s'il n'existe plus.
  Etudiant? getById(String id) {
    for (final e in _repository.getAll()) {
      if (e.id == id) return e;
    }
    return null;
  }

  bool get estVide => etudiants.isEmpty;

  /// Nombre total d'étudiants (sans tenir compte des filtres).
  int get total => _repository.getAll().length;

  /// Nombre d'étudiants actuellement affichés (après filtrage).
  int get nombreAffiche => etudiants.length;

  /// Indique si une recherche est en cours.
  bool get rechercheActive => _recherche.trim().isNotEmpty;

  /// Indique si un filtre (recherche ou filière) est actif.
  bool get filtreActif => rechercheActive || _filiereFiltre != null;

  /// Liste triée des filières existantes (pour les filtres).
  List<String> get filieres {
    final set = _repository.getAll().map((e) => e.filiere).toSet().toList();
    set.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return set;
  }

  /// Nombre d'étudiants par filière (pour l'écran de statistiques).
  Map<String, int> get statistiquesParFiliere {
    final stats = <String, int>{};
    for (final e in _repository.getAll()) {
      stats[e.filiere] = (stats[e.filiere] ?? 0) + 1;
    }
    // Trié par effectif décroissant.
    final entries = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final e in entries) e.key: e.value};
  }

  /// Nombre d'étudiants par niveau (pour l'écran de statistiques).
  Map<String, int> get statistiquesParNiveau {
    final stats = {for (final n in Etudiant.niveaux) n: 0};
    for (final e in _repository.getAll()) {
      stats[e.niveau] = (stats[e.niveau] ?? 0) + 1;
    }
    return stats;
  }

  // ---------------------------------------------------------------------------
  // Actions (logique métier)
  // ---------------------------------------------------------------------------

  /// Ajoute un nouvel étudiant (l'id est généré automatiquement).
  ///
  /// Retourne `null` en cas de succès, ou un message d'erreur si le matricule
  /// est déjà utilisé.
  String? ajouter({
    required String nom,
    required String prenom,
    required String matricule,
    required String email,
    required String filiere,
    String niveau = 'L1',
  }) {
    final mat = matricule.trim();
    if (_repository.matriculeExiste(mat)) {
      return 'Le matricule « $mat » est déjà utilisé.';
    }

    final etudiant = Etudiant(
      id: _repository.nouvelId(),
      nom: nom.trim(),
      prenom: prenom.trim(),
      matricule: mat,
      email: email.trim(),
      filiere: filiere.trim(),
      niveau: niveau,
    );
    _repository.ajouter(etudiant);
    notifyListeners();
    return null;
  }

  /// Modifie un étudiant existant (identifié par son id).
  ///
  /// Retourne `null` en cas de succès, ou un message d'erreur si le matricule
  /// entre en conflit avec un autre étudiant.
  String? modifier(Etudiant etudiant) {
    final mat = etudiant.matricule.trim();
    if (_repository.matriculeExiste(mat, exclureId: etudiant.id)) {
      return 'Le matricule « $mat » est déjà utilisé.';
    }

    _repository.modifier(etudiant.copyWith(
      nom: etudiant.nom.trim(),
      prenom: etudiant.prenom.trim(),
      matricule: mat,
      email: etudiant.email.trim(),
      filiere: etudiant.filiere.trim(),
    ));
    notifyListeners();
    return null;
  }

  /// Supprime un étudiant.
  void supprimer(String id) {
    _repository.supprimer(id);
    // Si la filière filtrée n'a plus d'étudiant, on enlève le filtre.
    if (_filiereFiltre != null && !filieres.contains(_filiereFiltre)) {
      _filiereFiltre = null;
    }
    notifyListeners();
  }

  /// Met à jour le filtre de recherche.
  void rechercher(String valeur) {
    _recherche = valeur;
    notifyListeners();
  }

  /// Réinitialise la recherche.
  void effacerRecherche() {
    if (_recherche.isEmpty) return;
    _recherche = '';
    notifyListeners();
  }

  /// Sélectionne une filière comme filtre (null = toutes).
  void filtrerParFiliere(String? filiere) {
    _filiereFiltre = filiere;
    notifyListeners();
  }

  /// Change le critère de tri.
  void trierPar(TriEtudiant tri) {
    _tri = tri;
    notifyListeners();
  }
}
