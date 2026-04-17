import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/%20manage_cards_controller_v2.dart';
import 'package:onyfast/View/Activité/recharger_mon_compte.dart';
import 'package:onyfast/View/BottomView/CarteDetails.dart';
import 'package:onyfast/View/BottomView/FullService.dart';
import 'package:onyfast/View/BottomView/widgets/colors.dart';
import 'package:onyfast/View/Gerer_cartes/gerer_mes_cartes.dart';
import 'package:onyfast/View/Merchand/view/merchant_view.dart';
import 'package:onyfast/View/Recevoir/Qr%20Code/scan_qr.dart';
import 'package:onyfast/Widget/dialog.dart';
import 'package:onyfast/verificationcode.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            spreadRadius: 2,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Titre + Tout voir ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Actions rapides',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: C.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Obx(() {
                final ManageCardsController controller = Get.find();
                final card = controller.currentCard;

                if (ManageCardsController.to.TestUserNotFound.value == false ||
                    card == null ||
                    (card.isActive != true)) {
                  return SizedBox.shrink();
                }

                return GestureDetector(
                  onTap: () {
                    Get.to(ServicesPage(), transition: Transition.cupertino);
                    // TODO: naviguer vers la page complète des actions
                  },
                  child: Text(
                    'Tout voir',
                    style: TextStyle(
                      fontSize: 8.sp,
                      color: C.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 1.8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(), // ← Ajouter ceci

            child: Row(
              spacing: 6.w,
                    mainAxisSize: MainAxisSize.min,  // ← min, pas max
              children: [
                Obx(() {
                  final ManageCardsController controller = Get.find();
                  final card = controller.currentCard;
                  return _ActionBtn(
                    label: 'Transfert',
                    icon: 'asset/transfert-qr.svg',
                    iconColor: Colors.white,
                    bgColor: const Color(0xFFDBEAFE),
                    innerColor: C.icoTransfBg,
                    onTap: () {
                      if (ManageCardsController.to.TestUserNotFound.value ==
                          false) {
                        Get.dialog(
                          AppDialog(
                            title: "Information",
                            body:
                                "Vous devez enregistrer et activer une carte avant de pouvoir initier un transfert. Retournez ici une fois la carte opérationnelle pour continuer.",
                            actions: [
                              AppDialogAction(
                                label: "OK",
                                isDestructive: true,
                                onPressed: () => Get.back(),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      if (card == null) {
                        Get.dialog(
                          AppDialog(
                            title: "Information",
                            body:
                                "Vous devez enregistrer et activer une carte avant de pouvoir initier un transfert. Retournez ici une fois la carte opérationnelle pour continuer.",
                            actions: [
                              AppDialogAction(
                                label: "OK",
                                isDestructive: true,
                                onPressed: () => Get.back(),
                              ),
                            ],
                          ),
                        );

                        return;
                      }

                      if (card.isActive != true) {
                        Get.dialog(
                          AppDialog(
                            title: "Information",
                            body:
                                "Veuillez activer votre carte pour effectuer des opérations.",
                            actions: [
                              AppDialogAction(
                                label: "OK",
                                isDestructive: true,
                                onPressed: () => Get.back(),
                              ),
                            ],
                          ),
                        );

                        return;
                      }
                      CodeVerification().show(context, () async {
                        if (Navigator.of(context).canPop()) {
                          Navigator.pop(context);
                        }
                        Get.to(ScanQr(), transition: Transition.cupertino);
                      });
                    },
                  );
                }),
                Obx(() {
                  final ManageCardsController controller = Get.find();
                  final card = controller.currentCard;
                  return _ActionBtn(
                    label: 'Marchands',
                    icon: 'asset/marchands.svg',
                    iconColor: C.icoMarch,
                    bgColor: C.icoMarchBg,
                    innerColor: C.icoMarchBg,
                    onTap: () => Get.to(MerchantPage(),
                        transition: Transition.cupertino),
                  );
                }),
                Obx(() {
                  final ManageCardsController controller = Get.find();
                  final card = controller.currentCard;
                  return _ActionBtn(
                    label: 'Carte',
                    icon: 'asset/cartes.svg',
                    iconColor: C.icoCartes,
                    bgColor: C.icoCartesBg,
                    innerColor: C.icoCartesBg,
                    onTap: () {
                      if (ManageCardsController.to.TestUserNotFound.value ==
                          false) {
                        Get.dialog(
                          AppDialog(
                            title: "Information",
                            body:
                                "Cette action nécessite une carte active. Veuillez enregistrer et activer votre carte dans l’espace dédié, puis revenez .",
                            actions: [
                              AppDialogAction(
                                label: "OK",
                                isDestructive: true,
                                onPressed: () => Get.back(),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      if (card == null) {
                        Get.dialog(
                          AppDialog(
                            title: "Information",
                            body:
                                "Cette action nécessite une carte active. Veuillez enregistrer et activer votre carte dans l’espace dédié, puis revenez .",
                            actions: [
                              AppDialogAction(
                                label: "OK",
                                isDestructive: true,
                                onPressed: () => Get.back(),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      Get.to(CardDetailPage(),
                          transition: Transition.cupertino);
                    },
                  );
                }),
                _ActionBtn(
                  label: 'Recharge',
                  icon: 'asset/charge-extra-money-svgrepo-com.svg',
                  iconColor: C.icoRech,
                  bgColor: C.icoRechBg,
                  innerColor: C.icoRechBg,
                  onTap: () =>
                      Get.to(RechargePage(), transition: Transition.cupertino),
                ),
              ],
            ),
          
          )
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final String icon;
  final Color iconColor;
  final Color bgColor;
  final Color innerColor;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.innerColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: innerColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(
                icon,
                color: iconColor,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 8.sp,
              color: C.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
