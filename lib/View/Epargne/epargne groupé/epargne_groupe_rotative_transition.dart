import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/Eparge/EpargneGroupeController.dart';
import 'package:onyfast/View/Epargne/epargne%20group%C3%A9/epargne_groupe.dart';
import 'package:onyfast/View/Epargne/epargne%20group%C3%A9/widget/ajouterTypeEpargne.dart';
import 'package:onyfast/model/Epargne/epargnegroupe.dart';
import 'package:shimmer/shimmer.dart';

class EpargneGroupeRotativeTransition extends StatefulWidget {
  const EpargneGroupeRotativeTransition({super.key});

  @override
  State<EpargneGroupeRotativeTransition> createState() =>
      _EpargneGroupeRotativeTransitionState();
}

class _EpargneGroupeRotativeTransitionState
    extends State<EpargneGroupeRotativeTransition> {
  var ajouterController = Get.find<EpargneGroupeController>();
  @override
  void initState() {
    super.initState();
    ajouterController.fetchMesGroupes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Obx(() =>
  ajouterController.isLoading.value
      ? const SizedBox.shrink()
      :ajouterController.error.value
      ? const SizedBox.shrink()
      : FloatingActionButton(
          onPressed: () {
            showCreateGroupePopup(context, 2, (nom, Frequence) {
              print('Nom groupe saisi : $nom');
              print('Frequence saisit $Frequence');
              final frequenceId = ajouterController.getFrequenceId(Frequence);
              ajouterController.creerGroupe(nom, "2", '$frequenceId');
            });
          },
          child: const Icon(Icons.add),
        ),
),

        appBar: AppBar(
          backgroundColor: Color(0xFF0A2149),
          title: const Text('Liste des groupes rotatifs',
              style: TextStyle(color: Colors.white)),
          leading: BackButton(color: Colors.white),
          centerTitle: true,
        ),
        body: Obx(() => ajouterController.isLoading.value
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: 5, // Nombre d'éléments de shimmer
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  margin: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 150,
                                        height: 20,
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                      Container(
                                        width: 100,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            : ajouterController.error.value
                ? Center(
                    child:
                        Text('Erreur: Impossible de se connecter au serveur'))
                : ajouterController.groupes.isEmpty
                    ? Center(child: Text('Aucun groupe trouvé'))
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: ajouterController.groupes
                                  .where((groupe) => groupe.typeGroupeId == 2)
                                  .length, // Replace with actual data length
                              itemBuilder: (context, index) {
                                return afficheGroupe(
                                    index,
                                    ajouterController.groupes
                                        .where((groupe) =>
                                            groupe.typeGroupeId == 2)
                                        .toList()[index]);
                              },
                            ),
                          ),
                        ],
                      )));
  }
}

Container afficheGroupe(int index, Groupe groupe) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue[100],
        child: const Icon(Icons.group, color: Colors.blue),
      ),
      title: Text(
        groupe.nom,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            'Fréquence: ${groupe.frequenceId != null ? getFrequenceLabel(groupe.frequenceId!) : 'Non spécifiée'}',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          Text(
            'Montant: ${groupe.montantTotal} XOF',
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
      onTap: () {
        // Navigate to group details
        print('Appuyer avec succes');
        Get.to(() => EpargneGroupeePage(), arguments: {
          'groupe': groupe,
        });
      },
    ),
  );
}
