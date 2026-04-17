// ignore: file_names
import 'package:flutter/material.dart';
import 'package:onyfast/model/Epargne/epargnegroupe.dart';

Widget groupeItem(var context ,GroupeObject item) {
  //double progress = item['current'] / item['goal'];
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: Icon(Icons.person_2_rounded, color: Colors.orange.shade800),
                  ),
                  SizedBox(width: 12),
                  Text(item.nom, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              Icon(Icons.settings, color: Colors.grey.shade700)
            ],
          ),
          SizedBox(height: 8),
          Text('${item.montantActuel} / ${item.montantCible} FCFA'),
          SizedBox(height: 6),
          SliderTheme(
  data: SliderTheme.of(context).copyWith(
    trackHeight: 10, // Hauteur de la ligne du slider

    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0), // Enlève le cercle
    overlayShape: SliderComponentShape.noOverlay, // Pas d'effet de survol
  ),
  child: Slider(
    min: 0,
    max: double.parse(item.montantCible),
    value:double.parse(item.montantActuel).clamp(0, double.parse(item.montantCible)),
    activeColor: Colors.orange,
    inactiveColor: Colors.orange,
    onChanged: null, // Lecture seule
  ),
),

          SizedBox(height: 6),
          Text('En cours', style: TextStyle(color: Colors.grey.shade600))
        ],
      ),
    );
  }
