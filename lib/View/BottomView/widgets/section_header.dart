import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:onyfast/Controller/%20manage_cards_controller_v2.dart';
import 'package:onyfast/Controller/niveau/niveau_controller.dart';
import 'package:onyfast/Controller/verifier_identite/voir_justificatifresidencecontroller.dart';
import 'package:onyfast/View/Activit%C3%A9/verification_identite/verifier_mon_compte.dart';
import 'package:onyfast/View/BottomView/profiluser.dart';
import 'package:onyfast/View/BottomView/widgets/colors.dart';
import 'package:onyfast/View/Gerer_cartes/cartephysique.dart';
import 'package:onyfast/View/Gerer_cartes/cartevirtuelle.dart';
import 'package:onyfast/Widget/dialog.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final ListeJustificatifController controllerTest2 = Get.find();

    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            if (ManageCardsController.to.TestUserNotFound.value == false ||
                ManageCardsController.to.currentCard == null ||
                ManageCardsController.to.isLoading.value) {
              return Text('Mes Cartes',
                  style: TextStyle(
fontSize: MediaQuery.of(context).size.width > 600 ? 15.sp : 15.sp,
                      color: C.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3));
            }
            return Text('Mon Solde',
                style: TextStyle(
fontSize: MediaQuery.of(context).size.width > 600 ? 15.sp : 15.sp,                    color: C.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3));
          }),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005),

          // Row(children: [
          //   const Icon(Icons.trending_up_rounded, color: C.primary, size: 15),
          //   const SizedBox(width: 4),
          //   // Obx(() {
          //   //   try {
          //   //     if (!Get.isRegistered<ManageCardsController>()) {
          //   //       return Text('0 active',
          //   //           style: TextStyle(
          //   //               fontSize: rf(context, 12),
          //   //               color: C.textGrey,
          //   //               fontWeight: FontWeight.w500));
          //   //     }
          //   //     final controller = Get.find<ManageCardsController>();
          //   //     final cards = controller.cards;
          //   //     final nbActives =
          //   //         cards.isEmpty ? 0 : cards.where((c) => c.isActive).length;
          //   //     return Text(
          //   //       '$nbActives active${nbActives > 1 ? 's' : ''}',
          //   //       style: TextStyle(
          //   //           fontSize: rf(context, 12),
          //   //           color: C.textGrey,
          //   //           fontWeight: FontWeight.w500),
          //   //     );
          //   //   } catch (e) {
          //   //     return Text('--',
          //   //         style: TextStyle(
          //   //             fontSize: rf(context, 12), color: C.textGrey));
          //   //   }
          //   // }),
          // ]),
        ],
      ),
      const Spacer(),
      Obx(() {
        if (ManageCardsController.to.isLoading.value) {
          return const SizedBox.shrink();
        }
        if (ManageCardsController.to.TestUserNotFound.value == true &&
            !ManageCardsController.to.errorMessage.value.isNotEmpty) {
          if (ManageCardsController.to.cards.length == 1) {
            if (ManageCardsController.to.TestUserNotFound.value == false) {
              return const SizedBox.shrink();
            }
            return GestureDetector(
                onTap: controllerTest2.chargementAccueil.value
                    ? null
                    : () async {
                        final profile =
                            ManageCardsController.to.userProfile.value;
                        final canAddPhysical =
                            profile == null || profile.cardID <= 0;
                        final canAddVirtual = profile == null ||
                            profile.cardIDVirtual == null ||
                            profile.cardIDVirtual! <= 0;
                        final NiveauController niveauController = Get.find();

                        controllerTest2.chargementAccueil.value = true;
                        await controllerTest2.chargerJustificatifs();
                        controllerTest2.chargementAccueil.value = false;

                        // ── Il a déjà la physique, manque virtuelle ──
                        if (!canAddPhysical && canAddVirtual) {
                          Get.to(() => CarteVirtuelle(),
                              transition: Transition.cupertino);
                          return;
                        }

                        // ── Il a déjà la virtuelle, manque physique ──
                        // ── Ou les deux manquent → même flow physique ──
                        if (niveauController.niveau.value == 3) {
                          Get.to(() => CartePhysique(),
                              transition: Transition.cupertino);
                          return;
                        }
                        if (controllerTest2.total.value == 0) {
                          _showComingSoon(
                              context, 'Veuillez soumettre un justificatif.');
                          return;
                        }
                        if (controllerTest2.isAdmin.value == false) {
                          _showComingSoon(
                              context, 'Pièce en attente de validation.');
                          return;
                        }
                        Get.to(() => CartePhysique(),
                            transition: Transition.cupertino);
                        controllerTest2.chargementAccueil.value = false;
                      },
                child: Container(
                 padding: EdgeInsets.symmetric(
  horizontal: MediaQuery.of(context).size.width * 0.035,
  vertical: MediaQuery.of(context).size.height * 0.012,
),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border:
                        Border.all(color: const Color(0xFFE5E9F2), width: 1),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 6,
                          offset: Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!(controllerTest2.chargementAccueil.value))
                        Icon(Icons.add, color: C.primary,size: MediaQuery.of(context).size.width * 0.037,),
                      const SizedBox(width: 4),
                      (controllerTest2.chargementAccueil.value)
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CupertinoActivityIndicator(
                                color: C.primary,
                              ),
                            )
                          : Text(() {
                              final profile =
                                  ManageCardsController.to.userProfile.value;
                              final canAddPhysical =
                                  profile == null || profile.cardID <= 0;
                              final canAddVirtual = profile == null ||
                                  profile.cardIDVirtual == null ||
                                  profile.cardIDVirtual! <= 0;

                              if (canAddPhysical && canAddVirtual)
                                return 'Ajouter une carte';
                              if (canAddPhysical)
                                return 'Ajouter carte physique';
                              if (canAddVirtual)
                                return 'Ajouter carte virtuelle';
                              return 'Ajouter';
                            }(),
                              style: TextStyle(
fontSize: MediaQuery.of(context).size.width > 600 ? 10.sp : 9.sp,                                  color: C.primary,
                                  fontWeight: FontWeight.w600)),
                    ],
                  ),
                ));
          }
        }
        return SizedBox.shrink();
      })
    ]);
  }
}

void _showComingSoon(BuildContext context, [String? title]) {

  Get.dialog(
  AppDialog(
    title: title ?? "Vous n'avez pas de pièce jointe",
    body: "Allez dans paramètre afin d'en ajouter",
    actions: [
      AppDialogAction(
        label: "Annuler",
        onPressed: () => Get.back(),
      ),
      AppDialogAction(
        label: "Confirmer",
        isDestructive: true,
        onPressed: () {
          Get.back();
          //  Navigator.of(context, rootNavigator: true).pop();
              Get.to(() => VerifierIdentiteScreen());
          // ta logique ici
        },
      ),
    ],
  ),
);
  // showCupertinoDialog(
  //   context: context,
  //   builder: (_) => WillPopScope(
  //     onWillPop: () async => false, // bloque bouton retour
  //     child: CupertinoAlertDialog(
  //       title: Text(title ?? "Vous n'avez pas de pièce jointe"),
  //       content: Text("Allez dans paramètre afin d'en ajouter"),
  //       actions: [
  //         CupertinoDialogAction(
  //           child: Text('OK'),
  //           onPressed: () {
  //             Navigator.of(context, rootNavigator: true).pop();
  //             Get.to(() => VerifierIdentiteScreen());
  //           },
  //         ),
  //       ],
  //     ),
  //   ),
  // );
}
