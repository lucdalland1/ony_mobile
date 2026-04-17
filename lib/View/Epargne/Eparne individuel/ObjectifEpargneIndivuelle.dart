import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

class MonEpargnePage extends StatelessWidget {
  const MonEpargnePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Liste statique des objectifs
    final List<Map<String, String>> objectifs = [
      {
        'nom': 'Vacances',
        'actuel': '25,500',
        'cible': '100,000',
      },
      {
        'nom': 'Urgence',
        'actuel': '12,500',
        'cible': '50,000',
      },
      {
        'nom': 'Formation',
        'actuel': '5,000',
        'cible': '20,000',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green.shade800,
        title: const Text(
          "Mon Épargne",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bloc Mon Épargne
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.green.shade900.withOpacity(0.95),
                              Colors.green.shade700.withOpacity(0.85),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.shade900.withOpacity(0.35),
                              blurRadius: 25,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mon Épargne',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Solde Total : 25,500 XOF',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Gains Cumulés : 2,150 XOF',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Objectif : 50,000 XOF',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),

                      // Liste des objectifs
                      Text(
                        'Objectifs à atteindre',
                        style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      SizedBox(height: 2.h),

                      ...objectifs.map((objectif) => _objectifCard(objectif)),

                      SizedBox(height: 3.h),

                      // Bouton + Créer un objectif
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: 6.h,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Action pour créer un objectif
                            },
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'Créer un Objectif',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade800,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _objectifCard(Map<String, String> objectif) {
    final double progress = double.parse(objectif['actuel']!.replaceAll(',', '')) /
        double.parse(objectif['cible']!.replaceAll(',', ''));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              objectif['nom']!,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 1.h),
            Text('${objectif['actuel']} / ${objectif['cible']} XOF'),
            SizedBox(height: 1.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
              ),
            ),
            SizedBox(height: 1.h),
          ],
        ),
      ),
    );
  }
}
