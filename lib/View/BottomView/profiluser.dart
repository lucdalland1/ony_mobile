import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:onyfast/Controller/Abonnement/Abonnementencourscontroller.dart';
import 'package:onyfast/Controller/NewTokenSecours/NewTokenSecours.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/Controller/numero_status_mobile_money.dart';
import 'package:onyfast/Controller/verou/verroucontroller.dart';
import 'package:onyfast/Services/push_notification_service.dart';
import 'package:onyfast/View/BottomView/widgets/widgetAbonnement.dart';
import 'package:onyfast/View/OnyPay/listedesPayementEnAttentes.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Widget/dialog.dart';
import 'package:onyfast/utils/codeParainage.dart';
import 'package:onyfast/utils/logout.dart';
import 'package:onyfast/verificationcode.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:onyfast/View/chatia/chat_ia.dart';
import 'package:onyfast/Api/user_inscription.dart';
import 'package:onyfast/View/Activité/parametre.dart';
import 'package:onyfast/View/Activité/abonnement.dart';
import 'package:onyfast/Controller/UserLocalController.dart';
import 'package:onyfast/View/Activité/info_personnelle.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:onyfast/View/Sousdistributeur/sousdistributeurs.dart';
import 'package:onyfast/Api/piecesjustificatif_Api/pieces_justificatif_api.dart';
import 'package:onyfast/View/Activité/verification_identite/verifier_mon_compte.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  final UserLocalController userLocalCtrl = Get.put(UserLocalController());
  final AuthController deconnexion = Get.find();
  PiecesController controllerTest = Get.find();
  final GetStorage storage = GetStorage();

  late AnimationController _animationController;
  late AnimationController _headerAnimationController;
  late AnimationController _subscriptionAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    AbonnementEncoursController.to.fetchAbonnement();
    AppSettingsController.to.setInactivity(true);

    _subscriptionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    controllerTest.fetchPieces();
    Get.put(RechargeStatusController()).fetchRechargeStatus();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
          parent: _headerAnimationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _headerAnimationController.dispose();
    _subscriptionAnimationController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> menuItems = [
    {
      'icon': CupertinoIcons.person,
      'label': 'Informations personnelles',
      'page': (BuildContext context) {
        Get.to(InformationsPersonnellesPage(),
            transition: Transition.cupertino);
      }
    },
    {
      'icon': CupertinoIcons.clock,
      'label': 'Paiements en attente',
      'page': (BuildContext context) {
        CodeVerification().show(context, () async {
          if (Navigator.of(context).canPop()) Navigator.pop(context);
          Get.to(PaiementsEnAttentePage(), transition: Transition.cupertino);
        });
      }
    },
    {
      'icon': CupertinoIcons.creditcard,
      'label': 'Associer mon compte bancaire',
      'page': (BuildContext context) => showComingSoon(context),
    },
    {
      'icon': CupertinoIcons.check_mark_circled_solid,
      'label': 'Vérifier mon identité',
      'page': (BuildContext context) {
        Get.to(VerifierIdentiteScreen(), transition: Transition.cupertino);
      }
    },
    {
      'icon': CupertinoIcons.square_list,
      'label': 'Abonnements',
      'page': (BuildContext context) {
        Get.to(AbonnementScreen(), transition: Transition.cupertino);
      }
    },
    {
      'icon': CupertinoIcons.creditcard,
      'label': 'Mon RIB',
      'page': (BuildContext context) => showComingSoon(context),
    },
    {
      'icon': CupertinoIcons.settings,
      'label': 'Paramètres',
      'page': (BuildContext context) {
        Get.to(ParametresScreen(), transition: Transition.cupertino);
      }
    },
    {
      'icon': CupertinoIcons.question_circle,
      'label': 'Support',
      'page': (BuildContext context) {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => Container(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 5.w, vertical: 2.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 0.7.h,
                      width: 30.w,
                      margin: EdgeInsets.only(bottom: 2.h),
                      decoration: BoxDecoration(
                        color: globalColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    Text(
                      'Contacter le support',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    ListTile(
                      leading:
                          const Icon(Icons.phone, color: Colors.blue),
                      title: Text('Contacter par téléphone',
                          style: TextStyle(fontSize: 11.sp)),
                      onTap: () async {
                        Navigator.pop(context);
                        final Uri phoneUri =
                            Uri(scheme: 'tel', path: '+242065891493');
                        if (await canLaunchUrl(phoneUri)) {
                          await launchUrl(phoneUri);
                        } else {
                          SnackBarService.warning(
                              'Impossible de lancer l\'appel téléphonique.');
                        }
                      },
                    ),
                    ListTile(
                      leading: SvgPicture.asset(
                        'asset/whatsapp.svg',
                        color: Colors.green,
                        width: 6.w,
                        height: 6.w,
                      ),
                      title: Text('Contacter via WhatsApp',
                          style: TextStyle(fontSize: 11.sp)),
                      onTap: () async {
                        Navigator.pop(context);
                        final Uri whatsappUrl =
                            Uri.parse('https://wa.me/242057757406');
                        if (await canLaunchUrl(whatsappUrl)) {
                          await launchUrl(whatsappUrl,
                              mode: LaunchMode.externalApplication);
                        } else {
                          SnackBarService.warning(
                              'WhatsApp n\'est pas disponible.');
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.email_outlined,
                          color: Colors.red),
                      title: Text('Contacter par email',
                          style: TextStyle(fontSize: 11.sp)),
                      onTap: () async {
                        Navigator.pop(context);
                        try {
                          final Email email = Email(
                            body: '',
                            subject: 'Assistance Onyfast',
                            recipients: ['assistance@onyfast.com'],
                          );
                          await FlutterEmailSender.send(email);
                        } catch (error) {
                          SnackBarService.warning(
                              'Aucune application email disponible.');
                        }
                      },
                    ),
                    SizedBox(height: 1.h),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Fermer',
                          style: TextStyle(fontSize: 11.sp)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    },
  ];

  @override
  Widget build(BuildContext context) {
    AppSettingsController.to.setInactivity(true);
    var user = storage.read('userInfo') ?? {};
    var nom = storage.read('prenom') ?? '';

    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ── Header ──
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(6.w),
                        bottomRight: Radius.circular(6.w),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              CupertinoColors.systemGrey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // ── Avatar + badge ──
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                              onTap: () => HapticFeedback.lightImpact(),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: globalColor.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 12.w,
                                  backgroundColor:
                                      globalColor.withOpacity(0.1),
                                  child: Icon(
                                    CupertinoIcons.person_fill,
                                    size: 13.w,
                                    color: globalColor,
                                  ),
                                ),
                              ),
                            ),
                            if (AbonnementEncoursController
                                    .to.abonnement.value !=
                                null)
                              Positioned(
                                top: -1.h,
                                right: -8.w,
                                child: GestureDetector(
                                  onTap: () =>
                                      showSubscriptionDetails(context),
                                  child: AnimatedBuilder(
                                    animation:
                                        _subscriptionAnimationController,
                                    builder: (context, child) {
                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 2.5.w,
                                            vertical: 0.5.h),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              couleurAbonnement(
                                                AbonnementEncoursController
                                                    .to
                                                    .abonnement
                                                    .value
                                                    ?.type,
                                              ).withOpacity(0.95),
                                              couleurAbonnement(
                                                AbonnementEncoursController
                                                    .to
                                                    .abonnement
                                                    .value
                                                    ?.type,
                                              ).withOpacity(0.85),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(3.w),
                                          border: Border.all(
                                              color: Colors.white,
                                              width: 2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: couleurAbonnement(
                                                      AbonnementEncoursController
                                                              .to
                                                              .abonnement
                                                              .value
                                                              ?.type ??
                                                          '')
                                                  .withOpacity(0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            AnimatedBuilder(
                                              animation:
                                                  _subscriptionAnimationController,
                                              builder: (context, child) {
                                                final scale = 0.9 +
                                                    (0.1 *
                                                        (0.5 +
                                                            0.5 *
                                                                ((_subscriptionAnimationController
                                                                            .value *
                                                                        2) %
                                                                    1)));
                                                return Transform.scale(
                                                  scale: scale,
                                                  child: Icon(
                                                    iconAbonnement(
                                                        AbonnementEncoursController
                                                                .to
                                                                .abonnement
                                                                .value
                                                                ?.type ??
                                                            ''),
                                                    color: Colors.white,
                                                    size: 4.w,
                                                  ),
                                                );
                                              },
                                            ),
                                            SizedBox(width: 1.w),
                                            Text(
                                              AbonnementEncoursController
                                                      .to
                                                      .abonnement
                                                      .value
                                                      ?.type ??
                                                  '',
                                              style: TextStyle(
                                                decoration:
                                                    TextDecoration.none,
                                                fontSize: 9.sp,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),

                        SizedBox(height: 1.5.h),

                        Visibility(
                          visible: nom != null && nom.isNotEmpty,
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              nom ?? '',
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: globalColor,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ),

                        SizedBox(height: 1.h),

                        Obx(() {
                          if (!SecureTokenController.to.isLoggedIn) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            children: [
                              // ── Téléphone ──
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth: 70.w),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4.w, vertical: 1.h),
                                decoration: BoxDecoration(
                                  color: globalColor.withOpacity(0.05),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  border: Border.all(
                                    color: globalColor.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '+${user['telephone'] ?? SecureTokenController.to.telephone.value}',
                                  style: TextStyle(
                                    decoration: TextDecoration.none,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: globalColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              SizedBox(height: 1.2.h),

                              // ── Code parrainage ──
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  afficherParrainagePopup();
                                },
                                child: Container(
                                  constraints:
                                      BoxConstraints(maxWidth: 70.w),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4.w, vertical: 1.h),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        globalColor.withOpacity(0.1),
                                        globalColor.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                    border: Border.all(
                                      color: globalColor.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(CupertinoIcons.gift,
                                          color: globalColor, size: 4.w),
                                      SizedBox(width: 2.w),
                                      Text(
                                        'Code: ${SecureTokenController.to.parrainageCode.value ?? "N/A"}',
                                        style: TextStyle(
                                          decoration: TextDecoration.none,
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.w600,
                                          color: globalColor,
                                          letterSpacing: 1.2,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(width: 2.w),
                                      Icon(
                                        CupertinoIcons.chevron_right,
                                        color:
                                            globalColor.withOpacity(0.6),
                                        size: 3.5.w,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 2.5.h),

              // ── Menu items ──
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.w),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(5.w),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemGrey
                              .withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ...menuItems.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> item = entry.value;
                          return TweenAnimationBuilder(
                            duration: Duration(
                                milliseconds: 600 + (index * 100)),
                            tween: Tween<double>(begin: 0, end: 1),
                            builder: (context, double value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Column(
                                    children: [
                                      _cupertinoMenuItem(item, context),
                                      if (index < menuItems.length - 1)
                                        Container(
                                          height: 0.5,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 4.w),
                                          color:
                                              CupertinoColors.systemGrey4,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 4.h),

              // ── Bouton déconnexion ──
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 1200),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.w),
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding:
                              EdgeInsets.symmetric(vertical: 2.h),
                          backgroundColor: Colors.red.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.w),
                          ),
                        ),
                        onPressed: () async {
                          HapticFeedback.mediumImpact();
                          CodeVerification().show(context, () async {
                            await SecureTokenController.to
                                .clearSecureStorage();
                            try {
                              await logout().timeout(
                                  const Duration(seconds: 10));
                            } catch (e) {}
                            deconnexion.logout();
                            await storage.erase();
                            await PushNotificationService
                                .clearAllNotifications();
                            await ApiEnvironmentController.to.setIsProd(
                                ApiEnvironmentController.to.isProd.value);
                          });
                        },
                        child: Text(
                          'Se déconnecter',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 6.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cupertinoMenuItem(
      Map<String, dynamic> item, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          HapticFeedback.lightImpact();
          final void Function(BuildContext) open =
              item['page'] as void Function(BuildContext);
          open(context);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
          child: Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: globalColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(3.w),
                ),
                child: Icon(
                  item['icon'],
                  color: globalColor,
                  size: 5.5.w,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  item['label'],
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.black,
                    decoration: TextDecoration.none,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              Icon(
                CupertinoIcons.forward,
                color: globalColor,
                size: 4.5.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showComingSoon(BuildContext context) {
   Get.dialog(
  AppDialog(
    title: "Bientôt disponible",
    body: "Cette fonctionnalité sera disponible prochainement",
    actions: [
      AppDialogAction(
        label: "OK",
        isDestructive: true,
        onPressed: () => Get.back(),
      ),
    ],
  ),
);
}