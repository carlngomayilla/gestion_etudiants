import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_etudiants/models/etudiant.dart';
import 'package:gestion_etudiants/repositories/etudiant_repository.dart';
import 'package:gestion_etudiants/viewmodels/etudiant_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late EtudiantViewModel vm;

  setUp(() {
    // Repository neuf à chaque test (contient des étudiants de démo).
    vm = EtudiantViewModel(EtudiantRepository());
  });

  test('ajouter augmente le nombre d\'étudiants', () {
    final avant = vm.total;
    final erreur = vm.ajouter(
      nom: 'Sow',
      prenom: 'Fatou',
      matricule: 'ETU-100',
      email: 'fatou.sow@univ.sn',
      filiere: 'Mathématiques',
    );
    expect(erreur, isNull);
    expect(vm.total, avant + 1);
  });

  test('ajouter refuse un matricule déjà utilisé', () {
    final dejaLa = vm.etudiants.first.matricule;
    final avant = vm.total;
    final erreur = vm.ajouter(
      nom: 'Sow',
      prenom: 'Fatou',
      matricule: dejaLa, // doublon
      email: 'fatou.sow@univ.sn',
      filiere: 'Mathématiques',
    );
    expect(erreur, isNotNull);
    expect(vm.total, avant); // aucun ajout
  });

  test('supprimer retire l\'étudiant', () {
    final cible = vm.etudiants.first;
    vm.supprimer(cible.id);
    expect(vm.etudiants.any((e) => e.id == cible.id), isFalse);
  });

  test('modifier met à jour les données', () {
    final cible = vm.etudiants.first;
    final erreur = vm.modifier(cible.copyWith(filiere: 'Réseaux'));
    expect(erreur, isNull);
    final maj = vm.etudiants.firstWhere((e) => e.id == cible.id);
    expect(maj.filiere, 'Réseaux');
  });

  test('modifier refuse un matricule appartenant à un autre étudiant', () {
    final premier = vm.etudiants[0];
    final second = vm.etudiants[1];
    // On tente de donner au second le matricule du premier.
    final erreur = vm.modifier(second.copyWith(matricule: premier.matricule));
    expect(erreur, isNotNull);
  });

  test('modifier accepte de conserver son propre matricule', () {
    final cible = vm.etudiants.first;
    // Même matricule, autre champ modifié : ne doit pas être bloqué.
    final erreur = vm.modifier(cible.copyWith(prenom: 'Awatef'));
    expect(erreur, isNull);
  });

  test('les identifiants générés sont uniques', () {
    final ids = <String>{};
    for (var i = 0; i < 50; i++) {
      vm.ajouter(
        nom: 'Test',
        prenom: 'N$i',
        matricule: 'ETU-2$i',
        email: 'test$i@univ.sn',
        filiere: 'Info',
      );
    }
    for (final e in vm.etudiants) {
      ids.add(e.id);
    }
    expect(ids.length, vm.total); // aucun doublon d'id
  });

  test('rechercher filtre la liste', () {
    vm.ajouter(
      nom: 'Sow',
      prenom: 'Fatou',
      matricule: 'ETU-100',
      email: 'fatou.sow@univ.sn',
      filiere: 'Mathématiques',
    );
    vm.rechercher('Fatou');
    expect(vm.rechercheActive, isTrue);
    expect(vm.nombreAffiche, 1);
    expect(vm.etudiants.first.prenom, 'Fatou');
  });

  test('effacerRecherche réaffiche tous les étudiants', () {
    vm.rechercher('Fatou');
    vm.effacerRecherche();
    expect(vm.rechercheActive, isFalse);
    expect(vm.nombreAffiche, vm.total);
  });

  test('le total reste indépendant du filtre de recherche', () {
    final total = vm.total;
    vm.rechercher('zzz-introuvable');
    expect(vm.nombreAffiche, 0);
    expect(vm.total, total); // le total ne change pas
  });

  test('Etudiant : égalité de valeur', () {
    const a = Etudiant(
      id: '1',
      nom: 'Diop',
      prenom: 'Awa',
      matricule: 'ETU-001',
      email: 'a@b.sn',
      filiere: 'Info',
    );
    final b = a.copyWith();
    final c = a.copyWith(filiere: 'Réseaux');
    final d = a.copyWith(niveau: 'M2');
    expect(a, equals(b));
    expect(a.hashCode, equals(b.hashCode));
    expect(a, isNot(equals(c)));
    expect(a, isNot(equals(d))); // le niveau compte dans l'égalité
  });

  test('ajouter conserve le niveau fourni', () {
    vm.ajouter(
      nom: 'Sow',
      prenom: 'Fatou',
      matricule: 'ETU-100',
      email: 'fatou.sow@univ.sn',
      filiere: 'Mathématiques',
      niveau: 'M1',
    );
    final ajoute = vm.etudiants.firstWhere((e) => e.matricule == 'ETU-100');
    expect(ajoute.niveau, 'M1');
  });

  test('getById retrouve un étudiant même quand un filtre est actif', () {
    final cible = vm.etudiants.first;
    vm.rechercher('zzz-introuvable'); // masque tout le monde
    expect(vm.nombreAffiche, 0);
    expect(vm.getById(cible.id), isNotNull);
    expect(vm.getById('id-inexistant'), isNull);
  });

  test('trierPar nomAsc / nomDesc ordonne la liste', () {
    vm.trierPar(TriEtudiant.nomAsc);
    final asc = vm.etudiants.map((e) => e.nomComplet).toList();
    final attenduAsc = [...asc]
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    expect(asc, attenduAsc);

    vm.trierPar(TriEtudiant.nomDesc);
    final desc = vm.etudiants.map((e) => e.nomComplet).toList();
    expect(desc, asc.reversed.toList());
  });

  test('filtrerParFiliere ne garde que la filière choisie', () {
    final filiere = vm.etudiants.first.filiere;
    vm.filtrerParFiliere(filiere);
    expect(vm.etudiants.every((e) => e.filiere == filiere), isTrue);
    expect(vm.filtreActif, isTrue);

    vm.filtrerParFiliere(null);
    expect(vm.nombreAffiche, vm.total);
  });

  test('filieres renvoie la liste distincte et triée', () {
    final filieres = vm.filieres;
    // Pas de doublon.
    expect(filieres.toSet().length, filieres.length);
    // Trié alphabétiquement (insensible à la casse).
    final trie = [...filieres]
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    expect(filieres, trie);
  });

  test('statistiquesParFiliere compte correctement', () {
    final stats = vm.statistiquesParFiliere;
    // La somme des effectifs = total.
    final somme = stats.values.fold<int>(0, (s, v) => s + v);
    expect(somme, vm.total);
  });

  test('statistiquesParNiveau couvre tous les niveaux', () {
    final stats = vm.statistiquesParNiveau;
    expect(stats.keys.toSet(), Etudiant.niveaux.toSet());
    final somme = stats.values.fold<int>(0, (s, v) => s + v);
    expect(somme, vm.total);
  });

  test('restaurer remet un étudiant supprimé (avec son id)', () {
    final cible = vm.etudiants.first;
    vm.supprimer(cible.id);
    expect(vm.getById(cible.id), isNull);

    vm.restaurer(cible);
    expect(vm.getById(cible.id), isNotNull);
    expect(vm.getById(cible.id), equals(cible)); // mêmes données qu'avant
  });

  group('Persistance (SharedPreferences)', () {
    test('charger() persiste les données de démo puis les recharge', () async {
      SharedPreferences.setMockInitialValues({});

      // 1er lancement : aucune donnée persistée -> on sauvegarde la démo.
      final repo1 = EtudiantRepository();
      await repo1.charger();
      final attendu = repo1.getAll().length;

      // 2e lancement : les données persistées doivent être rechargées.
      final repo2 = EtudiantRepository();
      await repo2.charger();
      expect(repo2.getAll().length, attendu);
    });

    test('un ajout est bien persisté et rechargé', () async {
      SharedPreferences.setMockInitialValues({});

      final vm1 = EtudiantViewModel(EtudiantRepository());
      await vm1.charger();
      final avant = vm1.total;
      vm1.ajouter(
        nom: 'Sow',
        prenom: 'Fatou',
        matricule: 'ETU-999',
        email: 'fatou.sow@univ.sn',
        filiere: 'Mathématiques',
        niveau: 'L2',
      );
      // Laisse la sauvegarde asynchrone se terminer.
      await Future<void>.delayed(Duration.zero);

      final vm2 = EtudiantViewModel(EtudiantRepository());
      await vm2.charger();
      expect(vm2.total, avant + 1);
      expect(
        vm2.etudiants.any((e) => e.matricule == 'ETU-999'),
        isTrue,
      );
    });
  });
}
