import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationController extends GetxController {
  final _storage = GetStorage();
  
  // état observable
  RxBool isLocationEnabled = false.obs;
  final String _key = "location_enabled";

  @override
  void onInit() {
    super.onInit();
    // Vérifier nativement les permissions au démarrage
    checkNativeLocationPermission();
  }

  /// Vérifie NATIVEMENT le statut de la permission de localisation
  /// (pas depuis le storage mais depuis le système)
  Future<void> checkNativeLocationPermission() async {
    try {
      // Vérifier le statut actuel de la permission NATIVE
      PermissionStatus status = await Permission.location.status;
      
      // Mettre à jour l'état selon le statut RÉEL de la permission
      isLocationEnabled.value = status.isGranted;
      
      // Synchroniser le storage avec l'état réel
      _storage.write(_key, isLocationEnabled.value);
      
      print('📍 Statut natif de localisation: ${status.toString()}');
      print('📍 isLocationEnabled: ${isLocationEnabled.value}');
    } catch (e) {
      print('❌ Erreur lors de la vérification de la permission: $e');
      isLocationEnabled.value = false;
      _storage.write(_key, false);
    }
  }

  /// Active la localisation en demandant la permission
  Future<bool> enableLocation() async {
    try {
      // Demander la permission
      PermissionStatus status = await Permission.location.request();
      
      // Mettre à jour l'état
      isLocationEnabled.value = status.isGranted;
      _storage.write(_key, status.isGranted);
      
      // Gérer les cas spéciaux
      if (status.isPermanentlyDenied) {
        Get.snackbar(
          'Permission requise',
          'Veuillez activer la localisation dans les paramètres',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
        await openAppSettings();
        return false;
      }
      
      return status.isGranted;
    } catch (e) {
      print('❌ Erreur lors de l\'activation de la localisation: $e');
      return false;
    }
  }

  /// Rafraîchir le statut de la permission (appelé quand l'app revient au premier plan)
  Future<void> refreshPermissionStatus() async {
    await checkNativeLocationPermission();
  }
}