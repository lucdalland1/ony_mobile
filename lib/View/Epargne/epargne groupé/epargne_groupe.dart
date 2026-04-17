import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/View/Epargne/epargne%20group%C3%A9/eparne_suite.dart';
import 'package:onyfast/model/Epargne/epargnegroupe.dart';

class EpargneGroupeePage extends StatelessWidget {
  final int totalEpargne = 210000;
  final String prochaineContribution = '15 février';

  final List<Map<String, dynamic>> groupes = [
    {
      'label': 'Tontine Mensuelle',
      'current': 150000,
      'goal': 750000,
      'icon': Icons.groups,
    },
    
  ];

  Groupe? groupe;

  @override
  Widget build(BuildContext context) {
    groupe = Get.arguments['groupe'];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0A2149),
        title: Text("Epargne Groupe Rotative", style: TextStyle(color: Colors.white)),
        leading: BackButton(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(groupe!.nom, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("Épargnez et tournez-vous l'argent avec votre groupe", style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 8),
              Text("Système de rotation mensuel pour tous les membres", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              SizedBox(height: 17),
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
                    Text('$totalEpargne FCFA', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
              SizedBox(height: 02),
              Text('Prochaine contribution', style: TextStyle(color: Colors.grey)),
              Text(prochaineContribution, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Rotation mensuelle automatique", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              SizedBox(height: 20),
              Text("Groupes d'épargne", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Rejoignez ou créez des groupes pour la rotation mensuelle", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              SizedBox(height: 10),
              ...groupes.map((group) => _groupeItem(group)).toList(),
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
                  child: Text('CRÉER UN GROUPE', style: TextStyle(fontWeight: FontWeight.bold, color: AppColorModel.WhiteColor),),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _groupeItem(Map<String, dynamic> item) {
    double progress = item['current'] / item['goal'];
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
                    child: Icon(item['icon'], color: Colors.orange.shade800),
                  ),
                  SizedBox(width: 12),
                  Text(item['label'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              Icon(Icons.settings, color: Colors.grey.shade700)
            ],
          ),
          SizedBox(height: 8),
          Text('${item['current']} / ${item['goal']} FCFA'),
          SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            color: Colors.orange,
            backgroundColor: Colors.grey.shade300,
            minHeight: 6,
          ),
          SizedBox(height: 6),
          Text('En cours', style: TextStyle(color: Colors.grey.shade600))
        ],
      ),
    );
  }
}

