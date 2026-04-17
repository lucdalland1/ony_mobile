import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppSettingsController extends GetxController {
  // --- Getter statique pour accéder facilement au controller partout
  static AppSettingsController get to => Get.find();

  final _storage = GetStorage();

  // Flags réactifs
  var enableInactivity = true.obs;
  var enableSizer = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Charger les valeurs à l'initialisation
    loadSettings();

    // Sauvegarde automatique à chaque changement
    ever(enableInactivity, (bool value) => _storage.write('enableInactivity', value));
    ever(enableSizer, (bool value) => _storage.write('enableSizer', value));
    
  }

  /// Charge les valeurs depuis GetStorage (peut être appelé à tout moment)
  void loadSettings() {
    enableInactivity.value = _storage.read('enableInactivity') ?? true;
    enableSizer.value = _storage.read('enableSizer') ?? true;
  }

  /// Méthodes pour changer les flags dynamiquement
  void setInactivity(bool enabled) => enableInactivity.value = enabled;
  void setSizer(bool enabled) => enableSizer.value = enabled;
}
