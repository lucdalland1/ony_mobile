import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:onyfast/View/Epargne/Eparne%20individuel/ObjectifEpargneIndivuelle.dart';
import 'package:onyfast/View/Epargne/Eparne%20individuel/fondcommunpage.dart';

class EpargneIndividuellePage extends StatelessWidget {
  const EpargneIndividuellePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A2149),
        title: const Text('Épargne', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            // Bloc 1 : Mes Fonds Commun de Placement
            _soldeButton(
              title: "Mes Fonds Commun de Placement",
              amount: "75,000 XOF",
              gradientColors: [
                Colors.orange.shade900.withOpacity(0.95),
                Colors.orange.shade600.withOpacity(0.85),
              ],
              onTap: () {
                Get.to(const FondsCommunPage());
                // Action sur le clic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Clique sur Mes Fonds Commun de Placement"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            SizedBox(height: 4.h),

            // Bloc 2 : Mon Épargne
            _soldeButton(
              title: "Mon Épargne",
              amount: "25,500 XOF",
              gradientColors: [
                Colors.green.shade900.withOpacity(0.95),
                Colors.green.shade600.withOpacity(0.85),
              ],
              onTap: () {
                Get.to(const MonEpargnePage());
                // Action sur le clic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Clique sur Mon Épargne"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _soldeButton({
    required String title,
    required String amount,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.35),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              amount,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
