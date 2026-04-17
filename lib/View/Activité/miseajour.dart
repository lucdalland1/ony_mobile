import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:onyfast/Api/UpdateApp/updateAppService.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/Controller/Mise_a_jour_build/MiseAJourController.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/utils/LienDowload.dart';
import 'package:onyfast/utils/compareBuildVersion.dart';
import 'package:url_launcher/url_launcher.dart';

// 🎯 Constantes de version - À mettre à jour manuellement depuis pubspec.yaml
class AppVersion {
  static const String version = '3.0.5';
  static const String buildNumber = '22';
  static const String appName = 'OnyFast';
}

class VersionAppPage extends StatefulWidget {
  const VersionAppPage({super.key});

  @override
  State<VersionAppPage> createState() => _VersionAppPageState();
}

class _VersionAppPageState extends State<VersionAppPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _floatingAnimation;


  var isAutoUpdateEnabled = false.obs;
  bool isUpdateAvailable = false;
  bool voir =false;

  final AppUpdateController APPcontroller = Get.put(AppUpdateController());

final UpdateController updateController = Get.put(UpdateController());
  @override
  void initState() { 
    super.initState();
     _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _floatingAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);

    updateController.sendUpdate();
  }
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: globalColor,
        title: Text(
          "Version de l'application",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColorModel.WhiteColor,
          ),
        ),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 30),

              // Logo de l'application
              AnimatedBuilder(
                      animation: _floatingAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatingAnimation.value),
                          child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF1D348C).withOpacity(0.2), // Ombre plus sombre
                                      spreadRadius: 10, // Étend l’ombre
                                      blurRadius: 15,  // Plus flou
                                      offset: const Offset(0, 6), // Ombre plus basse
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Image.asset(
                                    "asset/onylogo.png",
                                    fit: BoxFit.contain,
                                    width: 60,
                                    height: 60,
                                  ),
                                ),
                              )

                        );
                      },
                    ),

              SizedBox(height: 20),

              // Nom de l'application
              Text(
                AppVersion.appName,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 8),

              // Version actuelle
              Text(
                "Version ${AppVersion.version} (${AppVersion.buildNumber})",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                ),
              ),

              SizedBox(height: 30),

              // Statut de mise à jour
              if (isUpdateAvailable==true)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.orange.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade700,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Mise à jour disponible",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade900,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Version ${APPcontroller.appUpdateResponse.value.data!.buildVersion} disponible",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.orange.shade700,
                              ),
                            ),
                            Text(
                              "Publie le : ${APPcontroller.appUpdateResponse.value.data!.updateDate}",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.orange.shade700,
                              ),
                            ),
                            Text(
                              "${APPcontroller.appUpdateResponse.value.data!.updateNotes}",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.orange.shade700,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                  if(voir==true)
                  Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.green.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.green.shade700,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Votre application est à jour",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                )else SizedBox.shrink(),

              SizedBox(height: 25),

              // Section Mise à jour automatique
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 15,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: globalColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: 
                            
                            
                            Icon(
                              Icons.sync,
                              color: globalColor,
                              size: 22,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Mise à jour automatique",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Télécharger automatiquement les mises à jour",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Obx((){

                            var data=null;


                          
                            if(updateController.isLoading.value)return CupertinoActivityIndicator();
                            if(updateController.responseData.isNotEmpty){
                                data=updateController.responseData.value["data"];

                                print("voila le status :${data["is_automatique"]}");
                                isAutoUpdateEnabled.value=data["is_automatique"];
                                
                              print('data ${updateController.responseData.value}   ${updateController.responseData.value['data']['is_automatique']} ');
                            }else{
                              return CupertinoActivityIndicator();
                            }

                                return CupertinoSwitch(
                                  value: isAutoUpdateEnabled.value,
                                  activeColor: globalColor,
                                  onChanged: updateController.isLoading.value ? null : (value) {
                                    updateController.sendUpdate(isAutomatique: !isAutoUpdateEnabled.value);
                                    isAutoUpdateEnabled.value = value; // Utilise la valeur du swi
                                                            
                            },
                          );
                          }),
                          
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Bouton de mise à jour
              if (isUpdateAvailable)
                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [globalColor, globalColor.withOpacity(0.8)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: globalColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      _showUpdateDialog(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.system_update,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Mettre à jour maintenant",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: 15),

              // Bouton vérifier les mises à jour
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: globalColor,
                    width: 1.5,
                  ),
                ),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    
                    _checkForUpdates(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.refresh,
                        color: globalColor,
                        size: 24,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Vérifier les mises à jour",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: globalColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Informations supplémentaires
             

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showUpdateDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            "Mise à jour disponible",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              "Une nouvelle version ($latestVersion) est disponible. Souhaitez-vous mettre à jour maintenant ?",
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text(
                "Plus tard",
                style: TextStyle(color: Colors.grey.shade700),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text(
                "Mettre à jour",
                style: TextStyle(
                  color: globalColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                _startUpdate();
               await LienDowload();

              },
            ),
          ],
        );
      },
    );
  }

  void _checkForUpdates(BuildContext context) {
    // Simulation de vérification
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        Future.delayed(Duration(seconds: 2), () async {
           await APPcontroller.fetchAppUpdate();

          //  if(APPcontroller.)

          if(APPcontroller.appUpdateResponse.value.data==null){
            Navigator.of(context).pop();
            SnackBarService.success('Aucune mise à jour disponible');
            return ;
          }
          print(APPcontroller.appUpdateResponse.value.data);

          Navigator.of(context).pop();
          var build =APPcontroller.appUpdateResponse.value.data!.buildVersion;
          
          final versionActuel=BuildVersion(latestVersion,buildNumber);
          final VersionEnligne=BuildVersion(build,APPcontroller.appUpdateResponse.value.data!.versionCode );


          final fin=pickHigherBuild(versionActuel,VersionEnligne);

          print('voila la fin ${fin.versionName} ${latestVersion}');
          if(latestVersion==fin.versionName){
              setState(() {
                voir=false ;
              });
              SnackBarService.success('Votre application est à jour');
              return;
          }

        
           SnackBarService.info('Nouvelle version disponible ${fin.versionName}');
       
            setState(() {
            isUpdateAvailable=true;
            voir=true;

            });
          
        });

        return Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoActivityIndicator(radius: 15),
                SizedBox(height: 15),
                Text(
                  "Vérification en cours...",
                  style: TextStyle(
                    
                    fontSize: 16,
                        decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                    color: Colors.black
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startUpdate() {
    SnackBarService.info('Téléchargement de la mise à jour...');
    // Ici vous ajouterez la logique réelle de mise à jour
    // Par exemple, ouvrir le store ou télécharger l'APK
  }


}