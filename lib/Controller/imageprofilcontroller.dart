import 'package:get/get.dart';

class ImageProfileController extends GetxController {
  var profileImagePath = ''.obs;

  void updateProfileImage(String path) {
    profileImagePath.value = path;
  }
}