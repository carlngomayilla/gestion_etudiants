import '../models/etudiant.dart';

/// REPOSITORY — Source de données des étudiants.
///
/// Ici les données sont stockées en mémoire. Cette classe isole l'accès aux
/// données : pour passer plus tard à une vraie base (SQLite, API REST,
/// Firebase…), il suffira de réimplémenter ces méthodes sans toucher au
/// ViewModel ni aux Vues.
class EtudiantRepository {
  final List<Etudiant> _etudiants = [];

  /// Quelques données de démonstration au démarrage.
  EtudiantRepository() {
    _etudiants.addAll([
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
    ]);
  }

  /// Retourne une copie de la liste (la liste interne reste protégée).
  List<Etudiant> getAll() => List.unmodifiable(_etudiants);

  void ajouter(Etudiant etudiant) => _etudiants.add(etudiant);

  void modifier(Etudiant etudiant) {
    final index = _etudiants.indexWhere((e) => e.id == etudiant.id);
    if (index != -1) _etudiants[index] = etudiant;
  }

  void supprimer(String id) => _etudiants.removeWhere((e) => e.id == id);

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

  /// Compteur global garantissant des identifiants uniques même si plusieurs
  /// étudiants sont créés dans la même microseconde (l'horloge système peut
  /// avoir une résolution grossière sur Windows / le web).
  static int _sequence = 0;

  /// Génère un identifiant unique : horloge + numéro de séquence.
  static String _genererId() =>
      'etu_${DateTime.now().microsecondsSinceEpoch}_${_sequence++}';

  /// Exposé pour que le ViewModel puisse créer de nouveaux identifiants.
  String nouvelId() => _genererId();
}
