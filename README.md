# Gestion des étudiants — Flutter (MVVM)

Mini application de gestion des étudiants : **ajouter**, **modifier**, **supprimer**
et **afficher la liste** (avec recherche).

## Architecture MVVM

```
lib/
├── main.dart                  # Point d'entrée + injection du ViewModel (Provider)
├── models/
│   └── etudiant.dart          # MODEL : structure de données immuable
├── repositories/
│   └── etudiant_repository.dart  # Source de données (en mémoire)
├── viewmodels/
│   └── etudiant_viewmodel.dart   # VIEWMODEL : état + logique métier (ChangeNotifier)
├── views/
│   ├── etudiant_list_view.dart   # VIEW : liste des étudiants
│   └── etudiant_form_view.dart   # VIEW : formulaire ajout / modification
└── widgets/
    └── etudiant_tile.dart        # Widget réutilisable (carte étudiant)
```

| Couche      | Rôle |
|-------------|------|
| **Model**     | Représente les données (`Etudiant`). Aucune logique d'UI. |
| **View**      | Affiche l'UI et capte les interactions. Aucune logique métier. |
| **ViewModel** | Contient l'état + la logique (CRUD, recherche). Notifie les Vues via `notifyListeners()`. |

La gestion d'état repose sur le package **`provider`** : le `ViewModel` est un
`ChangeNotifier`, les Vues l'observent avec `Consumer` / `context.watch` et lui
envoient des actions avec `context.read`.

## Prérequis

Flutter n'est pas encore installé sur cette machine. Installe-le :
1. Télécharge le SDK : https://docs.flutter.dev/get-started/install/windows
2. Ajoute `flutter\bin` au `PATH`, puis vérifie avec `flutter doctor`.

## Lancer le projet

Depuis le dossier du projet :

```powershell
# 1. Générer les dossiers de plateforme (android, web, windows…)
#    Ne touche PAS aux fichiers de lib/ déjà présents.
flutter create .

# 2. Récupérer les dépendances
flutter pub get

# 3. Lancer (choisis une cible : windows, chrome, ou un émulateur)
flutter run -d windows
# ou
flutter run -d chrome
```

> ⚠️ Si après `flutter create .` le fichier `lib/main.dart` a été remplacé par
> l'exemple par défaut, restaure simplement la version fournie ici.

## Lancer les tests

```powershell
flutter test
```

## Fonctionnalités

- ✅ Afficher la liste des étudiants (avec compteur « résultats / total »)
- ✅ Ajouter un étudiant (validation des champs + **matricule unique**)
- ✅ Modifier un étudiant (vérifie aussi l'unicité du matricule)
- ✅ Supprimer un étudiant (avec confirmation)
- ✅ Rechercher (nom, matricule, filière, email) + bouton « effacer »
- ✅ Identifiants garantis uniques (compteur de séquence, pas de collision d'horloge)

## Aller plus loin

Le `EtudiantRepository` stocke les données **en mémoire** (perdues à la fermeture).
Pour une persistance réelle, réimplémente ses méthodes avec `sqflite`,
`shared_preferences`, une API REST ou Firebase — **sans rien changer** au
ViewModel ni aux Vues.
