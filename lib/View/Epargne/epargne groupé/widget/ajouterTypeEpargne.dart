import 'package:flutter/material.dart';

void showCreateGroupePopup(
  BuildContext context,
  int type,
  Function(String nom, String frequence) onCreate,
) {
  final nomController = TextEditingController();
  final frequences = ['Quotidien', 'Hebdomadaire', 'Mensuel', 'Trimestriel', 'Annuel'];
  String? selectedFrequence;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(
          type == 1
              ? 'Créer un groupe d\'épargne commune'
              : 'Créer un groupe d\'épargne rotative',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomController,
              maxLength: 30,
              decoration: InputDecoration(
                labelText: 'Nom du groupe',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Fréquence',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              value: selectedFrequence,
              items: frequences.map((f) {
                return DropdownMenuItem(
                  value: f,
                  child: Text(f),
                );
              }).toList(),
              onChanged: (value) {
                
                selectedFrequence = value;
              },
              validator: (value) =>
                  value == null ? 'Veuillez sélectionner une fréquence' : null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (nomController.text.trim().isEmpty || selectedFrequence == null) {
                // Optionnel : tu peux afficher un message ici si tu veux
                return;
              }
              onCreate(nomController.text.trim(), selectedFrequence!);
              Navigator.of(context).pop();
            },
            child: Text('Créer'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler'),
          ),
        ],
      );
    },
  );
}
