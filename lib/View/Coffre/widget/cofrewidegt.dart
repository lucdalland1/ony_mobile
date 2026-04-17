import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/CoffreController.dart';
import 'package:onyfast/View/Coffre/model/coffreModel.dart';
import 'package:onyfast/View/Coffre/modifierCoffre.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/Widget/dialog.dart';
import 'package:onyfast/verificationcode.dart';
void showMyCupertinoPopup(ObjectifModel objectif) {

 List <Widget> controlle (){
    if(objectif.isActive)return [ CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () async {
            Get.back();
            if(objectif.montantActuel == 0){
               await Get.find<CoffreController>().supprimerObjectif(objectif.id);
              return;
            }else if(objectif.montantActuel==objectif.montantCible){
                            await Get.find<CoffreController>().supprimerObjectif(objectif.id);
                  return ;
            }
                  SnackBarService.info("Vous ne pouvez pas supprimer un objectif en cours ");

            print("voila le montant actuel ${objectif.montantActuel}  ");
            print("voila le montant cible ${objectif.montantCible}  ");

            // Navigate back to coffre page after deletion
          },
          child: Text('Supprimer'),
        ),
      ];
    else if(objectif.montantActuel!=0)return [

  CupertinoActionSheetAction(
          onPressed: () {
            Get.back();
            CodeVerification().show(Get.context!, () {
              
                    showCupertinoInputPopup(title: 'Ajouter à l\'objectif', hint: 'Montant', onConfirm: (int  montant) { 
                      Get.find<CoffreController>().ajouterMontantObjectif(objectif.id, montant);

         });
            });
            // Get.snackbar('Action', 'Objectif affiché');
          },
          child: Text("Ajouter à L'objectif "),
        ),
  

    ];

    
    return [
        
        CupertinoActionSheetAction(
          onPressed: () {
            Get.back();
            CodeVerification().show(Get.context!, () {
              
                    showCupertinoInputPopup(title: 'Ajouter à l\'objectif', hint: 'Montant', onConfirm: (int  montant) { 
                      Get.find<CoffreController>().ajouterMontantObjectif(objectif.id, montant);

         });
            });
            // Get.snackbar('Action', 'Objectif affiché');
          },
          child: Text("Ajouter à L'objectif "),
        ),
  
//         CupertinoActionSheetAction(
//           onPressed: () {
//             Get.back();
//             if(objectif.montantActuel > 0){
//               SnackBarService.info("Vous ne pouvez pas modifier un objectif en cours ");
//               return;
//             }
            
// showComingSoon();
//             //  Get.to(Modifiercoffre( objectif: objectif, ));
//           },
//           child: Text('Modifier'),
//         ),
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () async {
            Get.back();
            if(objectif.montantActuel == 0){
               await Get.find<CoffreController>().supprimerObjectif(objectif.id);
              return;
            }else if(objectif.montantActuel==objectif.montantCible){
                            await Get.find<CoffreController>().supprimerObjectif(objectif.id);
                  return ;
            }
                  SnackBarService.info("Vous ne pouvez pas supprimer un objectif en cours ");

            print("voila le montant actuel ${objectif.montantActuel}  ");
            print("voila le montant cible ${objectif.montantCible}  ");

            // Navigate back to coffre page after deletion
          },
          child: Text('Supprimer'),
        ),
      ];
  }
  showCupertinoModalPopup(
    context: Get.context!,
    builder: (_) => CupertinoActionSheet(
      title: Text('Gérer l\'objectif'),
      message: Text('Que souhaitez-vous faire ?'),
      actions: controlle(),
      cancelButton: CupertinoActionSheetAction(
        onPressed: () {
          Get.back();
        },
        child: Text('Annuler'),
      ),
    ),
  );

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



void showCupertinoInputPopup({
  required String title,
  required String hint,
  required void Function(int) onConfirm,
}) {
  final TextEditingController textController = TextEditingController();

  Get.dialog(
   Platform.isIOS
        ? CupertinoAlertDialog(
            title: Text(title),
            content: Padding(
              padding: EdgeInsets.only(top: 1.h),
              child: CupertinoTextField(
                controller: textController,
                keyboardType: TextInputType.number,
                placeholder: hint,
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Get.back(),
                child: const Text("Annuler"),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  final input = textController.text.trim();
                  if (input.isNotEmpty) {
                    Get.back();
                    onConfirm(int.parse(input));
                  } else {
                    SnackBarService.warning("Le champ est vide");
                  }
                },
                child: const Text("Valider"),
              ),
            ],
          )
        : Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 5.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(1.5.h),
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Container(
                  width: double.infinity,
                  color: const Color(0xFF4F46E5),
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),

                /// INPUT
                Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
                  child: TextField(
                    controller: textController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 10.sp),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(fontSize: 10.sp),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.2.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(1.h),
                        borderSide: const BorderSide(color: Color(0xFF4F46E5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(1.h),
                        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                      ),
                    ),
                  ),
                ),

                /// ACTIONS
                Padding(
                  padding: EdgeInsets.fromLTRB(2.w, 0, 2.w, 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// Annuler
                      SizedBox(
                        width: 35.w,
                        child: MaterialButton(
                          onPressed: () => Get.back(),
                          elevation: 0,
                          highlightElevation: 0,
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1.h),
                            side: const BorderSide(color: Color(0xFF4F46E5), width: 1),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 1.2.h),
                          child: Text(
                            "Annuler",
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF4F46E5),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 3.w),

                      /// Valider
                      SizedBox(
                        width: 35.w,
                        child: MaterialButton(
                          onPressed: () {
                            final input = textController.text.trim();
                            if (input.isNotEmpty) {
                              Get.back();
                              onConfirm(int.parse(input));
                            } else {
                              SnackBarService.warning("Le champ est vide");
                            }
                          },
                          elevation: 0,
                          highlightElevation: 0,
                          color: const Color(0xFF4F46E5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1.h),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 1.2.h),
                          child: Text(
                            "Valider",
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    barrierDismissible: false,
  );
}