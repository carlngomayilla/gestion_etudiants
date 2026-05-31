/// MODEL — Représente un étudiant.
///
/// Couche "Model" de l'architecture MVVM : c'est une simple structure de
/// données immuable, sans aucune logique d'affichage.
class Etudiant {
  final String id;
  final String nom;
  final String prenom;
  final String matricule;
  final String email;
  final String filiere;

  /// Niveau d'études : L1, L2, L3, M1, M2 (voir [Etudiant.niveaux]).
  final String niveau;

  const Etudiant({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.matricule,
    required this.email,
    required this.filiere,
    this.niveau = 'L1',
  });

  /// Niveaux d'études autorisés (utilisés pour le menu déroulant du formulaire).
  static const List<String> niveaux = ['L1', 'L2', 'L3', 'M1', 'M2'];

  /// Nom complet affichable, ex: "Awa Diop".
  String get nomComplet => '$prenom $nom';

  /// Initiales pour l'avatar, ex: "AD".
  String get initiales {
    final p = prenom.isNotEmpty ? prenom[0] : '';
    final n = nom.isNotEmpty ? nom[0] : '';
    return (p + n).toUpperCase();
  }

  /// Retourne une copie modifiée de l'étudiant (utile pour l'édition).
  Etudiant copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? matricule,
    String? email,
    String? filiere,
    String? niveau,
  }) {
    return Etudiant(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      matricule: matricule ?? this.matricule,
      email: email ?? this.email,
      filiere: filiere ?? this.filiere,
      niveau: niveau ?? this.niveau,
    );
  }

  /// Sérialisation (utile pour une future persistance : JSON, base de données…).
  Map<String, dynamic> toMap() => {
        'id': id,
        'nom': nom,
        'prenom': prenom,
        'matricule': matricule,
        'email': email,
        'filiere': filiere,
        'niveau': niveau,
      };

  factory Etudiant.fromMap(Map<String, dynamic> map) => Etudiant(
        id: map['id'] as String,
        nom: map['nom'] as String,
        prenom: map['prenom'] as String,
        matricule: map['matricule'] as String,
        email: map['email'] as String,
        filiere: map['filiere'] as String,
        niveau: (map['niveau'] as String?) ?? 'L1',
      );

  /// Deux étudiants sont égaux s'ils ont les mêmes données.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Etudiant &&
          other.id == id &&
          other.nom == nom &&
          other.prenom == prenom &&
          other.matricule == matricule &&
          other.email == email &&
          other.filiere == filiere &&
          other.niveau == niveau;

  @override
  int get hashCode =>
      Object.hash(id, nom, prenom, matricule, email, filiere, niveau);

  @override
  String toString() =>
      'Etudiant(id: $id, $nomComplet, matricule: $matricule, '
      'filiere: $filiere, niveau: $niveau)';
}
