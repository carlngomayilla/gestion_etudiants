import 'package:flutter/material.dart';

/// Palette de couleurs utilisée pour les avatars.
const List<Color> _palette = [
  Color(0xFF3949AB), // indigo
  Color(0xFF00897B), // teal
  Color(0xFFD81B60), // pink
  Color(0xFF6D4C41), // brown
  Color(0xFF1E88E5), // blue
  Color(0xFF8E24AA), // purple
  Color(0xFFF4511E), // deep orange
  Color(0xFF43A047), // green
  Color(0xFF5E35B1), // deep purple
  Color(0xFF00ACC1), // cyan
];

/// Retourne une couleur stable (toujours la même pour une chaîne donnée).
///
/// Utilisé pour colorer les avatars : un même étudiant garde sa couleur.
Color couleurDepuisTexte(String texte) {
  if (texte.isEmpty) return _palette.first;
  var hash = 0;
  for (final unite in texte.codeUnits) {
    hash = (hash * 31 + unite) & 0x7fffffff;
  }
  return _palette[hash % _palette.length];
}
