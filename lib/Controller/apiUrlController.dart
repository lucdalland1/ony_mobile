import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiEnvironmentController extends GetxController {
  static ApiEnvironmentController get to => Get.find();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _isProdKey = 'is_prod_environment';

  /// ✅ PROD par défaut
  final RxBool isProd = true.obs;

  static const String _prodBaseUrl = 'https://pro.onyfastbank.com/api';
  static const String _testBaseUrl = 'https://test.onyfastbank.com/api';

  @override
  void onInit() {
    super.onInit();
    loadEnvironment();
  }

  /// Retourne l'URL globale utilisée dans toute l'application
  String get baseUrl =>
      isProd.value ? _prodBaseUrl : _testBaseUrl;

  /// Sauvegarder l'environnement
  Future<void> setIsProd(bool value) async {
    await _storage.write(
      key: _isProdKey,
      value: value.toString(),
    );

    isProd.value = value;
  }

  /// Charger l'environnement depuis le secure storage
  Future<void> loadEnvironment() async {
    final storedValue = await _storage.read(key: _isProdKey);

    if (storedValue != null) {
      isProd.value = storedValue == 'true';
    } else {
      // Si rien en base → PROD
      isProd.value = true;
    }
  }

  /// Reset (revient en PROD)
  Future<void> resetEnvironment() async {
    await _storage.delete(key: _isProdKey);
    isProd.value = true;
  }
}
