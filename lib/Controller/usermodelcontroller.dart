import 'package:get/get.dart';

import '../model/user_model.dart';

class UserController extends GetxController {
  var user = UserModel(name: "", email: "", createdAt:"", updatedAt: "", organisationId:0, prenom:"", telephone:"", adresse:"", typeUserId:0, profilePhotoUrl:"").obs;

  void updateUser(UserModel newUser) {
    user.value = newUser;
  }
}