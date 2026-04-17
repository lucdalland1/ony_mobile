import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import '../BottomView/profiluser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Route/route.dart';
import '../../Color/app_color_model.dart';
import '../Notification/notification.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:onyfast/View/Activit%C3%A9/miseajour.dart';
import 'package:onyfast/View/Parametre/localisationview.dart';
import 'package:onyfast/View/Activit%C3%A9/securitePage.dart';
import 'package:onyfast/View/Activit%C3%A9/mode_application.dart';


class WebViewPage extends StatelessWidget {
  final String title;
  final String url;

  const WebViewPage({super.key, required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
          leading: BackButton(
            color: Colors.white,
          ),
          backgroundColor: globalColor,
          title: Text(
            title,
            style: TextStyle(
                fontSize: 16.dp,
                color: AppColorModel.WhiteColor),
          )),
      body: WebViewWidget(controller: controller),
    );
  }
}

class ParametresScreen extends StatelessWidget {
  const ParametresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: globalColor,
        title: Text(
          "Paramètres",
          style: TextStyle(
              fontSize: 16.sp,
              color: AppColorModel.WhiteColor),
        ),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
        actions: [
         NotificationWidget(),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 2.h),

            // Menu items avec design amélioré
             Container(
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.w),
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
    //                 {
    //   'icon': CupertinoIcons.map_fill,
    //   'label': 'Localisation',
    //   'page': LocationSharingScreen()
    // },
                  // _buildSettingItem(Icons.face, "Configurer Face ID / Empreinte", () {showComingSoon(context);}, 0, 9),
                  _buildSettingItem(Icons.security, "Sécurité", () {
                    Get.to(SecuritePage());
                  }, 1, 9),
                  _buildSettingItem(
                      CupertinoIcons.map_fill, "Localisation", () {
                        Get.to(Localisationview());
                      }, 2, 9),
                  _buildSettingItem(
                      Icons.notifications, "Notifications", () {}, 2, 9),
                  _buildSettingItem(
                      Icons.privacy_tip, "Données et confidentialité", () {
                    showComingSoon(context);
                  }, 3, 9),
                  _buildSettingItem(
                      CupertinoIcons.doc_append, "Politique de Confidentialité",
                      () async {
                    final url = 'https://onyfast.com/privacy.html';

                    try {
                      Get.to(
                        () => WebViewPage(
                          title: 'Politique de confidentialité',
                          url: url,
                        ),
                        transition: Transition
                            .cupertino, // 👈 iOS-style slide transition
                      );
                    } catch (e) {
                      print('❌ Erreur lors de l\'ouverture de la page : $e');
                      SnackBarService.error(
                          'Impossible d\'ouvrir la page de confidentialité.');
                    }
                  }, 4, 9),
                  _buildSettingItem(CupertinoIcons.lock_shield,
                      "Conditions Générales d'Utilisation", () async {
                    final url = ('https://onyfast.com/cgu.html');
                    try {
                      Get.to(
                        () => WebViewPage(
                          title: "Conditions Générales d'Utilisation",
                          url: url,
                        ),
                        transition: Transition
                            .cupertino, // 👈 iOS-style slide transition
                      );
                    } catch (e) {
                      print('❌ Erreur lors de l\'ouverture de la page : $e');
                      SnackBarService.error(
                          'Impossible d\'ouvrir la page de Conditions.');
                    }
                  }, 5, 9),
                  _buildSettingItem(Icons.color_lens, "Mode clair / sombre",
                      () {
                    // Get.to(ThemeModePage());
                  }, 6, 9),
                  _buildSettingItem(Icons.language, "Langue", () {
                    showComingSoon(context);
                  }, 7, 9),
                //   _buildSettingItem(Icons.info_outline, "Version de l'application", () {Get.to(VersionAppPage());}, 8, 9), 
                ],
              ),
            ),
            // /* _buildSettingItem(Icons.info_outline, "Version de l'application", () {Get.to(VersionAppPage());}, 8, 9), */
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

 Widget _buildSettingItem(IconData icon, String title, VoidCallback onTap,
    int index, int totalItems) {
  return Column(
    children: [
      Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onTap,
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
                    icon,
                    color: globalColor,
                    size: 5.5.w,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
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
      ),
      if (index < totalItems - 1)
        Container(
          height: 0.5,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          color: Colors.grey.shade300,
        ),
    ],
  );
}

}
