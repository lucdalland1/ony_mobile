import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/View/Epargne/Eparne%20individuel/epargne_groupe_type.dart';
import 'package:onyfast/View/Epargne/epargne%20group%C3%A9/epargne_groupe.dart';
import 'package:onyfast/View/Epargne/Eparne%20individuel/eparne_individuelle.dart';
import 'package:onyfast/View/Epargne/soldeEpargne.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import '../Notification/notification.dart';

class EpargnePage extends StatelessWidget {
  const EpargnePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc pour correspondre à SoldeEpargnePage
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColorModel.Bluecolor242,
        title: Text(
          "Épargne",
          style: TextStyle(
            fontSize: 17.dp,
            fontWeight: FontWeight.bold,
            color: AppColorModel.WhiteColor,
          ),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        actions: [
         NotificationWidget(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),

                // Carte de solde identique à SoldeEpargnePage
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SoldeEpargnePage(),
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'solde_card',
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF006400).withOpacity(0.95), // Vert foncé (DarkGreen)
    Color(0xFF00C853).withOpacity(0.85), // Vert clair (Green Accent)
  ],
)
,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColorModel.Bluecolor242.withOpacity(0.3),
                            blurRadius: 25,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Mon Solde',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),

                // Cartes de type épargne harmonisées avec SoldeEpargnePage
                Row(
                  children: [
                    Expanded(
                      child: _epargneType(
                        icon: Icons.savings_outlined,
                        title: 'Mon épargne individuelle',
                        subtitle: 'Épargnez à votre propre rythme',
                        onTap: () {
                          Get.to(EpargneIndividuellePage());
                        },
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: _epargneType(
                        icon: Icons.groups_2_outlined,
                        title: 'Mon épargne groupée',
                        subtitle: "Épargnez ensemble avec d'autres personnes",
                        onTap: () {
                          Get.to(EpargneGroupeType());
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),

                // Description harmonisée
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Text(
                      "Épargnez de l'argent de manière individuelle ou avec un groupe",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _epargneType({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 3.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColorModel.Bluecolor242.withOpacity(0.15),
                        AppColorModel.Bluecolor242.withOpacity(0.08),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColorModel.Bluecolor242.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: AppColorModel.Bluecolor242,
                    size: 26.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5.sp,
                    letterSpacing: -0.3,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10.5.sp,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
