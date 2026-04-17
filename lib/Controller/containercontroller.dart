import 'package:get/get.dart';

class ContainerController extends GetxController {
  // Liste observable pour stocker les données des conteneurs
  var containers = <String>[
    'asset/carte-virtuelle.png',
  ].obs;
  var second = <String>['asset/carte-onyfast-vierge.png'].obs;

  // Méthode pour ajouter un conteneur

  void addContainer() {
    containers.add('asset/carte-virtuelle.png'); // Ajouter un nouveau conteneur
  }

  // Méthode pour supprimer un conteneur
  void removeContainer() {
    if (containers.isNotEmpty) {
      containers.removeLast(); // Supprimer le dernier conteneur
    }
  }
}
