import 'package:get/get.dart';

class FormController extends GetxController {
  var city = ''.obs;
  var name = ''.obs;
  var firstName = ''.obs;
  var email = ''.obs;
  var address = ''.obs;
  var phone = ''.obs;
  var selectedGenre = ''.obs;
  
  var numero_piece = ''.obs;

  void updateFirstName(String value) {
    numero_piece.value = value;
  }

  // Méthode pour valider le formulaire
  bool validate() {
    return city.value.isNotEmpty &&
           name.value.isNotEmpty &&
           firstName.value.isNotEmpty &&
           email.value.isNotEmpty &&
           address.value.isNotEmpty &&
           phone.value.isNotEmpty &&
           selectedGenre.value.isNotEmpty;
  }
}