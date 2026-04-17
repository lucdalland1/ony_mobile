import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SemiArcController extends GetxController {
  final sections = <ArcSection>[
    ArcSection(color: Colors.blue, percent: 30.0, label: "Catégorie A"),
    ArcSection(color: Colors.green, percent: 25.0, label: "Catégorie B"),
    ArcSection(color: Colors.orange, percent: 25.0, label: "Catégorie C"),
    ArcSection(color: Colors.purple, percent: 20.0, label: "Catégorie D"),
  ].obs;

  void updateSection(int index, double newPercent) {
    // Logique de répartition automatique
    final total = sections.fold(0.0, (sum, s) => sum + (s == sections[index] ? 0 : s.percent));
    final remaining = 100 - newPercent;
    
    sections[index].percent = newPercent;
    
    // Répartir le reste proportionnellement
    if (total > 0) {
      for (var section in sections.where((s) => s != sections[index])) {
        section.percent = (section.percent / total) * remaining;
      }
    }
    sections.refresh();
  }
}

class ArcSection {
  Color color;
  double percent;
  String label;

  ArcSection({
    required this.color,
    required this.percent,
    required this.label,
  });
}