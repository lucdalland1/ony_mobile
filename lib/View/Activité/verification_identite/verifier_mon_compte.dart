// ignore_for_file: deprecated_member_use


import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:onyfast/Api/piecesjustificatif_Api/pieces_justificatif_api.dart';
import 'package:onyfast/Controller/RejetPiece/rejetpiececontroller.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/niveau/niveau_controller.dart';
import 'package:onyfast/Controller/verifier_identite/voir_justificatifresidencecontroller.dart';
import 'package:onyfast/Controller/verou/verroucontroller.dart';
import 'package:onyfast/View/Activit%C3%A9/verification_identite/justificatif_domicile.dart';
import 'package:onyfast/View/Activit%C3%A9/verification_identite/justificatif_identite.dart';
import 'package:onyfast/View/Notification/notification.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/Widget/notificationWidget.dart';

////
///

// Écran principal de vérification d'identité
// ignore: use_key_in_widget_constructors
class VerifierIdentiteScreen extends StatefulWidget {
  @override
  State<VerifierIdentiteScreen> createState() => _VerifierIdentiteScreenState();
}

class _VerifierIdentiteScreenState extends State<VerifierIdentiteScreen> {
  
  final RejectionController rejectionController = Get.put(RejectionController());
  PiecesController controllerTest =Get.find() ;
  ListeJustificatifController controllerTest2 =Get.find() ;
  NiveauController niveauController= Get.find();
  var nombre =0;
  bool Historique=false;
  @override
  void initState() {
    super.initState();
    AppSettingsController.to.setInactivity(false);
    rejectionController.fetchRejectionReasons();
    niveauController.fetchNiveau();
    controllerTest.fetchPieces();
    controllerTest2.chargerJustificatifs();
    ValidationTokenController.to.validateToken();

  }


  @override
  void dispose(){
    super.dispose();
    AppSettingsController.to.setInactivity(true);
  }
  @override
  Widget build(BuildContext context) {
    AppSettingsController.to.setInactivity(false);
    controllerTest.fetchPieces();
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF1E3A8A),
        leading: IconButton(
          icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
           color: Colors.white),
          onPressed: () 
          {
            AppSettingsController.to.setInactivity(true);
            Get.back();},
        ),
        title: Text(
          'Vérifier mon identité',
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(Get.context!).size.width > 600?18.sp : 16.sp,
          ),
        ),
        actions: [
          NotificationWidget(),
        ],
      ),
      body: Obx(()  {


        

        if (niveauController.isLoading.value)return Center(child: CupertinoActivityIndicator(
          color: globalColor,
        ),);


        if(niveauController.errorMessage.value!='')return Center(child: Text(niveauController.errorMessage.value,textAlign:TextAlign.center,style: TextStyle(color: globalColor),),);
        nombre = niveauController.niveau.value;

          return body();
      }) 
          
          );
  }
  body(){
    return GestureDetector(
        onTap: (){
    FocusManager.instance.primaryFocus?.unfocus();
        },
        child:  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() {

            var test = controllerTest.totalPieces.value;
            var test2;
///3e niveau verif à ne pas confondre avec le test2
            var test3=controllerTest2.total.value;
              
            
            var Test3;
            if(test3!=0){
            Test3=controllerTest2.isAdmin.value;
            print('admin $Test3');
            }
            print('test 3 $test3');

          if(test!=0)  test2 = controllerTest.pieces[0].verificationAdmin;
            print('voila $test $test2');

           
             WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
              Historique= (controllerTest2.isAdmin.value==true&& test2==true )?true:false;
              print('Historique $Historique');
      });
    });

            if(controllerTest.Error.value){
             return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Erreur de récupération des pièces',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Connectez-vous à nouveau',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );

            }

            return Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildVerificationStep(
                      icon: Icons.check_circle,
                      iconColor: Colors.green,
                      title: 'Création du compte',
                      subtitle: 'Complet',
                      isCompleted: true,
                      onTap: () {},
                    ),
                    SizedBox(height: 16),
                    _buildVerificationStep(
                      icon:test2==true ?Icons.tag:Icons.check_circle,
                      iconColor:nombre!=1?Colors.green:(test==1?Colors.green: Color(0xFF1E3A8A)),
                      title: 'Pièce d\'identité',
                      subtitle: nombre!=1 ?'Complet':(test == 1
                          ?((test2==true)? 'Complet':'En attente de validation')
                          : 'Insérez une pièce d\'identité valide et une photo'),
                      isCompleted:nombre!=1?true:( test == 1 ? true : false),
                      onTap:nombre!=1?(){}: (test == 1
                          ? () {}
                          : () {
                              print('j ai cliqué sur justificatif ');
                              Get.to(JustificatifIdentite());
                            }),
                    ),

                    SizedBox(height: 16),
                    _buildVerificationStep(
                      icon: Icons.tag,
                      iconColor:nombre>2?Colors.green:( test3 == 1 ? Colors.green : const Color(0xFF1E3A8A)),
                      title: 'Justificatif de domicile',
                      subtitle:nombre>2?'Complet':( test3 == 1 ? (controllerTest2.isAdmin.value==true?'Complet':'En attente de validation')
                      :'Inserez un justificatif de domicile valide et une photo'),
                      isCompleted:nombre>2?true:( test3 == 1),
                      onTap: nombre>2?(){}: (controllerTest.totalPieces.value==0?(){
                        if(nombre==2){
                          Get.to(JustificatifDomicilePage());
                          return;
                        }
                        SnackBarService.info('Veuillez d\'abord ajouter une pièce d\'identité');
                      }:
                      test3 == 1 
                          ? () {} 
                          : () {
                              print('j ai cliqué sur justificatif domicile  ');
                              Get.to(JustificatifDomicilePage());
                            }),
                    ),
                    SizedBox(height: 16),

                nombre>2||Historique==true? SizedBox.shrink(): (Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Historique des rejets',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          Obx(() {
            if (rejectionController.rejectionCount > 0) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${rejectionController.rejectionCount}',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          }),
        ],
      ),
      SizedBox(height: 16),
      
      // Contenu de l'historique
      Obx(() {
        // Afficher le loader
        if (rejectionController.isLoading.value) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CupertinoActivityIndicator(color: globalColor),
            ),
          );
        }

        // Afficher l'erreur
        if (rejectionController.hasError.value) {
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 40),
                SizedBox(height: 8),
                Text(
                  'Erreur de chargement',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Impossible de récupérer l\'historique',
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Pas de rejets
        if (!rejectionController.hasRejections) {
          return Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Aucun document rejeté',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Afficher la liste des rejets
        return Column(
          children: List.generate(
            rejectionController.rejections.length > 3 
                ? 3 
                : rejectionController.rejections.length,
            (index) {
              final rejection = rejectionController.rejections[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.shade200,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rejection.documentTypeFormatted,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                rejection.timeSinceRejection,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rejection.rejectionReason,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    // Text(
                    //   'Rejeté par: ${rejection.adminName}',
                    //   style: TextStyle(
                    //     fontSize: 11,
                    //     color: Colors.grey.shade600,
                    //     fontStyle: FontStyle.italic,
                    //   ),
                    // ),
                  ],
                ),
              );
            },
          )..add(
            // Bouton "Voir tout" si plus de 3 rejets
            rejectionController.rejections.length > 3
    ? InkWell(
        onTap: () {
          _showAllRejectionsDialog(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            color: Color(0xFF1E3A8A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  'Voir tous les rejets (${rejectionController.rejections.length})',
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 2.w),
              TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 1000),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(3 * value, 0),
                    child: Opacity(
                      opacity: 0.5 + (0.5 * value),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF1E3A8A),
                        size: 3.w,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      )
    : SizedBox.shrink(),
          ),
        );
      }),
    ],
  ),
)
                  )
                  
                  
                  
                  
                  ],
                ),
              ),
            );
          })
        ],
      ),
    

      );
          
        
  }
  Widget _buildVerificationStep({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted
                  ? Colors.green.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(isCompleted?Icons.check_circle: icon, color: iconColor, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: isCompleted ? Colors.green : Color(0xFF6B7280),
                        fontWeight:
                            isCompleted ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            
            ],
          ),
        ));
  }

  void _showAllRejectionsDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
      return Center(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: 70.h,
            maxWidth: 90.w,
          ),
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          child: Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Historique complet des rejets',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white, size: 6.w),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                
                // Liste complète
                Flexible(
                  child: Obx(() {
                    return ListView.builder(
                      padding: EdgeInsets.all(3.w),
                      shrinkWrap: true,
                      itemCount: rejectionController.rejections.length,
                      itemBuilder: (context, index) {
                        final rejection = rejectionController.rejections[index];
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 2.h),
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: rejection.isResolved 
                                  ? Colors.green.shade50 
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: rejection.isResolved 
                                    ? Colors.green.shade200 
                                    : Colors.red.shade200,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(2.w),
                                      decoration: BoxDecoration(
                                        color: rejection.isResolved 
                                            ? Colors.green 
                                            : Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        rejection.isResolved 
                                            ? Icons.check 
                                            : Icons.close,
                                        color: Colors.white,
                                        size: 5.w,
                                      ),
                                    ),
                                    SizedBox(width: 3.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            rejection.documentTypeFormatted,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                          SizedBox(height: 0.5.h),
                                          Text(
                                            rejection.rejectedAt,
                                            style: TextStyle(
                                              fontSize: 9.sp,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.5.h),
                                Container(
                                  padding: EdgeInsets.all(2.5.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            color: Colors.orange,
                                            size: 4.5.w,
                                          ),
                                          SizedBox(width: 2.w),
                                          Text(
                                            'Raison du rejet:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 1.h),
                                      Text(
                                        rejection.rejectionReason,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Par: ${rejection.adminName}',
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          color: Colors.grey.shade600,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      rejection.timeSinceRejection,
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}
}
