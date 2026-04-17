import 'package:flutter/material.dart';
import 'package:onyfast/Color/app_color_model.dart';
class ProgressionCirculaireAvecMax extends StatelessWidget {
  final double valeurActuelle; // Exemple : 90.0
  final double valeurMax;      // Exemple : 100.0

  const ProgressionCirculaireAvecMax({
    required this.valeurActuelle,
    required this.valeurMax,
  });

  @override
  Widget build(BuildContext context) {
    double progression = valeurActuelle / valeurMax;

    return Container(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              value: progression, // entre 0.0 et 1.0
              strokeWidth: 4,
              backgroundColor: Colors.grey[300],
              color: AppColorModel.BlueColor,
            ),
          ),
          Text(
            '${(progression * 100).toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
