import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:onyfast/Color/app_color_model.dart';

class SoldeEpargnePage extends StatelessWidget {
  const SoldeEpargnePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColorModel.Bluecolor242,
        title:
        
        Hero(tag: 'solde_card', child: Text(
          "Mon Solde",
          style: TextStyle(
            fontSize: 17.dp,
            fontWeight: FontWeight.bold,
            color: AppColorModel.WhiteColor,
          ),
        )) ,
        centerTitle: true,
        leading: BackButton(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),

                      // Row: Solde total épargné avec montant
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Solde total épargné',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            '25,500 XOF',
                            style: TextStyle(
                              color: AppColorModel.Bluecolor242,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),

                      // Carte de solde avec Hero Animation
                      
                      SizedBox(height: 4.h),

                      // Détails du solde
                      _SectionHeader(title: 'Informations du Solde'),
                      SizedBox(height: 2.h),

                      _BalanceInfoCard(
                        label: 'Solde Total',
                        amount: '25,500 XOF',
                        color: AppColorModel.Bluecolor242,
                      ),
                      SizedBox(height: 2.h),

                      _BalanceInfoCard(
                        label: 'Gains Cumulés',
                        amount: '+2,150 XOF',
                        color: Colors.green,
                      ),
                      SizedBox(height: 2.h),

                      _BalanceInfoCard(
                        label: 'Objectif',
                        amount: '50,000 XOF',
                        color: Colors.orange,
                      ),
                      SizedBox(height: 4.h),

                      // Progression vers l'objectif
                      _SectionHeader(title: 'Progression'),
                      SizedBox(height: 2.h),

                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '51%',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColorModel.Bluecolor242,
                                  ),
                                ),
                                Text(
                                  'vers votre objectif',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.5.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: 0.51,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColorModel.Bluecolor242,
                                ),
                              ),
                            ),
                            SizedBox(height: 1.5.h),
                            Text(
                              'Il vous reste 24,500 XOF pour atteindre votre objectif',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3.h),
                    ],
                  ),
                ),
              ),
            ),

            // Bouton Retirer l'épargne en bas de la page
            Padding(
              padding: EdgeInsets.all(5.w),
              child: SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Demande de retrait en cours...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    'Retirer l\'épargne',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _SectionHeader({required String title}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _BalanceInfoCard({
    required String label,
    required String amount,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
