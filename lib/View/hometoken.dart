import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/NewTokenSecours/NewTokenSecours.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/info_user/usercontroller.dart';
import 'package:onyfast/Controller/tokencontroller.dart';
// import 'package:onyfast/Controller/empreintecontroller.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Controller/verou/verroucontroller.dart';
import 'package:onyfast/View/InscriptionSuplementaire/InscritInfoSuplementaire.dart';
import 'package:onyfast/utils/miseAjour.dart';
import 'home.dart';
import 'menuscreen.dart';
import 'package:flutter_device_imei/flutter_device_imei.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
class HomeToken extends StatefulWidget {

  HomeToken({super.key});

  @override
  State<HomeToken> createState() => _HomeTokenState();
}

class _HomeTokenState extends State<HomeToken> {
  // Initialisez les contrôleurs
  final TokenController auth = Get.put(TokenController());

  // final EmpreinteController empreinteCtrl = Get.put(EmpreinteController());
  final GetStorage storage = GetStorage();

  final userCtrl = Get.put(UserMeController());
void getDeviceIMEI() async {
  var imei = await  FlutterDeviceImei.instance.getIMEI();
  print("  ✅  ✅  ✅  ✅  ✅  ✅   Device IMEI/Identifier: $imei");
}

Future<void> initialiserToken() async {
  GetStorage storage= GetStorage();
  //  Rawait storage.erase();
  if (SecureTokenController.to.isLoggedIn) {
     await storage.write('token', SecureTokenController.to.token.value);
  print('Token: ${SecureTokenController.to.token.value}');
 AppSettingsController.to.setInactivity(true);

}

 checkVersion();
  userCtrl.loadMe();
  print('🔥🔥🔥🔥🔥🔥 voila le token sauvergardé ${SecureTokenController.to.token.value}'); 
}

@override
void initState() { 
  super.initState();
  AppSettingsController.to.setInactivity(true);
   ValidationTokenController.to.validateToken();
  initialiserToken();
  
}

  @override
  Widget build(BuildContext context) {
    getDeviceIMEI();
    return Obx(() => SecureTokenController.to.token.value != null ? middleware() : Home());
  }

  Widget middleware() {
    final userInfo = storage.read('userInfo') ?? {};

    final nom = userInfo['name']?.toString() ?? '';
    final prenom = userInfo['prenom']?.toString() ?? '';
    final email = userInfo['email']?.toString() ?? '';

    

if (userCtrl.isLoading.value && userCtrl.user.value == null) {

              return const Scaffold(
                backgroundColor: Colors.white,
                body: Center(child: CupertinoActivityIndicator(
                                color: Color(0xFF1D348C),
                                radius: 30,
                              ),));
            }
            if (userCtrl.errorMessage.isNotEmpty && userCtrl.user.value == null) {
              return Scaffold(
  backgroundColor: Colors.white,
  body: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24.0),
    child: Center(
      child:  Container(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône simple
                Icon(
                  Icons.wifi_off,
                  size: 80,
                  color: Colors.red.shade600,
                ),
                
                const SizedBox(height: 30),
                
                // Titre
                Text(
                  'Connexion Impossible',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 15),
                
                // Message
                Text(
                  'Vérifiez votre connexion internet\net réessayez',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Bouton principal
                ElevatedButton.icon(
                  onPressed: () {
                    userCtrl.refreshMe();
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Réessayer',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F52BA),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
  ),
);
 }
 final user = userCtrl.user.value;
  if (user == null) {
    // Si l'utilisateur est null, afficher le loader ou retourner à l'écran de connexion
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CupertinoActivityIndicator(
          color: Color(0xFF1D348C),
          radius: 30,
        ),
      ),
    );
  }
  print('\n\n\n\n\n\npartie validation user ');
  print('voila le user connecté $userInfo');

  if (userCtrl.user.value!.name.isEmpty || userCtrl.user.value!.prenom.isEmpty||userCtrl.user.value!.email.isEmpty||userCtrl.user.value!.adresse.isEmpty||userCtrl.user.value!.telephone.isEmpty) {
    return InscritInfoSuplementaire();
  }

  return MenuScreen();
}
}
