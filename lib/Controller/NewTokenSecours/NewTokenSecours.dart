import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'dart:async';

class SecureTokenController extends GetxController {
  static SecureTokenController get to => Get.find();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Timer? _expirationTimer;

  static const String _tokenKey = 'auth_token';
  static const String _telephoneKey = 'telephone_auth';
  static const String _parrainageKey = 'parrainage_code';
  final RxnString parrainageCode = RxnString();
  static const String _codeParrainKey = 'code_parrain';
  static const String _onyPayTokenKey = 'ony_pay_token';

  static const String _typeNotificationIdKey = 'type_notification_id';
  static const String _codeKey = 'otp_code';
  static const String _expirationKey = 'notification_expiration';

  final RxnString codeParrain = RxnString();

  final RxnString token = RxnString();
  final RxnString telephone = RxnString();
  final RxnString onyPayToken = RxnString();
  final RxnString expirationDate = RxnString();

  final RxnInt typeNotificationId = RxnInt(); // 👈 entier
  final RxnString code = RxnString(); // 👈 string
  @override
  void onInit() {
    super.onInit();
    loadToken();
    loadTelephone();
    loadParrainageCode(); // <-- ajoute cette ligne
    loadCodeParrain();
    loadOnyPayToken(); // ✅ ajouté

    loadTypeNotificationId(); // ✅
    loadCode(); // ✅
    checkAndRestartTimer();
    loadExpirationDate(); // ✅ IMPORTANT
  }

  @override
  void onClose() {
    _expirationTimer?.cancel();
    super.onClose();
  }

  Future<void> loadExpirationDate() async {
    expirationDate.value = await _storage.read(key: _expirationKey);
  }

  Future<void> saveTypeNotificationId(int value) async {
    await _storage.write(key: _typeNotificationIdKey, value: value.toString());
    typeNotificationId.value = value;
  }

  Future<void> loadTypeNotificationId() async {
    final data = await _storage.read(key: _typeNotificationIdKey);
    typeNotificationId.value = data != null ? int.tryParse(data) : null;
  }

  Future<void> deleteTypeNotificationId() async {
    await _storage.delete(key: _typeNotificationIdKey);
    typeNotificationId.value = null;
  }

  Future<void> saveOnyPayToken(String newToken) async {
    await _storage.write(key: _onyPayTokenKey, value: newToken);
    onyPayToken.value = newToken;
  }

  Future<void> loadOnyPayToken() async {
    onyPayToken.value = await _storage.read(key: _onyPayTokenKey);
  }

  Future<void> saveCodeParrain(String code) async {
    await _storage.write(key: _codeParrainKey, value: code);
    codeParrain.value = code;
  }

  Future<void> saveCode(String value) async {
    final expiration = DateTime.now().add(const Duration(minutes: 5));

    await _storage.write(key: _codeKey, value: value);
    await _storage.write(
        key: _expirationKey, value: expiration.toIso8601String());

    code.value = value;
    expirationDate.value = expiration.toIso8601String();

    _startExpirationTimer(expiration); // ✅ LANCE LE TIMER
  }

  void _startExpirationTimer(DateTime expiration) {
    _expirationTimer?.cancel();

    final remaining = expiration.difference(DateTime.now());

    if (remaining.isNegative) {
      _handleExpiration();
      return;
    }

    _expirationTimer = Timer(remaining, () {
      _handleExpiration();
    });
  }

  Future<void> _handleExpiration() async {
    await deleteCode();
    await deleteTypeNotificationId();
    await _storage.delete(key: _expirationKey);

    code.value = null;
    typeNotificationId.value = null;
    expirationDate.value = null;

    print("⏰ OTP supprimé automatiquement");
  }

  Future<void> loadCode() async {
    code.value = await _storage.read(key: _codeKey);
  }

  Future<void> checkAndRestartTimer() async {
    final expirationString = await _storage.read(key: _expirationKey);

    if (expirationString == null) return;

    final expiration = DateTime.parse(expirationString);

    if (DateTime.now().isAfter(expiration)) {
      await _handleExpiration();
    } else {
      expirationDate.value = expirationString; // 👈 sync UI
      _startExpirationTimer(expiration);
    }
  }

  bool get hasValidOtp =>
      code.value != null &&
      expirationDate.value != null &&
      DateTime.now().isBefore(DateTime.parse(expirationDate.value!));
  Future<void> deleteCode() async {
    await _storage.delete(key: _codeKey);
    code.value = null;
  }

  Future<void> loadCodeParrain() async {
    codeParrain.value = await _storage.read(key: _codeParrainKey);
  }

  Future<void> deleteOnyPayToken() async {
    await _storage.delete(key: _onyPayTokenKey);
    onyPayToken.value = null;
  }

  Future<void> deleteCodeParrain() async {
    await _storage.delete(key: _codeParrainKey);
    codeParrain.value = null;
  }

  Future<void> saveParrainageCode(String code) async {
    await _storage.write(key: _parrainageKey, value: code);
    parrainageCode.value = code;
  }

  Future<void> loadParrainageCode() async {
    parrainageCode.value = await _storage.read(key: _parrainageKey);
  }

  Future<void> deleteParrainageCode() async {
    await _storage.delete(key: _parrainageKey);
    parrainageCode.value = null;
  }

  Future<void> saveToken(String newToken) async {
    await _storage.write(key: _tokenKey, value: newToken);
    token.value = newToken;
  }

  Future<void> saveTelephone(String newTelephone) async {
    await _storage.write(key: _telephoneKey, value: newTelephone);
    telephone.value = newTelephone;
    await ValidationTokenController.to.validateToken();
  }

  Future<void> loadToken() async {
    token.value = await _storage.read(key: _tokenKey);
  }

  Future<void> loadTelephone() async {
    telephone.value = await _storage.read(key: _telephoneKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _telephoneKey);
    token.value = null;
    telephone.value = null;
  }

  Future<void> clearSecureStorage() async {
    await _storage.deleteAll();
    telephone.value = null;
    token.value = null;
    parrainageCode.value = null;
    codeParrain.value = null;
    onyPayToken.value = null; // ✅ ajouté
    typeNotificationId.value = null; // ✅
    code.value = null; // ✅
  }

  bool get isLoggedIn => token.value != null;
}
