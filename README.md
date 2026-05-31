# Gestion des étudiants — Flutter (MVVM)

[![CI](https://github.com/carlngomayilla/gestion_etudiants/actions/workflows/ci.yml/badge.svg)](https://github.com/carlngomayilla/gestion_etudiants/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)

Application Flutter de gestion des étudiants : **ajouter**, **modifier**,
**supprimer**, **rechercher**, **trier**, **filtrer** et visualiser des
**statistiques** — le tout avec une **persistance locale** des données et un
**thème clair / sombre**.

## ✨ Fonctionnalités

- ✅ Liste des étudiants avec **avatars colorés** et **badge de niveau** (L1…M2)
- ✅ Ajouter / modifier / supprimer (avec **confirmation** et **annulation**)
- ✅ **Matricule unique** et mis en **MAJUSCULES** automatiquement
- ✅ **Recherche** (nom, matricule, filière, email, niveau) + bouton effacer
- ✅ **Tri** (nom A→Z / Z→A, matricule, filière) et **filtre par filière** (chips)
- ✅ **Écran de détail** (tap sur une carte) avec en-tête en dégradé
- ✅ **Statistiques** : répartition par filière et par niveau (barres + %)
- ✅ **Persistance locale** : les données survivent à la fermeture de l'app
- ✅ **Thème clair / sombre** basculable (et mémorisé)
- ✅ Identifiants garantis uniques (pas de collision d'horloge)

## 🏛️ Architecture MVVM

```
lib/
├── main.dart                       # Point d'entrée + injection des ViewModels
├── models/
│   └── etudiant.dart               # MODEL : structure de données immuable
├── repositories/
│   └── etudiant_repository.dart    # Source de données (mémoire + SharedPreferences)
├── viewmodels/
│   ├── etudiant_viewmodel.dart     # VIEWMODEL : état + logique métier (CRUD, tri, filtre)
│   └── theme_viewmodel.dart        # VIEWMODEL : thème clair / sombre persisté
├── views/
│   ├── etudiant_list_view.dart     # VIEW : liste + recherche + tri + filtres
│   ├── etudiant_form_view.dart     # VIEW : formulaire ajout / modification
│   ├── etudiant_detail_view.dart   # VIEW : détail d'un étudiant
│   └── statistiques_view.dart      # VIEW : statistiques
├── widgets/
│   └── etudiant_tile.dart          # Widget réutilisable (carte étudiant)
└── utils/
    └── avatar_couleur.dart         # Couleur d'avatar déterministe
```

| Couche      | Rôle |
|-------------|------|
| **Model**     | Représente les données (`Etudiant`). Aucune logique d'UI. |
| **View**      | Affiche l'UI et capte les interactions. Aucune logique métier. |
| **ViewModel** | Contient l'état + la logique. Notifie les Vues via `notifyListeners()`. |

La gestion d'état repose sur le package **`provider`** : les `ViewModel` sont des
`ChangeNotifier`, les Vues les observent avec `Consumer` / `context.watch` et
leur envoient des actions avec `context.read`. Le `Repository` isole l'accès aux
données : passer à SQLite, une API REST ou Firebase ne demanderait de modifier
**que cette couche**.

## 🚀 Lancer le projet

Prérequis : [Flutter](https://docs.flutter.dev/get-started/install) installé
(`flutter doctor`). Sur **Windows**, activer le **Mode développeur** (requis par
les plugins) : `start ms-settings:developers`.

```powershell
flutter pub get
flutter run -d chrome    # ou -d windows
```

## 🧪 Tests & qualité

```powershell
flutter analyze    # analyse statique (0 problème attendu)
flutter test       # tests unitaires du ViewModel et du Model
dart format .      # formatage
```

L'**intégration continue** ([GitHub Actions](.github/workflows/ci.yml)) lance
automatiquement le formatage, l'analyse et les tests à chaque `push` et `pull
request` sur `main`.

## 🗺️ Aller plus loin

Idées d'améliorations : champs supplémentaires (photo, date de naissance),
gestion des notes/moyennes, export CSV/JSON, sélection multiple, localisation
FR/EN, layout adaptatif (master-detail sur tablette/desktop).

## 📄 Licence

Distribué sous licence **MIT** — voir le fichier [LICENSE](LICENSE).
