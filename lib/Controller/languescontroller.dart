import 'package:get/get.dart';

enum AppLanguage { french, english, spanish }

class AppController extends GetxController {
  var language = AppLanguage.french.obs;

  void changeLanguage(AppLanguage newLanguage) {
    language.value = newLanguage;
  }
}