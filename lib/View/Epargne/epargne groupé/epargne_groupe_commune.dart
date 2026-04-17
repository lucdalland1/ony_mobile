import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:onyfast/Controller/Eparge/EpargneGroupeController.dart';
import 'package:onyfast/View/Epargne/epargne%20group%C3%A9/widget/List.dart';
import 'package:onyfast/View/Epargne/epargne%20group%C3%A9/widget/ajouterTypeEpargne.dart';
import 'package:onyfast/View/Epargne/epargne%20group%C3%A9/widget/body.dart';
import 'package:onyfast/View/Epargne/epargne%20group%C3%A9/widget/myaccordion.dart';
import 'package:onyfast/View/Epargne/model/EpargneIndividuelleModel.dart';
   final List<Map<String, dynamic>> groupes = [
    {
      'label': 'Type Commune',
      'current': 150000,
      'goal': 750000,
      'icon': Icons.groups,
    },
    {
      'label': 'Projet Mariage',
      'current': 60000,
      'goal': 100000,
      'icon': Icons.volunteer_activism,
    },
  ];



class EpargneGroupeCommune extends StatefulWidget {
   EpargneGroupeCommune({Key? key}) : super(key: key);

  @override
  _EpargneGroupeCommuneState createState() => _EpargneGroupeCommuneState();
}

class _EpargneGroupeCommuneState extends State<EpargneGroupeCommune> {
    
    @override
    void initState() { 
      super.initState();
      ajouterController.fetchMesGroupes();
    }
  var ajouterController = Get.find<EpargneGroupeController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {

         // ignore: avoid_types_as_parameter_names
         showCreateGroupePopup(context,1, (nom,Frequence) {

         print('Nom groupe saisi : $nom');
         print('Fréquence saisie : $Frequence');
        final frequenceId = ajouterController.getFrequenceId(Frequence);

         ajouterController.creerGroupe(nom, "1", '$frequenceId');
          ajouterController.fetchMesGroupes();
     
    });
         
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFF0A2149),
        title: const Text('Épargne Commune',  style: TextStyle(color: Colors.white)),
        leading: BackButton(color: Colors.white),
        centerTitle: true,
      ),
    body:Obx(() {
        if (ajouterController.isLoading.value) {
          return Center(child: CupertinoActivityIndicator());
        }

        else if (ajouterController.error.value==true) {
          return Center(child: Text('Erreur: Impossible de se connecter au serveur}'));
        }
        if (ajouterController.groupes.isEmpty) {
          return Center(child: Text('Aucun groupe trouvé'));
        }

        return MyAccordion(
            children: ajouterController.groupes.where((groupe) => groupe.typeGroupeId == 1).
            map((groupe) 
            {
              
              
              return CustomAccordion(
                groupe: groupe, 

              );
  }).toList(),
);

      }),
    
 
    );
  }
}
