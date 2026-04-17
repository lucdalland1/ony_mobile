import 'dart:async';
import 'package:get/get.dart';
import 'package:onyfast/Api/addresseNetwork/addresseNetworkApi.dart';
import 'package:onyfast/Api/ip/ipapi.dart';
import 'package:onyfast/Api/onypay/loginOnypay.dart';
import 'package:onyfast/Controller/%20manage_cards_controller_v2.dart';
import 'package:onyfast/Controller/Abonnement/Abonnementencourscontroller.dart';
import 'package:onyfast/Controller/NewTokenSecours/NewTokenSecours.dart';
import 'package:onyfast/Controller/OnypayController/PendingPaymentCacheController.dart';
import 'package:onyfast/Controller/OnypayController/onypayController.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/Controller/history/history_activiticontroller.dart';
import 'package:onyfast/Controller/verou/verroucontroller.dart';
import 'package:onyfast/View/home.dart';

import 'package:onyfast/utils/device.dart';
import 'package:onyfast/utils/miseAjour.dart';
import 'Langue/translate.dart';
import 'model/user_model.dart';
import 'Api/user_inscription.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onyfast/verouillage.dart';
import 'package:onyfast/Route/route.dart';
import 'package:onyfast/View/otp_mail.dart';
import 'package:onyfast/View/hometoken.dart';
import 'Controller/usermodelcontroller.dart';
import 'Controller/UserLocalController.dart';
import 'Api/Epargne/depot_individuelle.dart';
import 'package:get_storage/get_storage.dart';
import 'Controller/validationcontroller.dart';
import 'package:onyfast/model/wallet_model.dart';
import 'Controller/identitecartecontroller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:onyfast/Services/token_service.dart';
import 'package:onyfast/Controller/otpcontroller.dart';
import 'package:onyfast/Controller/tokencontroller.dart';
import 'package:onyfast/Controller/CoffreController.dart';
import 'package:onyfast/Controller/transfertcountry.dart';
import 'package:onyfast/Controller/languescontroller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:onyfast/Controller/navigationcontroller.dart';
import 'package:onyfast/Api/Epargne/EpargneIndivituelle.dart';
import 'package:onyfast/Controller/NotificationController.dart';
import 'package:onyfast/Controller/tutoriel/tutocontroller.dart';
import 'package:onyfast/Services/push_notification_service.dart';
import 'package:onyfast/Controller/niveau/niveau_controller.dart';
import 'package:onyfast/Controller/transfert/pays_controller.dart';
import 'package:onyfast/Controller/EpargneIndividuelController.dart';
import 'Controller/RecenteTransaction/recenttransactcontroller.dart';
import 'package:onyfast/Controller/features/features_controller.dart';
import 'package:onyfast/Controller/verifier_identite/type_piece.dart';
import 'package:onyfast/Controller/carte/cartephysiquecontroller.dart';
import 'package:onyfast/Controller/transfert/FraisFixeController.dart';
import 'package:onyfast/Controller/Eparge/EpargneGroupeController.dart';
import 'package:onyfast/Controller/Abonnement/abonnementcontroller.dart';
import 'package:onyfast/Controller/parametre/localisationcontroller.dart';
import 'package:onyfast/View/Merchand/controller/transaction_controller.dart';
import 'package:onyfast/Api/piecesjustificatif_Api/pieces_justificatif_api.dart';
import 'package:onyfast/Controller/transfert/transfert_operator_controller.dart';
import 'package:onyfast/Controller/verifier_identite/voir_justificatifresidencecontroller.dart';

// ignore: unnecessary_import

void main() async {
  // --- DÉPLACÉ: s'assurer du binding avant tout plugin / SystemChrome / GetStorage
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialise Firebase avant d'enregistrer les controllers qui pourraient l'utiliser
  var ip = await getPublicIP();
  final networkInfo = await IpInfoService.getNetworkInfo();

  final body = {
    "telephone": "telephone",
    "password": "password",
    ...?networkInfo?.toJson(),
  };
  final authOnyPay = AuthOnyPayService();

// final result =
// // await authOnyPay.login(
//   phone: "242064100000",
//   password: "password",
//   device: "788fc6b6553d190a",
// );

// if (result != null) {
//   print("Utilisateur connecté");
//   print(result);
// } else {
//   print("Échec connexion OnyPay");
// }
  var deviceskey = await getDeviceIMEI();

  print("✅$deviceskey"
      '✅ Firebase initialized successfully (Main)\n'
      'IP: ${networkInfo?.ipAddress}\n'
      'City: ${networkInfo?.city}\n'
      'ISP: ${networkInfo?.isp}\n'
      '✅✅✅Body: $body');
  await Firebase.initializeApp();
  print('✅ Firebase initialized successfully (Main) ip :$ip');
  await PushNotificationService.initialize();
  print('✅ PushNotificationService initialized successfully (Main)');
  checkVersion();

  // Initialize controllers (après Firebase et GetStorage)
  _initializeControllers();

  final service = FeaturesService();

  final isActive = await service.isFeatureActive(AppFeature.otpWhatssap);

  if (isActive) {
    print('✅ L otp whatssap est di est disponible');
  } else {
    print('✅ L otp whatssap n est  pas disponible');
  }
  await OnyPayController.to.validateOtp(paymentId: "1", code: "33939");
  print('✅ Pending OTP loaded: ');

  runApp(
    // Réactiver le wrapper d'inactivité pour capter les interactions utilisateur
    InactivityWrapper(
      child: FlutterSizer(
        builder: (context, orientation, deviceType) {
          return MyApp();
        },
      ),
    ),
  );
}

// RouteObserver global pour observer les changements de routes
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
void _initializeControllers() {
  // Controllers principaux

  //  Get.put(LocationController());
  Get.put(TransactionsController());
  Get.put(ApiEnvironmentController());
  Get.put(ValidationTokenController());
  Get.put(AppSettingsController());
  Get.put(SecureTokenController(), permanent: true);
  Get.put(NavigationController());
  Get.put(TutorialController());
  Get.put(NiveauController());
  Get.put(TokenController(), permanent: true);
  Get.put(AppController(), permanent: true);
  Get.put(
    LockController(),
    permanent: true,
  ); // Nouveau controller de verrouillage
  Get.put(AuthController());
  Get.put(UserController());
  Get.put(ValidationController());
  Get.put(UserLocalController());

  Get.put(PiecesController());
  Get.put(ListeJustificatifController());
  Get.put(RecentTransactionsController());
  Get.put(Otpcontroller());
  Get.put(AbonnementEncoursController());
  Get.put(TransactionController(), permanent: true);
  Get.put(VerifOtpCode());
  // Contrôleurs lazy pour une meilleure gestion de la mémoire
  Get.lazyPut(() => CoffreController());
  Get.lazyPut(() => PaysController());
  Get.put(TransferController());
  Get.lazyPut(() => IdentityFormController());
  Get.lazyPut(() => DepotController());
  Get.lazyPut(() => TransfertCountryController());
  Get.lazyPut(
    () => EpargneIndividuelleController(service: EpargneIndividuelleService()),
  );
  Get.lazyPut(() => EpargneGroupeController());
  Get.lazyPut(() => TokenService());

  Get.put(EmmettreCartePhysiqueController(), permanent: true);

  Get.put(FraisFixeController());
  Get.put(AbonnementController());
  Get.put(ManageCardsController());
  Get.put(PendingPaymentCacheController(), permanent: true);
  // Models
  Get.put(
    UserModel(
      name: "",
      email: "",
      createdAt: "",
      updatedAt: "",
      organisationId: 0,
      prenom: "",
      telephone: "",
      adresse: "",
      typeUserId: 0,
      profilePhotoUrl: "",
    ),
  );

  Get.put(
    WalletModel(
      id: 0,
      solde: 0.00,
      assignedUserId: 0,
      userId: 0,
      startDate: "",
      createdAt: "",
      updatedAt: "",
    ),
  );

  Get.put(TypePieceController());
  Get.put(NotificationController());
  Get.put(OnyPayController());
  // Get.put(RecentTransactionsController());
}

// Nouveau contrôleur pour gérer le verrouillage
class LockController extends GetxController {
  static LockController get to => Get.find();

  final _isLocked = false.obs;
  final _shouldShowLockAtStart = false.obs;
  Timer? _inactivityTimer;
  DateTime? _lastActivity;
  bool _isDisposed = false;

  // Configuration
  final Duration inactivityTimeout = const Duration(minutes: 30);

  bool get isLocked => _isLocked.value;
  bool get shouldShowLockAtStart => _shouldShowLockAtStart.value;

  @override
  void onInit() {
    super.onInit();
    _checkInitialLockState();
    _resetInactivityTimer();
  }

  void _checkInitialLockState() {
    if (_isDisposed) return;

    try {
      // Vérifie si l'utilisateur a un token
      final tokenController = Get.find<TokenController>();
      final storage = GetStorage();

      // Si token existe ou si l'app a été fermée avec un utilisateur connecté
      if (tokenController.token.isNotEmpty ||
          storage.read('user_logged_in') == true) {
        _shouldShowLockAtStart.value = true;
        _isLocked.value = true;
      }
    } catch (e) {
      // Gérer les erreurs silencieusement
    }
  }

  void lockApp({bool immediate = false}) {
    if (_isDisposed || _isLocked.value) return;
    if (!AppSettingsController.to.enableInactivity.value) return;
    try {
      _isLocked.value = true;
      _inactivityTimer?.cancel();

      // Navigation vers l'écran de verrouillage
      if (Get.currentRoute != '/lock') {
        if (immediate) {
          Get.toNamed('/lock');
        } else {
          // Délai pour permettre une transition fluide
          Future.delayed(const Duration(milliseconds: 100), () {
            if (!_isDisposed && Get.currentRoute != '/lock') {
              Get.toNamed('/lock');
            }
          });
        }
      }
    } catch (e) {
      // Gérer les erreurs silencieusement
    }
  }

  void unlockApp() {
    if (_isDisposed) return;

    try {
      _isLocked.value = false;
      _shouldShowLockAtStart.value = false;
      _resetInactivityTimer();

      final navState = Get.key.currentState;

      // Fermer d'abord tous les dialogs / bottom sheets éventuels
      if (navState != null) {
        while (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
          Get.back();
        }

        // S'il reste plus d'une route → il y a quelque chose sous /lock
        if (navState.canPop()) {
          // On enlève /lock et on revient à la page précédente
          Get.back();
        } else {
          // /lock était seule → on va sur l'écran principal
          Get.offAllNamed(AppRoutes.hometoken);
        }
      } else {
        // Par sécurité : si on n'a pas de navState, on va sur hometoken
        Get.offAllNamed(AppRoutes.hometoken);
      }

      // Marquer l'utilisateur comme connecté
      GetStorage().write('user_logged_in', true);
    } catch (e) {
      // Gérer les erreurs silencieusement
    }
  }

  void resetInactivityTimer() {
    if (_isDisposed || _isLocked.value) return;

    try {
      _lastActivity = DateTime.now();
      _resetInactivityTimer();
    } catch (e) {
      // Gérer les erreurs silencieusement
    }
  }

  void _resetInactivityTimer() {
    if (_isDisposed) return;

    try {
      _inactivityTimer?.cancel();
      _inactivityTimer = Timer(inactivityTimeout, () {
        if (!_isDisposed && !_isLocked.value) {
          // Vérifier si l'utilisateur est en train de taper
          if (!_isUserTyping()) {
            if (AppSettingsController.to.enableInactivity.value) {
              lockApp();
            }
          } else {
            // Si l'utilisateur tape, relancer le timer
            _resetInactivityTimer();
          }
        }
      });
    } catch (e) {
      // Gérer les erreurs silencieusement
    }
  }

  bool _isUserTyping() {
    // Vérifier s'il y a un champ de texte en focus
    try {
      final currentFocus = FocusManager.instance.primaryFocus;
      return currentFocus != null && currentFocus.hasFocus;
    } catch (e) {
      return false;
    }
  }

  void onAppPaused() {
    if (_isDisposed) return;
    if (!AppSettingsController.to.enableInactivity.value) return;

    // Verrouiller immédiatement quand l'app va en arrière-plan
    if (!_isLocked.value) {
      lockApp(immediate: true);
    }
  }

  void onAppResumed() {
    if (_isDisposed) return;

    try {
      // Vérifier si l'app doit être verrouillée au retour
      final tokenController = Get.find<TokenController>();
      if (tokenController.token.isNotEmpty && !_isLocked.value) {
        if (AppSettingsController.to.enableInactivity.value) {
          lockApp(immediate: true);
        }
      }
    } catch (e) {
      // Gérer les erreurs silencieusement
    }
  }

  void logout() {
    if (_isDisposed) return;

    try {
      _isLocked.value = false;
      _shouldShowLockAtStart.value = false;
      _inactivityTimer?.cancel();
      GetStorage().write('user_logged_in', false);
    } catch (e) {
      // Gérer les erreurs silencieusement
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    _inactivityTimer?.cancel();
    super.onClose();
  }
}

class InactivityWrapper extends StatefulWidget {
  final Widget child;

  const InactivityWrapper({super.key, required this.child});

  @override
  State<InactivityWrapper> createState() => _InactivityWrapperState();
}

class _InactivityWrapperState extends State<InactivityWrapper>
    with WidgetsBindingObserver {
  late LockController lockController;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    try {
      lockController = Get.find<LockController>();
    } catch (e) {
      // Handle error if controller not found
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;

    try {
      switch (state) {
        case AppLifecycleState.paused:
          if (SecureTokenController.to.token.value != null) {
            if (!AppSettingsController.to.enableInactivity.value) return;
            lockController.onAppPaused();
          }

          break;
        case AppLifecycleState.resumed:
          if (SecureTokenController.to.token.value != null) {
            if (!AppSettingsController.to.enableInactivity.value) return;
            lockController.onAppResumed();
          }

          break;
        case AppLifecycleState.inactive:
          // Optionnel: verrouiller aussi quand inactive
          break;
        default:
          break;
      }
    } catch (e) {
      // Handle errors silently
    }
  }

  void _onUserActivity() {
    if (_isDisposed) return;

    try {
      if (SecureTokenController.to.token.value != null) {
        print('✅  ✅  ✅  ✅  ✅  ✅   il n');
        lockController.resetInactivityTimer();
      }
    } catch (e) {
      // Handle errors silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _onUserActivity(),
      onPointerMove: (_) => _onUserActivity(),
      onPointerUp: (_) => _onUserActivity(),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _onUserActivity(),
        onPanUpdate: (_) => _onUserActivity(),
        child: widget.child,
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final TokenController auth = Get.put(TokenController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        fontFamily: 'Roboto', // Using Roboto as a consistent font
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(fontSize: 24),
          headlineMedium: TextStyle(fontSize: 20),
          headlineSmall: TextStyle(fontSize: 16),
          titleLarge: TextStyle(fontSize: 16),
          titleMedium: TextStyle(fontSize: 14),
          titleSmall: TextStyle(fontSize: 12),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
          bodySmall: TextStyle(fontSize: 12),
        ),
      ),
      translations: AppTranslations(),
      locale: const Locale('fr', "FR"),
      fallbackLocale: const Locale('fr', 'FR'),

      // Route initiale dynamique basée sur l'état de verrouillage
      home: Obx(() {
        final lockController = Get.find<LockController>();
        AbonnementEncoursController.to.fetchAbonnement();

        if ((lockController.shouldShowLockAtStart || lockController.isLocked) &&
            auth.token.isNotEmpty) {
          return const LockScreen();
        }
        return _getInitialScreen();
      }),

      getPages: [
        ...AppRoutes.routes,
        GetPage(
          name: '/lock',
          page: () => const LockScreen(),
          transition: Transition.noTransition,
        ),
      ],

      unknownRoute: GetPage(
        name: '/unknown',
        page: () =>
            const Scaffold(body: Center(child: Text('Page non trouvée'))),
      ),
    );
  }

  Widget _getInitialScreen() {
    // Logique pour déterminer l'écran initial
    final tokenController = Get.find<TokenController>();
    print(" ✅ voila son token ${SecureTokenController.to.token.value}");
    if (SecureTokenController.to.token.value != null) {
      // Si l'utilisateur a un token, on va vers l'écran principal
      // mais normalement on devrait être sur l'écran de verrouillage
      return const LockScreen();
    }

    // Sinon, écran de connexion ou d'accueil
    return HomeToken(); // Remplacer par votre écran d'accueil/login
  }
}
