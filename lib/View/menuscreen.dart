import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onyfast/Controller/NewTokenSecours/NewTokenSecours.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/Controller/features/features_controller.dart';
import 'package:onyfast/Services/deconnexionUser.dart';
import 'package:onyfast/Services/push_notification_service.dart';
import 'package:onyfast/View/chatia/chat_ia.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Widget/chargementpopup.dart';
import 'package:onyfast/Widget/dialog.dart';
import 'package:onyfast/utils/testInternet.dart';
import 'package:onyfast/verificationcode.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Controller/navigationcontroller.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:onyfast/Api/user_inscription.dart';
import 'package:onyfast/View/BottomView/accueil.dart';
import 'package:onyfast/View/BottomView/service.dart';
import 'package:onyfast/View/BottomView/activite.dart';
import 'package:onyfast/View/BottomView/profiluser.dart';
import 'package:onyfast/View/Activit%C3%A9/abonnement.dart';
import 'package:onyfast/Controller/UserLocalController.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:onyfast/View/Sousdistributeur/sousdistributeurs.dart';

import '../utils/logout.dart';
// ignore_for_file: use_key_in_widget_constructors

// Contrôleur pour gérer l'état du drawer
// Nouveau nom
class GlobalDrawerController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final shouldOpenDrawer = false.obs;

  void openDrawer() {
    final state = scaffoldKey.currentState;
    if (state != null && state.mounted) {
      state.openEndDrawer();
    } else {
      // Déclencher l'ouverture via observable
      shouldOpenDrawer.value = true;
      Future.delayed(Duration(milliseconds: 50), () {
        shouldOpenDrawer.value = false;
      });
    }
  }

  void closeDrawer() {
    scaffoldKey.currentState?.closeEndDrawer();
  }
}
// Widget du Drawer global

class GlobalEndDrawer extends StatefulWidget {
  const GlobalEndDrawer({super.key});

  @override
  State<GlobalEndDrawer> createState() => _GlobalEndDrawerState();
}

class _GlobalEndDrawerState extends State<GlobalEndDrawer> {

  Widget _cupertinoMenuItem(Map<String, dynamic> item, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          final void Function(BuildContext) open =
              item['page'] as void Function(BuildContext);
          open(context);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              // Icône avec container stylé
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: globalColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item['icon'],
                  color: globalColor,
                  size: 22,
                ),
              ),

              SizedBox(width: 15),

              // Label avec flex
              Expanded(
                child: Text(
                  item['label'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.black,
                    decoration: TextDecoration.none,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),

              // Flèche avec animation subtle
              Icon(
                CupertinoIcons.forward,
                color: globalColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  final GetStorage storage = GetStorage();
  final UserLocalController userLocalCtrl = Get.put(UserLocalController());

  @override
  Widget build(BuildContext context) {
    ValidationTokenController.to.validateToken();
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth * 0.75;
    var user = storage.read('userInfo') ?? {};
    print("voila $user");

    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        backgroundColor: CupertinoColors.systemBackground,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: Container(
          color: CupertinoColors.systemBackground,
          child: SafeArea(
            child: Column(
              children: [
                // Header du drawer
                Container(
                  padding: EdgeInsets.all(20.dp),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.zero,
                    color: globalColor.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30.dp,
                        backgroundColor: globalColor,
                        child: Icon(
                          CupertinoIcons.person_fill,
                          size: 30.dp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 15.dp),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() => Text(
                                  userLocalCtrl.nom,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                )),
                            SizedBox(height: 4.dp),
                            Text(
                              '+${user['telephone'] ?? ''}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      SizedBox(
                        height: 15.w,
                      ),
                      // _buildDrawerItem(
                      //   icon: CupertinoIcons.home,
                      //   title: 'Accueil',
                      //   onTap: () {
                      //     Get.back();
                      //     Get.find<NavigationController>().setIndex(0);
                      //   },
                      // ),
                      _buildDrawerItem(
                        icon: CupertinoIcons.square_list,
                        title: 'Abonnement',
                        onTap: () {
                          Get.back();
                          // Get.find<NavigationController>().setIndex(3);
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (_) => AbonnementScreen()));
                        },
                      ),
                      // _buildDrawerItem(
                      //   icon: CupertinoIcons.person_2,
                      //   title: 'Sous distributeurs',
                      //   onTap: () {
                      //     Get.back();
                      //     // Get.find<NavigationController>().setIndex(3);
                      //     Navigator.push(
                      //         context,
                      //         CupertinoPageRoute(
                      //             builder: (_) => SousDistributeursPage()));
                      //   },
                      // ),
                      _buildDrawerItem(
                        icon: CupertinoIcons.creditcard,
                        title: 'RIB',
                        onTap: () {
                          Get.back();
                          //  Get.find<NavigationController>().setIndex(2);
                          showComingSoon(context);
                        },
                      ),
                      // _buildDrawerItem(
                      //   icon: CupertinoIcons.person,
                      //   title: 'Profil',
                      //   onTap: () {
                      //     Get.back();
                      //     Get.find<NavigationController>().setIndex(3);
                      //   },
                      // ),
                      Divider(height: 1.dp, thickness: 1),
                      _buildDrawerItem(
                        icon: CupertinoIcons.settings,
                        title: 'Paramètres',
                        onTap: () {
                          Get.back();
                          Get.find<NavigationController>().setIndex(3);
                          // Naviguez vers la page des paramètres
                        },
                      ),
                      _buildDrawerItem(
                          icon: CupertinoIcons.question_circle,
                          title: 'Support',
                          onTap: () async {
                            Get.back();
                            bool isConnected = await hasInternetConnection();

                            if (isConnected) {
                              print('Connexion Internet disponible');
                            } else {
                              return;
                            }
                            chargementDialog();
                            final service = FeaturesService();

                            final isActive = await service
                                .isFeatureActive(AppFeature.chatIA);

                            if (isActive) {
                              while (Get.isDialogOpen ?? false) {
                                Get.back();
                              }
                              Get.to(() => MosalisichatScreen(),
                                  transition: Transition.cupertino);
                            } else {
                              while (Get.isDialogOpen ?? false) {
                                Get.back();
                              }
                               SnackBarService.error(
                                '❌ Pour des raisons de maintenance, Le chat IA est momentainément suspendu. Nos équipes travaillent d\'arrache-pied pour son rétablissement.\nVeuillez réessayer plus tard.');
                            }
                           
                          }
                          // Navigator.pop(context);

                          // Naviguez vers la page à propos

                          ),
                      /* _buildDrawerItem(
                        icon: CupertinoIcons.question_circle,
                        title: 'Support',
                        onTap: () {
                          Get.back();
                          //  Get.to(MosalisichatScreen(), transition: Transition.cupertino);
                          // showModalBottomSheet(
                          //   context: context,
                          //   backgroundColor: Colors.transparent,
                          //   isScrollControlled: true,
                          //   shape: const RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.vertical(
                          //         top: Radius.circular(20)),
                          //   ),
                          //   builder: (_) => Container(
                          //     color: Colors.transparent,
                          //     child: Container(
                          //       width: double.infinity,
                          //       decoration: const BoxDecoration(
                          //         color: Colors.white,
                          //         borderRadius: BorderRadius.vertical(
                          //             top: Radius.circular(20)),
                          //       ),
                          //       child: Padding(
                          //         padding: const EdgeInsets.symmetric(
                          //             horizontal: 20, vertical: 15),
                          //         child: Column(
                          //           mainAxisSize: MainAxisSize.min,
                          //           children: [
                          //             // Barre de glissement
                          //             Container(
                          //               height: 6,
                          //               width: 30.w,
                          //               margin:
                          //                   const EdgeInsets.only(bottom: 20),
                          //               decoration: BoxDecoration(
                          //                 color: globalColor,
                          //                 borderRadius:
                          //                     BorderRadius.circular(20),
                          //               ),
                          //             ),

                          //             const Text(
                          //               'Contacter le support',
                          //               style: TextStyle(
                          //                   fontSize: 18,
                          //                   fontWeight: FontWeight.bold),
                          //             ),
                          //             const SizedBox(height: 20),

                          //             // Message
                          //             ListTile(
                          //               leading: const Icon(Icons.phone,
                          //                   color: Colors.blue),
                          //               title: const Text(
                          //                   'Contacter par téléphone'),
                          //               onTap: () async {
                          //                 Navigator.pop(context);
                          //                 final Uri phoneUri = Uri(
                          //                     scheme: 'tel',
                          //                     path:
                          //                         '+242065891493'); // ou avec indicatif : 'tel:+242057757406'

                          //                 if (await canLaunchUrl(phoneUri)) {
                          //                   await launchUrl(phoneUri);
                          //                 } else {
                          //                   SnackBarService.warning(
                          //                     'Impossible de lancer l\'appel téléphonique.',
                          //                   );
                          //                 }
                          //               },
                          //             ),

                          //             // WhatsApp
                          //             ListTile(
                          //               leading: SvgPicture.asset(
                          //                 'asset/whatsapp.svg',
                          //                 color: Colors.green,
                          //                 width: 24.0,
                          //                 height: 24.0,
                          //               ),
                          //               title: const Text(
                          //                   'Contacter via WhatsApp'),
                          //               onTap: () async {
                          //                 Navigator.pop(context);
                          //                 final Uri whatsappUrl = Uri.parse(
                          //                     'https://wa.me/242057757406');

                          //                 if (await canLaunchUrl(whatsappUrl)) {
                          //                   final bool launched =
                          //                       await launchUrl(
                          //                     whatsappUrl,
                          //                     mode: LaunchMode
                          //                         .externalApplication,
                          //                   );

                          //                   if (!launched) {
                          //                     SnackBarService.warning(
                          //                         'Impossible d\'ouvrir WhatsApp.');
                          //                   }
                          //                 } else {
                          //                   SnackBarService.warning(
                          //                       'WhatsApp n\'est pas disponible.');
                          //                 }
                          //               },
                          //             ),

                          //             // Email
                          //             ListTile(
                          //               leading: const Icon(
                          //                   Icons.email_outlined,
                          //                   color: Colors.red),
                          //               title:
                          //                   const Text('Contacter par email'),
                          //               onTap: () async {
                          //                 Navigator.pop(context);

                          //                 try {
                          //                   final Email email = Email(
                          //                     body: '',
                          //                     subject: 'Assistance Onyfast',
                          //                     recipients: [
                          //                       'assistance@onyfast.com'
                          //                     ],
                          //                   );

                          //                   await FlutterEmailSender.send(
                          //                       email);
                          //                 } catch (error) {
                          //                   SnackBarService.warning(
                          //                     'Aucune application email disponible.',
                          //                   );
                          //                 }
                          //               },
                          //             ),

                          //             const SizedBox(height: 10),
                          //             TextButton(
                          //               onPressed: () => Navigator.pop(context),
                          //               child: const Text('Fermer'),
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // );

                          // Naviguez vers la page d'aide
                        },
                      ), */
                      Divider(height: 1.dp, thickness: 1),
                      _buildDrawerItem(
                        icon: CupertinoIcons.square_arrow_right,
                        title: 'Déconnexion',
                        onTap: () {
                          Get.back();

                          _showLogoutDialog(context);
                        },
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),

                // Footer
                Padding(
                  padding: EdgeInsets.all(16.dp),
                  child: Text(
                    'Version 3.0.2',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? CupertinoColors.destructiveRed : globalColor,
        size: 21.dp,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color:
              isDestructive ? CupertinoColors.destructiveRed : Colors.black87,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.dp, vertical: 4.dp),
    );
  }

  void _showLogoutDialog(BuildContext context) {

    Get.dialog(
  AppDialog(
    title: "Confirmation",
    body: "Êtes-vous sûr de vouloir vous déconnecter ?",
    actions: [
      AppDialogAction(
        label: "Annuler",
        onPressed: () => Get.back(),
      ),
      AppDialogAction(
        label: "Confirmer",
        isDestructive: true,
        onPressed: ()async {
          Get.back();
          CodeVerification().show(Get.context!, () async {
                // bool deco = false;
                if (!Get.isRegistered<AuthController>()) return;
                
                await logoutUser();
                // if (deco==false) {
                //   SnackBarService.error(
                //       'Erreur lors de la déconnexion.');
                //   return;
                // }

                // Déconnexion réussie
                print('🧹 Déconnexion réussie');

                // SnackBarService.success('Déconnecté avec succès');
              });
        },
      ),
    ],
  ),
);

    
  }
}

class MenuScreen extends StatefulWidget {
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final NavigationController navigationController = Get.find();
  final drawerController = Get.put(GlobalDrawerController());
  late CupertinoTabController _tabController;
  late Worker _worker; // Ajouter cette ligne

  @override
  void initState() {
    super.initState();
    ValidationTokenController.to.validateToken();
    _tabController = CupertinoTabController(
      initialIndex: navigationController.selectedIndex.value,
    );
    _worker = ever(navigationController.selectedIndex, (index) {
      if (!mounted) return; // <-- Vérifie que le widget est monté
      if (_tabController.index != index) {
        setState(() {
          _tabController.index = index;
        });
      }
    });
  }

  @override
  void dispose() {
    _worker.dispose(); // Désactive l'écouteur
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Accueil(),
      ActivityPage(),
      SousDistributeursPage(),
      ProfilePage(),
    ];

    // Calculs responsifs
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;

    // Hauteurs adaptatives
    final tabBarHeight =
        isSmallScreen ? 55.dp : (isMediumScreen ? 58.dp : 60.dp);
    final iconSize = isSmallScreen ? 20.dp : (isMediumScreen ? 21.dp : 22.dp);
    final iconWidth = isSmallScreen ? 23.dp : (isMediumScreen ? 24.dp : 25.dp);

    return Scaffold(
      backgroundColor: Colors.white,
      key: drawerController.scaffoldKey,
      endDrawer: GlobalEndDrawer(),
      body: CupertinoTabScaffold(
        backgroundColor: CupertinoColors.systemBackground,
        controller: _tabController,
        tabBar: CupertinoTabBar(
          height: tabBarHeight,
          onTap: (index) {
            navigationController.setIndex(index);
            ValidationTokenController.to.validateToken();
          },
          backgroundColor: CupertinoColors.systemBackground,
          activeColor: globalColor,
          inactiveColor: Colors.grey.shade400,
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300.withOpacity(0.5),
              width: 0.5,
            ),
          ),
          iconSize: iconSize,
          items: [
            BottomNavigationBarItem(
              icon:
                  _buildIcon('asset/accueil-gris.svg', 0, iconSize, iconWidth),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon('asset/activites.svg', 1, iconSize, iconWidth),
              label: 'Activité',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.store, 2, iconSize+1, iconWidth, ),
              label: 'Points Onyfast',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon('asset/pprofile.svg', 3, iconSize, iconWidth),
              label: 'Profil',
            ),
          ],
        ),
        tabBuilder: (context, index) {
          return CupertinoTabView(
            builder: (context) {
              return pages[index];
            },
          );
        },
      ),
    );
  }

  Widget _buildIcon(var assetPath, int index, double height, double width ,) {
    return Obx(() {
      final isSelected = navigationController.selectedIndex.value == index;
      return AnimatedContainer(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 2.dp),
        child: AnimatedScale(
          scale: isSelected ? 1.1 : 1.0,
          duration: Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: 
           assetPath.runtimeType==String?
          SvgPicture.asset(
            assetPath,
            height: height,
            width: width,
            colorFilter: isSelected
                ? ColorFilter.mode(globalColor, BlendMode.srcIn)
                : ColorFilter.mode(Colors.grey.shade400, BlendMode.srcIn),
          ):Icon(
        assetPath as IconData,
        size: height,
        color: isSelected ? globalColor : Colors.grey.shade400,
      )
          ,
        ),
      );
    });
  }
}
