import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/etudiant.dart';
import '../viewmodels/etudiant_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../widgets/etudiant_tile.dart';
import 'etudiant_detail_view.dart';
import 'etudiant_form_view.dart';
import 'statistiques_view.dart';

/// VIEW — Écran principal : affiche la liste des étudiants.
///
/// Cette Vue se contente d'observer le [EtudiantViewModel] et de lui
/// déléguer toutes les actions. Elle ne contient aucune logique métier.
class EtudiantListView extends StatefulWidget {
  const EtudiantListView({super.key});

  @override
  State<EtudiantListView> createState() => _EtudiantListViewState();
}

class _EtudiantListViewState extends State<EtudiantListView> {
  // Contrôleur du champ de recherche : permet d'afficher/effacer le texte.
  final TextEditingController _recherche = TextEditingController();

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  void _ouvrirFormulaire(BuildContext context, {Etudiant? etudiant}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EtudiantFormView(etudiant: etudiant),
      ),
    );
  }

  void _ouvrirDetail(BuildContext context, Etudiant etudiant) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EtudiantDetailView(etudiantId: etudiant.id),
      ),
    );
  }

  void _ouvrirStatistiques(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StatistiquesView()),
    );
  }

  Future<void> _confirmerSuppression(
    BuildContext context,
    Etudiant etudiant,
  ) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text(
          'Voulez-vous vraiment supprimer ${etudiant.nomComplet} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirme == true && context.mounted) {
      final vm = context.read<EtudiantViewModel>();
      final messenger = ScaffoldMessenger.of(context);
      vm.supprimer(etudiant.id);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('${etudiant.nomComplet} supprimé(e)'),
          action: SnackBarAction(
            label: 'Annuler',
            onPressed: () => vm.restaurer(etudiant),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des étudiants'),
        centerTitle: true,
        actions: [
          // Bascule du thème clair / sombre.
          Consumer<ThemeViewModel>(
            builder: (context, theme, _) => IconButton(
              icon: Icon(theme.estSombre ? Icons.light_mode : Icons.dark_mode),
              tooltip: theme.estSombre ? 'Thème clair' : 'Thème sombre',
              onPressed: theme.basculer,
            ),
          ),
          // Menu de tri.
          Consumer<EtudiantViewModel>(
            builder: (context, vm, _) => PopupMenuButton<TriEtudiant>(
              icon: const Icon(Icons.sort),
              tooltip: 'Trier',
              initialValue: vm.tri,
              onSelected: vm.trierPar,
              itemBuilder: (_) => [
                for (final t in TriEtudiant.values)
                  PopupMenuItem(value: t, child: Text(t.libelle)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Statistiques',
            onPressed: () => _ouvrirStatistiques(context),
          ),
        ],
      ),
      // `Consumer` reconstruit l'UI à chaque `notifyListeners()` du ViewModel.
      body: Consumer<EtudiantViewModel>(
        builder: (context, vm, _) {
          return Column(
            children: [
              _barreRecherche(vm),
              _filtresFiliere(vm),
              _compteur(vm),
              Expanded(
                child: vm.estVide
                    ? _etatVide(vm)
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: vm.etudiants.length,
                        itemBuilder: (context, index) {
                          final etudiant = vm.etudiants[index];
                          return EtudiantTile(
                            etudiant: etudiant,
                            onTap: () => _ouvrirDetail(context, etudiant),
                            onModifier: () => _ouvrirFormulaire(
                              context,
                              etudiant: etudiant,
                            ),
                            onSupprimer: () =>
                                _confirmerSuppression(context, etudiant),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _ouvrirFormulaire(context),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }

  Widget _barreRecherche(EtudiantViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: TextField(
        controller: _recherche,
        decoration: InputDecoration(
          hintText: 'Rechercher (nom, matricule, filière…)',
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          // Bouton « effacer » visible uniquement quand une recherche est active.
          suffixIcon: vm.rechercheActive
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Effacer',
                  onPressed: () {
                    _recherche.clear();
                    vm.effacerRecherche();
                  },
                )
              : null,
        ),
        onChanged: vm.rechercher,
      ),
    );
  }

  /// Rangée de chips permettant de filtrer par filière.
  Widget _filtresFiliere(EtudiantViewModel vm) {
    final filieres = vm.filieres;
    if (filieres.length < 2) return const SizedBox.shrink();

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('Toutes'),
              selected: vm.filiereFiltre == null,
              onSelected: (_) => vm.filtrerParFiliere(null),
            ),
          ),
          for (final f in filieres)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(f),
                selected: vm.filiereFiltre == f,
                onSelected: (sel) => vm.filtrerParFiliere(sel ? f : null),
              ),
            ),
        ],
      ),
    );
  }

  Widget _compteur(EtudiantViewModel vm) {
    // Quand un filtre est actif, on montre le nombre affiché sur le total.
    final texte = vm.filtreActif
        ? '${vm.nombreAffiche} résultat(s) sur ${vm.total}'
        : '${vm.total} étudiant(s)';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          texte,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _etatVide(EtudiantViewModel vm) {
    final aFiltre = vm.filtreActif;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            aFiltre ? Icons.search_off : Icons.group_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            aFiltre
                ? 'Aucun étudiant ne correspond aux filtres'
                : 'Aucun étudiant.\nAppuyez sur « Ajouter » pour commencer.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
