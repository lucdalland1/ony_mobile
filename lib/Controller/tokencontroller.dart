import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../View/home.dart';

class TokenController extends GetxController {
  final GetStorage storage = GetStorage();
  var token = ''.obs;
  var lastActivity = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    _loadSession();
    _startTokenChecker();
  }

  void _loadSession() {
    token.value = storage.read('token') ?? '';
    lastActivity.value = DateTime.parse(storage.read('lastActivity') ?? DateTime.now().toString());
  }

  void _startTokenChecker() {
    Future.delayed(Duration(minutes: 1), () {
      if (_isTokenExpired()) {
        logout();
      }
      _startTokenChecker(); // Vérification périodique
    });
  }

  bool _isTokenExpired() {
    // Token expire après 24h d'inactivité
    return lastActivity.value.add(Duration(hours: 24)).isBefore(DateTime.now());
  }

  void updateActivity() {
    lastActivity.value = DateTime.now();
    storage.write('lastActivity', lastActivity.value.toString());
  }

  Future<void> login(String phone, String password) async {
    try {
      // Simulation de login
      token.value = 'new_token_${DateTime.now().millisecondsSinceEpoch}';
      storage.write('token', token.value);
      updateActivity();
    } catch (e) {
      throw e;
    }
  }

  Future<void> logout() async {
    token.value = '';
    storage.remove('token');
    storage.remove('lastActivity');
    Get.offAll(() => Home());
  }
}