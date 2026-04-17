import 'package:get/get.dart';
import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onyfast/Controller/Abonnement/Abonnementencourscontroller.dart';
import 'package:onyfast/Widget/dialog.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import 'package:onyfast/verificationcode.dart';
import '../Notification/notification.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/utils/testInternet.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/model/abonnement/abonnementModel.dart';
import 'package:onyfast/View/Activit%C3%A9/abonnement_suite.dart';
import 'package:onyfast/Controller/Abonnement/abonnementcontroller.dart';
//     import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_sizer/flutter_sizer.dart';
// import 'package:get/get.dart';
// import 'package:onyfast/Color/app_color_model.dart';
// import 'package:onyfast/Controller/Abonnement/abonnementcontroller.dart';
// import 'package:onyfast/View/Activit%C3%A9/abonnement_suite.dart';
// import 'package:onyfast/model/abonnement/abonnementModel.dart';

// import '../Notification/notification.dart';
// import 'dart:math' show Random;

// class AbonnementScreen extends StatefulWidget {
//   const AbonnementScreen({super.key});

//   @override
//   State<AbonnementScreen> createState() => _AbonnementScreenState();
// }

// class _AbonnementScreenState extends State<AbonnementScreen> {
//   final PageController _pageController = PageController();
//   final AbonnementController controller = Get.find<AbonnementController>();
//   int currentIndex = 0;

//   // Map pour les couleurs des plans
//   final Map<String, Color> planColors = {
//     'basic': Colors.grey[900]!,
//     'premium': const Color(0xFF1234A0),
//     '': const Color.fromARGB(255, 196, 105, 1),
//   };

//     //  '': const Color(0xFFF6A623),

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColorModel.Bluecolor242,
//         title: Text(
//           "Abonnements",
//           style: TextStyle(
//             fontSize: 17.dp,
//             fontWeight: FontWeight.bold,
//             color: AppColorModel.WhiteColor,
//           ),
//         ),
//         centerTitle: true,
//         leading: BackButton(color: Colors.white),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.notifications, color: Colors.white),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 CupertinoPageRoute(builder: (context) => NotificationsPage()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return Center(
//             child: CupertinoActivityIndicator(
//               color: AppColorModel.Bluecolor242,
//             ),
//           );
//         }

//         if (controller.errorMessage.value.isNotEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.error_outline,
//                   size: 50,
//                   color: Colors.red,
//                 ),
//                 SizedBox(height: 16),
//                 Text(
//                   controller.errorMessage.value,
//                   style: TextStyle(color: Colors.red),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () => controller.fetchAbonnements(),
//                   child: Text("Réessayer"),
//                 ),
//               ],
//             ),
//           );
//         }

//         if (controller.abonnements.isEmpty) {
//           return Center(
//             child: Text("Aucun abonnement disponible"),
//           );
//         }

//         return Column(
//           children: [
//             // Indicateur de pages
//             Container(
//               padding: EdgeInsets.symmetric(
//                 vertical: MediaQuery.of(context).size.height * 0.02,
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(
//                   controller.abonnements.length,
//                   (index) => Container(
//                     margin: EdgeInsets.symmetric(
//                       horizontal: MediaQuery.of(context).size.width * 0.01,
//                     ),
//                     width: currentIndex == index
//                         ? MediaQuery.of(context).size.width * 0.03
//                         : MediaQuery.of(context).size.width * 0.02,
//                     height: currentIndex == index
//                         ? MediaQuery.of(context).size.width * 0.03
//                         : MediaQuery.of(context).size.width * 0.02,
//                     decoration: BoxDecoration(
//                       color: currentIndex == index
//                           ? AppColorModel.Bluecolor242
//                           : Colors.grey.shade400,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             // Slides des plans
//             Expanded(
//               child: PageView.builder(
//                 controller: _pageController,
//                 onPageChanged: (index) {
//                   setState(() {
//                     currentIndex = index;
//                   });
//                 },
//                 itemCount: controller.abonnements.length,
//                 itemBuilder: (context, index) {
//                   return AnimatedBuilder(
//                     animation: _pageController,
//                     builder: (context, child) {
//                       double value = 1.0;
//                       if (_pageController.position.haveDimensions) {
//                         value = _pageController.page! - index;
//                         value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
//                       }
//                       return Transform.scale(
//                         scale: Curves.easeOut.transform(value),
//                         child: Opacity(
//                           opacity: value,
//                           child: _buildPlanSlide(controller.abonnements[index], index),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),

//             // Boutons de navigation
//             Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: MediaQuery.of(context).size.width * 0.05,
//                 vertical: MediaQuery.of(context).size.height * 0.015,
//               ),
//               child: SafeArea(
//                 child: Row(
//                   children: [
//                     if (currentIndex > 0)
//                       Expanded(
//                         child: OutlinedButton(
//                           onPressed: () {
//                             _pageController.previousPage(
//                               duration: const Duration(milliseconds: 300),
//                               curve: Curves.easeInOut,
//                             );
//                           },
//                           style: OutlinedButton.styleFrom(
//                             side: BorderSide(color: AppColorModel.Bluecolor242),
//                             padding: EdgeInsets.symmetric(
//                               vertical:
//                                   MediaQuery.of(context).size.height * 0.018,
//                             ),
//                           ),
//                           child: Text(
//                             "Précédent",
//                             style: TextStyle(
//                               color: AppColorModel.Bluecolor242,
//                               fontWeight: FontWeight.bold,
//                               fontSize: MediaQuery.of(context).size.width * 0.04,
//                             ),
//                           ),
//                         ),
//                       ),
//                     if (currentIndex > 0)
//                       SizedBox(width: MediaQuery.of(context).size.width * 0.04),
//                     Expanded(
//                       flex: currentIndex == 0 ? 1 : 2,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           if (currentIndex < controller.abonnements.length - 1) {
//                             _pageController.animateToPage(
//                               currentIndex + 1,
//                               duration: const Duration(milliseconds: 500),
//                               curve: Curves.easeInOutCubic,
//                             );
//                           } else {
//                             Get.to(() => SubscriptionComparisonPage(),
//                               transition: Transition.rightToLeft,
//                               duration: const Duration(milliseconds: 300),
//                             );
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _getPlanColor(controller.abonnements[currentIndex]),
//                           padding: EdgeInsets.symmetric(
//                             vertical: MediaQuery.of(context).size.height * 0.018,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: Text(
//                           currentIndex < controller.abonnements.length - 1
//                               ? "Suivant"
//                               : "Recap",
//                           style: TextStyle(
//                             fontSize: MediaQuery.of(context).size.width * 0.04,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         );
//       }),
//     );
//   }

//   Color _getPlanColor(Abonnement abonnement) {

//     return planColors[abonnement.identifiant.toLowerCase()] ??
//            AppColorModel.Bluecolor242;
//   }

//   // List<String> _buildFeaturesList(Abonnement abonnement) {
//   //   List<String> features = [];
//   //   //*${abonnement.caracteristiques.cartes.virtuelles}*/
//   //   // Cartes virtuelles
//   //   features.add('Carte(s) virtuelle(s)');

//   //   // Carte physique
//   //   if (abonnement.caracteristiques.cartes.physique is bool) {

//   //     if(abonnement.caracteristiques.cartes.physique ){
//   //       features.add('Carte physique');
//   //     }

//   //   } else if (abonnement.caracteristiques.cartes.physique is Map) {
//   //     final cartePhysique = abonnement.caracteristiques.cartes.physique as Map;
//   //     features.add('Carte physique ${cartePhysique['type'] ?? 'Premium'}');
//   //   }

//   //   // Plafonds
//   //   features.add('Plafond: ${abonnement.caracteristiques.plafonds.mensuel}');
//   //   if (abonnement.caracteristiques.plafonds.prets != "0 FCFA") {
//   //     features.add('Prêts: ${abonnement.caracteristiques.plafonds.prets}');
//   //   }

//   //   // Multi-devises
//   //   if (abonnement.caracteristiques.multiDevises is bool) {

//   //     if(abonnement.caracteristiques.multiDevises){
//   //       features.add('Multi-devises');
//   //     }
//   //   } else if (abonnement.caracteristiques.multiDevises is String) {
//   //     features.add(' ${abonnement.caracteristiques.multiDevises}');
//   //   }

//   //   // Objectifs
//   //   if (abonnement.caracteristiques.objectifs is int) {
//   //     features.add(' ${abonnement.caracteristiques.objectifs} objectif(s)');
//   //   } else {
//   //     features.add('Objectifs ${abonnement.caracteristiques.objectifs}');
//   //   }

//   //   // Cashback
//   //   features.add('Cashback ${abonnement.avantages.financiers.cashback}');

//   //   // Frais (seulement si pas "Aucun frais cachés")
//   //   if (abonnement.avantages.financiers.frais != "Aucun frais cachés") {
//   //     features.add('${abonnement.avantages.financiers.frais}');
//   //   }

//   //   // Support
//   //   features.add('Support ${abonnement.avantages.services.support}');

//   //   // Conseiller dédié
//   //   if (abonnement.avantages.services.conseillerDedie) {
//   //     features.add('Conseiller dédié');
//   //   }

//   //   // Lounge aéroport
//   //   if (abonnement.avantages.services.loungeAeroport is bool) {
//   //     if (abonnement.avantages.services.loungeAeroport) {
//   //       features.add('Accès lounge aéroport');
//   //     }
//   //   } else if (abonnement.avantages.services.loungeAeroport is String) {
//   //     features.add('Lounge: ${abonnement.avantages.services.loungeAeroport}');
//   //   }

//   //   // Mode incognito
//   //   if (abonnement.avantages.services.modeIncognito) {
//   //     features.add('Mode incognito');
//   //   }

//   //   return features;
//   // }

//  List<String> _buildFeaturesList(Abonnement abonnement) {
//   List<String> features = [];

//   // Plafonds
//   if (abonnement.caracteristiques?.plafonds?.mensuel != null) {
//     features.add('Plafond: ${abonnement.caracteristiques!.plafonds!.mensuel}');
//   }

//   // Objectifs
//   if (abonnement.caracteristiques?.objectifs != null) {
//     if (abonnement.caracteristiques!.objectifs is int) {
//       features.add('${abonnement.caracteristiques!.objectifs} objectif(s)');
//     } else if (abonnement.caracteristiques!.objectifs is String) {
//       features.add('Objectifs ${abonnement.caracteristiques!.objectifs}');
//     }
//   }

//   // Support
//   if (abonnement.avantages?.services?.support != null) {
//     features.add('Support ${abonnement.avantages!.services!.support}');
//   }

//   // Conseiller dédié
//   if (abonnement.avantages?.services?.conseillerDedie != null) {
//     if (abonnement.avantages!.services!.conseillerDedie == 1 ||
//         abonnement.avantages!.services!.conseillerDedie == true) {
//       features.add('Conseiller dédié');
//     }
//   }

//   // Best for (recommandation d'usage)
//   if (abonnement.bestFor != null && abonnement.bestFor!.isNotEmpty) {
//     features.add('Idéal pour: ${abonnement.bestFor}');
//   }

//   // Ajout dynamique d'autres caractéristiques si elles existent
//   // Vérifier s'il y a d'autres propriétés dans les caractéristiques
//   if (abonnement.caracteristiques != null) {
//     final Map<String, dynamic> caracMap = abonnement.caracteristiques!.toJson();
//     caracMap.forEach((key, value) {
//       if (key != 'plafonds' && key != 'objectifs' && value != null) {
//         // Traiter les autres caractéristiques dynamiquement
//         if (value is bool && value == true) {
//           features.add(_formatKey(key));
//         } else if (value is String && value.isNotEmpty) {
//           features.add('${_formatKey(key)}: $value');
//         } else if (value is int && value > 0) {
//           features.add('${_formatKey(key)}: $value');
//         }
//       }
//     });
//   }

//   // Ajout dynamique d'autres avantages si ils existent
//   if (abonnement.avantages != null) {
//     final Map<String, dynamic> avantagesMap = abonnement.avantages!.toJson();
//     avantagesMap.forEach((key, value) {
//       if (key != 'services' && value != null) {
//         if (value is Map) {
//           final Map<String, dynamic> subMap = value as Map<String, dynamic>;
//           subMap.forEach((subKey, subValue) {
//             if (subValue != null && subValue.toString().isNotEmpty) {
//               if (subValue is bool && subValue == true) {
//                 features.add(_formatKey(subKey));
//               } else if (subValue is String && subValue.isNotEmpty) {
//                 features.add('${_formatKey(subKey)}: $subValue');
//               }
//             }
//           });
//         }
//       }
//     });
//   }

//   return features;
// }

// // Méthode helper pour formater les clés
// String _formatKey(String key) {
//   // Remplacer les underscores par des espaces et capitaliser
//   return key.replaceAll('_', ' ').split(' ').map((word) {
//     if (word.isEmpty) return word;
//     return word[0].toUpperCase() + word.substring(1).toLowerCase();
//   }).join(' ');
// }

//     String? _getBadge(Abonnement abonnement) {
//       if (abonnement.popularite != null) {
//         if (abonnement.popularite!.etoiles >= 4.5) {
//           return 'POPULAIRE';
//         } else if (abonnement.identifiant.toLowerCase() == '') {
//           return 'VIP';
//         }
//       }
//       return null;
//     }

//   Widget _buildPlanSlide(Abonnement abonnement, int index) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final availableHeight = screenHeight -
//         kToolbarHeight -
//         MediaQuery.of(context).padding.top -
//         180; // 180px pour les boutons et indicateurs

//     final planColor = _getPlanColor(abonnement);
//     final features = _buildFeaturesList(abonnement);
//     final badge = _getBadge(abonnement);

//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
//       child: SingleChildScrollView(
//         child: SizedBox(
//           height: availableHeight,
//           child: Column(
//             children: [
//               // En-tête avec badge si disponible
//               if (badge != null)
//                 Container(
//                   margin: EdgeInsets.only(bottom: screenHeight * 0.02),
//                   padding: EdgeInsets.symmetric(
//                     horizontal: screenWidth * 0.03,
//                     vertical: screenHeight * 0.008,
//                   ),
//                   decoration: BoxDecoration(
//                     color: planColor,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     badge,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: screenWidth * 0.03,
//                     ),
//                   ),
//                 ),

//               // Carte principale du plan
//               Expanded(
//                 child: Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.all(screenWidth * 0.06),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         planColor,
//                         planColor.withOpacity(0.8),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: planColor.withOpacity(0.3),
//                         blurRadius: 20,
//                         offset: const Offset(0, 10),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       // Nom du plan
//                       Text(
//                         abonnement.nom,
//                         style: TextStyle(
//                           fontSize: screenWidth * 0.08,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),

//                       SizedBox(height: screenHeight * 0.01),

//                       // Description
//                       Text(
//                         abonnement.description,
//                         style: TextStyle(
//                           fontSize: screenWidth * 0.035,
//                           color: Colors.white.withOpacity(0.9),
//                           fontStyle: FontStyle.italic,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),

//                       SizedBox(height: screenHeight * 0.03),

//                       // Prix
//                       InkWell(
//                         onTap: () {
//                          var a= abonnement.id.toString();
//                        //  print("voilà son abonnement $a");

//                        showCupertinoDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return CupertinoAlertDialog(
//         title: const Text("Confirmation"),
//         content: const Text("Voulez-vous vous abonner ?"),
//         actions: [
//           CupertinoDialogAction(
//             child: const Text("Non", style: TextStyle(color: CupertinoColors.destructiveRed)),
//             onPressed: () {
//               Navigator.of(context).pop(); // fermer la pop-up
//             },
//           ),
//           CupertinoDialogAction(
//             isDefaultAction: true,
//             child: const Text("Oui"),
//             onPressed: () async {
//               Navigator.of(context).pop();
//               controller.souscrireAbonnement(a);
//               // final ok = await ctrl.souscrire();
//               // if (ok) {
//               //   Get.snackbar("Succès", ctrl.successMessage.value ?? "Souscription réussie ✅");
//               // } else {
//               //   Get.snackbar("Erreur", ctrl.errorMessage.value ?? "Échec de la souscription",
//               //       backgroundColor: const Color(0xFFFFE0E0));
//               // }
//             },
//           ),
//         ],
//       );
//     },
//   );
//                         },
//                         child: Container(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: screenWidth * 0.05,
//                           vertical: screenHeight * 0.015,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(15),
//                           border:
//                               Border.all(color: Colors.white.withOpacity(0.3)),
//                         ),
//                         child: Column(
//                           children: [
//                             Text(
//                               abonnement.prix.mensuel,
//                               style: TextStyle(
//                                 fontSize: screenWidth * 0.055,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                             if (abonnement.prix.economieAnnuelle.isNotEmpty)
//                               Text(
//                                 "Appuyer pour souscrire",
//                                 style: TextStyle(
//                                   fontSize: screenWidth * 0.025,
//                                   color: Colors.white.withOpacity(0.8),
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                           ],
//                         ),
//                       ),
//                       ),

//                       SizedBox(height: screenHeight * 0.03),

//                       // Fonctionnalités
//                      Expanded(
//   child: Container(
//     width: double.infinity,
//     padding: EdgeInsets.all(screenWidth * 0.05),
//     decoration: BoxDecoration(
//       color: Colors.white.withOpacity(0.1),
//       borderRadius: BorderRadius.circular(15),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Fonctionnalités :",
//           style: TextStyle(
//             fontSize: screenWidth * 0.045,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         SizedBox(height: screenHeight * 0.015),
//         Expanded(
//           child: ListView.builder(
//             itemCount: features.length,
//             itemBuilder: (context, featIndex) {
//               return Padding(
//                 padding: EdgeInsets.only(bottom: screenHeight * 0.01),
//                 child: Row(
//                   children: [
//                     Icon(Icons.check_circle_outline, color: Colors.white),
//                     Text(
//                   features[featIndex],
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.035,
//                     color: Colors.white.withOpacity(0.95),
//                     height: 1.3,
//                   ),
//                 ),
//                   ],
//                 )
//               );
//             },
//           ),
//         ),
//       ],
//     ),
//   ),
// )

//                     ],
//                   ),
//                 ),
//               ),

//               // Indication de swipe
//               if (index < controller.abonnements.length - 1)
//                 Container(
//                   margin: EdgeInsets.only(top: screenHeight * 0.02),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.swipe_left,
//                         color: Colors.grey.shade600,
//                         size: screenWidth * 0.05,
//                       ),
//                       SizedBox(width: screenWidth * 0.02),
//                       Text(
//                         "Glissez pour voir le plan suivant",
//                         style: TextStyle(
//                           color: Colors.grey.shade600,
//                           fontSize: screenWidth * 0.03,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
// }

class AbonnementScreen extends StatefulWidget {
  const AbonnementScreen({super.key});

  @override
  State<AbonnementScreen> createState() => _AbonnementScreenState();
}

class _AbonnementScreenState extends State<AbonnementScreen> {
  final PageController _pageController = PageController();
  final AbonnementController controller = Get.find<AbonnementController>();
  int currentIndex = 0;

  // Map pour les couleurs des plans
  final Map<String, Color> planColors = {
    'basic': Colors.grey[900]!,
    'premium': const Color(0xFF1234A0),
    'elite': const Color.fromARGB(255, 196, 105, 1),
  };

  @override
  Widget build(BuildContext context) {
    // controller.errorMessage.value='flkf';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColorModel.Bluecolor242,
        title: Text(
          "Abonnements",
          style: TextStyle(
            fontSize:
                MediaQuery.of(Get.context!).size.width > 600 ? 18.sp : 16.sp,
            color: AppColorModel.WhiteColor,
          ),
        ),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
        actions: [
          NotificationWidget(),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CupertinoActivityIndicator(
              color: AppColorModel.Bluecolor242,
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red.shade600,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    controller.errorMessage.value,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: null,
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: () async {
                      controller.isLoading.value = true;
                      bool isConnected = await hasInternetConnection();

                      if (isConnected) {
                        print('Connexion Internet disponible');
                      } else {
                        controller.isLoading.value = false;
                        // SnackBarService.error('Pas de connexion Internet');
                        return;
                      }
                      controller.isLoading.value = false;

                      controller.fetchAbonnements();
                    },
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label:  Text(
                      "Réessayer",
                      style: TextStyle(
                        fontSize: 12.sp,
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
          );
        }

        if (controller.abonnements.isEmpty) {
          return Center(
            child: Text("Aucun abonnement disponible"),
          );
        }

        return Column(
          children: [
            // Indicateur de pages
            Container(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.abonnements.length,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.01,
                    ),
                    width: currentIndex == index
                        ? MediaQuery.of(context).size.width * 0.03
                        : MediaQuery.of(context).size.width * 0.02,
                    height: currentIndex == index
                        ? MediaQuery.of(context).size.width * 0.03
                        : MediaQuery.of(context).size.width * 0.02,
                    decoration: BoxDecoration(
                      color: currentIndex == index
                          ? AppColorModel.Bluecolor242
                          : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),

            // Slides des plans
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemCount: controller.abonnements.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = _pageController.page! - index;
                        value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                      }
                      return Transform.scale(
                        scale: Curves.easeOut.transform(value),
                        child: Opacity(
                          opacity: value,
                          child: _buildPlanSlide(
                              controller.abonnements[index], index),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Boutons de navigation
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.height * 0.015,
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Boutons sur une ligne si possible, sinon en colonne
                    LayoutBuilder(
                      builder: (context, constraints) {
                        bool shouldStack = constraints.maxWidth < 300;

                        if (shouldStack) {
                          return Column(
                            children: [
                              if (currentIndex > 0)
                                Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(bottom: 8),
                                  child: OutlinedButton(
                                    onPressed: () {
                                      _pageController.previousPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: AppColorModel.Bluecolor242),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15),
                                    ),
                                    child: Text(
                                      "Précédent",
                                      style: TextStyle(
                                        color: AppColorModel.Bluecolor242,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (currentIndex <
                                        controller.abonnements.length - 1) {
                                      _pageController.animateToPage(
                                        currentIndex + 1,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInOutCubic,
                                      );
                                    } else {
                                      Get.to(
                                        () => SubscriptionComparisonPage(),
                                        transition: Transition.rightToLeft,
                                        duration:
                                            const Duration(milliseconds: 300),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _getPlanColor(
                                        controller.abonnements[currentIndex]),
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    currentIndex <
                                            controller.abonnements.length - 1
                                        ? "Suivant"
                                        : "Recap",
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Row(
                            children: [
                              if (currentIndex > 0)
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      _pageController.previousPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: AppColorModel.Bluecolor242),
                                      padding: EdgeInsets.symmetric(
                                        vertical:
                                            MediaQuery.of(context).size.height *
                                                0.018,
                                      ),
                                    ),
                                    child: FittedBox(
                                      child: Text(
                                        "Précédent",
                                        style: TextStyle(
                                          color: AppColorModel.Bluecolor242,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11.sp
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (currentIndex > 0)
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.04),
                              Expanded(
                                flex: currentIndex == 0 ? 1 : 2,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (currentIndex <
                                        controller.abonnements.length - 1) {
                                      _pageController.animateToPage(
                                        currentIndex + 1,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInOutCubic,
                                      );
                                    } else {
                                      Get.to(
                                        () => SubscriptionComparisonPage(),
                                        transition: Transition.rightToLeft,
                                        duration:
                                            const Duration(milliseconds: 300),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _getPlanColor(
                                        controller.abonnements[currentIndex]),
                                    padding: EdgeInsets.symmetric(
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              0.018,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: FittedBox(
                                    child: Text(
                                      currentIndex <
                                              controller.abonnements.length - 1
                                          ? "Suivant"
                                          : "Recap",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Color _getPlanColor(Abonnement abonnement) {
    return planColors[abonnement.identifiant.toLowerCase()] ??
        AppColorModel.Bluecolor242;
  }

  List<String> _buildFeaturesList(Abonnement abonnement) {
    List<String> features = [];

    // Plafonds
    if (abonnement.caracteristiques?.plafonds?.mensuel != null) {
      features
          .add('Plafond: ${abonnement.caracteristiques!.plafonds!.mensuel}');
    }

    // Objectifs
    if (abonnement.caracteristiques?.objectifs != null) {
      if (abonnement.caracteristiques!.objectifs is int) {
        features.add('${abonnement.caracteristiques!.objectifs} objectif(s)');
      } else if (abonnement.caracteristiques!.objectifs is String) {
        features.add('Objectifs ${abonnement.caracteristiques!.objectifs}');
      }
    }

    // Support
    if (abonnement.avantages?.services?.support != null) {
      features.add('Support ${abonnement.avantages!.services!.support}');
    }

    // Conseiller dédié
    if (abonnement.avantages?.services?.conseillerDedie != null) {
      if (abonnement.avantages!.services!.conseillerDedie == 1 ||
          abonnement.avantages!.services!.conseillerDedie == true) {
        features.add('Conseiller dédié');
      }
    }

    // Best for (recommandation d'usage)
    if (abonnement.bestFor != null && abonnement.bestFor!.isNotEmpty) {
      features.add('Idéal pour: ${abonnement.bestFor}');
    }

    // Ajout dynamique d'autres caractéristiques si elles existent
    if (abonnement.caracteristiques != null) {
      final Map<String, dynamic> caracMap =
          abonnement.caracteristiques!.toJson();
      caracMap.forEach((key, value) {
        if (key != 'plafonds' && key != 'objectifs' && value != null) {
          if (value is bool && value == true) {
            features.add(_formatKey(key));
          } else if (value is String && value.isNotEmpty) {
            features.add('${_formatKey(key)}: $value');
          } else if (value is int && value > 0) {
            features.add('${_formatKey(key)}: $value');
          }
        }
      });
    }

    // Ajout dynamique d'autres avantages si ils existent
    if (abonnement.avantages != null) {
      final Map<String, dynamic> avantagesMap = abonnement.avantages!.toJson();
      avantagesMap.forEach((key, value) {
        if (key != 'services' && value != null) {
          if (value is Map) {
            final Map<String, dynamic> subMap = value as Map<String, dynamic>;
            subMap.forEach((subKey, subValue) {
              if (subValue != null && subValue.toString().isNotEmpty) {
                if (subValue is bool && subValue == true) {
                  features.add(_formatKey(subKey));
                } else if (subValue is String && subValue.isNotEmpty) {
                  features.add('${_formatKey(subKey)}: $subValue');
                }
              }
            });
          }
        }
      });
    }

    return features;
  }

  // Méthode helper pour formater les clés
  String _formatKey(String key) {
    return key.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String? _getBadge(Abonnement abonnement) {
    if (abonnement.popularite != null) {
      if (abonnement.popularite!.etoiles >= 4.5) {
        return 'POPULAIRE';
      } else if (abonnement.identifiant.toLowerCase() == '') {
        return 'VIP';
      }
    }
    return null;
  }

  Widget _buildPlanSlide(Abonnement abonnement, int index) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final availableHeight = screenHeight -
        kToolbarHeight -
        MediaQuery.of(context).padding.top -
        180;
    print(abonnement.nom);
    final planColor = _getPlanColor(abonnement);
    final features = _buildFeaturesList(abonnement);
    final badge = _getBadge(abonnement);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: SingleChildScrollView(
        child: SizedBox(
          height: availableHeight,
          child: Column(
            children: [
              // En-tête avec badge si disponible
              if (badge != null)
                Container(
                  margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.008,
                  ),
                  decoration: BoxDecoration(
                    color: planColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 8.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Carte principale du plan
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        planColor,
                        planColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: planColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Nom du plan
                      Text(
                        abonnement.nom,
                        style: TextStyle(
                          fontSize: screenWidth * 0.08,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: screenHeight * 0.01),

                      // Description
                      Text(
                        abonnement.description,
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: Colors.white.withOpacity(0.9),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Prix
                      InkWell(
                        onTap: (((AbonnementEncoursController
                                                .to.abonnement.value?.type) ??
                                            "")
                                        .toLowerCase() // tout en minuscules
                                        .replaceAll(RegExp(r'\s+'), '') ==
                                    ((abonnement.nom ?? '')
                                        .toLowerCase() // tout en minuscules
                                        .replaceAll(RegExp(r'\s+'), '')) &&
                                AbonnementEncoursController
                                        .to.abonnement.value !=
                                    null)
                            ? null
                            : () {
                                var a = abonnement.id.toString();

// Dialog de suppression
                                Get.dialog(
                                  AppDialog(
                                    title: "Confirmation",
                                    body:
                                        "Le mot de passe fourni est incorrect.",
                                    // headerColor: Colors.red,

                                    actions: [
                                      AppDialogAction(
                                        label: "Non",
                                        onPressed: () => Get.back(),
                                      ),
                                      AppDialogAction(
                                        label: "Oui",
                                        isDestructive: true,
                                        onPressed: () {
                                          Get.back();

                                          CodeVerification().show(context,
                                              () async {
                                            // if (Navigator.of(context).canPop()) {
                                            //   Navigator.pop(context);
                                            // }
                                            controller.souscrireAbonnement(a);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );

                                // showCupertinoDialog(
                                //   context: context,
                                //   builder: (BuildContext context) {
                                //     return CupertinoAlertDialog(
                                //       title: const Text("Confirmation"),
                                //       content: const Text(
                                //           "Voulez-vous vous abonner ?"),
                                //       actions: [
                                //         CupertinoDialogAction(
                                //           child: const Text("Non",
                                //               style: TextStyle(
                                //                   color: CupertinoColors
                                //                       .destructiveRed)),
                                //           onPressed: () {
                                //             Navigator.of(context).pop();
                                //           },
                                //         ),
                                //         CupertinoDialogAction(
                                //           isDefaultAction: true,
                                //           child: const Text("Oui"),
                                //           onPressed: () async {
                                //             Navigator.pop(context);
                                //             CodeVerification().show(context,
                                //                 () async {
                                //               // if (Navigator.of(context).canPop()) {
                                //               //   Navigator.pop(context);
                                //               // }
                                //               controller.souscrireAbonnement(a);
                                //             });
                                //           },
                                //         ),
                                //       ],
                                //     );
                                //   },
                                // );
                              },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: screenHeight * 0.015,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                abonnement.prix.mensuel,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (((AbonnementEncoursController
                                                  .to.abonnement.value?.type) ??
                                              "")
                                          .toLowerCase() // tout en minuscules
                                          .replaceAll(RegExp(r'\s+'), '') ==
                                      ((abonnement.nom ?? '')
                                          .toLowerCase() // tout en minuscules
                                          .replaceAll(RegExp(r'\s+'), '')) &&
                                  AbonnementEncoursController
                                          .to.abonnement.value !=
                                      null)
                                Text(
                                  'Abonnement en cours',
                                  style: TextStyle(color: Colors.green,
                                  fontSize: 9.sp),
                                )
                              else if (abonnement
                                  .prix.economieAnnuelle.isNotEmpty)
                                Text(
                                  "Appuyer pour souscrire",
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Fonctionnalités
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Fonctionnalités :",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: features.length,
                                  itemBuilder: (context, featIndex) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          bottom: screenHeight * 0.01),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.white,
                                            size: screenWidth * 0.04,
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              features[featIndex],
                                              style: TextStyle(
                                                fontSize: 9.sp,
                                                color: Colors.white
                                                    .withOpacity(0.95),
                                                height: 1.3,
                                              ),
                                              maxLines:
                                                  null, // Permet plusieurs lignes
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Indication de swipe
              if (index < controller.abonnements.length - 1)
                Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swipe_left,
                        color: Colors.grey.shade600,
                        size: 11.sp,
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: Text(
                          "Glissez pour voir le plan suivant",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11.sp,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
