import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/View/Epargne/epargne%20group%C3%A9/eparne_suite.dart';
import 'package:onyfast/View/Epargne/epargne%20group%C3%A9/widget/CardObjectEpargneCommune.dart';
import 'package:onyfast/model/Epargne/epargnegroupe.dart';

// ignore: camel_case_types
class body extends StatefulWidget {
  final Groupe groupe;
  const body({super.key, required this.groupe });

  @override
  State<body> createState() => _bodyState();
}

// ignore: camel_case_types
class _bodyState extends State<body> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.groupe.nom, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Solde total épargné', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  Text('${widget.groupe.montantTotal} FCFA', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text('Prochaine contribution', style: TextStyle(color: Colors.grey)),
            Text(
              widget.groupe.nextDepositDate != null
                  ? widget.groupe.nextDepositDate.toString()
                  : 'inconnue',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("Contribution automatique chaque mois", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            SizedBox(height: 20),
            Text("Groupes d'épargne", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Rejoignez ou créez des groupes pour des projets communs", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            SizedBox(height: 10),

            // ❌ REMPLACEMENT DE Expanded
            ListView.builder(
              shrinkWrap: true, // Permet au ListView de fonctionner dans un scroll
              physics: NeverScrollableScrollPhysics(), // Empêche double scroll
              itemCount: widget.groupe.groupeObjects.length,
              itemBuilder: (BuildContext context, int index) {
                return groupeItem(context,widget.groupe.groupeObjects[index]);
              },
            ),

            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Get.to(CreerGroupePage());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorModel.Bluecolor242,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text('CRÉER UN OBJECTIF', style: TextStyle(fontWeight: FontWeight.bold, color: AppColorModel.WhiteColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
