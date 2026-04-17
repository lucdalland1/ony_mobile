import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/onypay/loginOnypay.dart';
import 'package:onyfast/Api/onypay/paiementsOtp.dart';
import 'package:onyfast/Controller/NewTokenSecours/NewTokenSecours.dart';
import 'package:onyfast/Services/deconnexionUser.dart';
import 'package:onyfast/model/Onypay/payementEnAttente.dart';
import 'package:onyfast/utils/device.dart';

class OnyPayController extends GetxController {
  static OnyPayController get to => Get.find();

  final storage = GetStorage();
  RxList<PendingPayment> pendingPayments = <PendingPayment>[].obs;
  final AuthOnyPayService _authService = AuthOnyPayService();
  final PaiementOnyPayService _paiementService = PaiementOnyPayService();

  /// 🔐 Token
  RxnString token = RxnString();

  /// 👤 User data
  Rxn<Map<String, dynamic>> user = Rxn<Map<String, dynamic>>();

  /// ⏳ Loader
  RxBool isLoading = false.obs;

  /// 📲 Device
  String device = "device-mobile-001";

  @override
  Future<void> onInit() async {
    super.onInit();
    _loadToken();
    device = (await getDeviceIMEI())!;
  }

  /// 🔄 Charger token depuis storage
  void _loadToken() {
    final storedToken = storage.read('onyPayToken');
    if (storedToken != null) {
      token.value = storedToken;
      _paiementService.setToken(storedToken);
    }
  }

  /// 💾 Sauvegarder token
  void _saveToken(String newToken) {
    token.value = newToken;
    storage.write('onyPayToken', newToken);
    _paiementService.setToken(newToken);
  }

  Future<void> loginAndLogoutAutomatique(String phone, String pwd) async {
    var connexion = await login(phone: phone, password: pwd);
    if (connexion != false) {
      if (connexion['success'] as bool == false) {
        print('🔥 🔥 il ya erreur  ');
        // Redirection vers l'écran d'accueil
        await logoutUser();
      } else {
        print('🔥 🔥 Tout est bon ');
      }
    }
  }

  /// 🔐 LOGIN
  Future login({
    required String phone,
    required String password,
  }) async {
    isLoading.value = true;
    device = (await getDeviceIMEI())!;

    final result = await _authService.login(
      phone: phone,
      password: password,
      device: device,
    );
    if (result != null) {
      return result;
      // final newToken = result['token']; // adapte si besoin
      // _saveToken(newToken);

      // await getUser();
    }

    isLoading.value = false;
    return false;
  }

  /// 👤 GET USER
  Future<void> getUser() async {
    isLoading.value = true;

    final result = await _authService.me();

    if (result != null) {
      user.value = result;
    }

    isLoading.value = false;
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {
    isLoading.value = true;

    await _authService.logout();

    token.value = null;
    user.value = {};
    storage.erase();

    isLoading.value = false;
  }

  /// 📲 OTP PENDING
  Future<void> loadPendingOtp() async {
    device = (await getDeviceIMEI())!;

    final response =
        await _paiementService.payementOtpEnAttente(device: device);
    print(response.toString());

    // On remplit le tableau RxList
    pendingPayments.value = response.data;
    print('📱📱 Bien Recuperer');
  }

  /// ✅ VALIDATE OTP
  Future<Map<String, dynamic>?> validateOtp({
    required String paymentId,
    required String code,
  }) async {

    device = (await getDeviceIMEI())!;
    return await _paiementService.validateOtp(
      paymentId: paymentId,
      code: code,    
    );
  }

  /// 🔁 RESEND OTP
  Future<Map<String, dynamic>?> renvoyerOtp({
    required int paymentId,
  }) async {
    device = (await getDeviceIMEI())!;
    return await _paiementService.renvoyerOtp(
      device: device,
      paymentId: paymentId.toString(),
      token: SecureTokenController.to.onyPayToken.value!,
    );
  }
}
