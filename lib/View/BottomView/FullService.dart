import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/numero_status_mobile_money.dart';
import 'package:onyfast/View/Activité/recharger_mon_compte.dart';
import 'package:onyfast/View/Coffre/coffre.dart';
import 'package:onyfast/View/Factures/facturewallet.dart';
import 'package:onyfast/View/Gerer_cartes/gerer_mes_cartes.dart';
import 'package:onyfast/View/Merchand/view/merchant_view.dart';
import 'package:onyfast/View/Recevoir/Qr%20Code/scan_qr.dart';
import 'package:onyfast/Widget/dialog.dart';
import 'package:onyfast/verificationcode.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    Get.put(RechargeStatusController()).fetchRechargeStatus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _services => [
        {
          'label': 'Transfert',
          'icon': 'asset/transfert-qr.svg',
          'color': const Color(0xFF17338D),
          'onTap': () {
            CodeVerification().show(Get.context!, () async {
              if (Navigator.of(Get.context!).canPop()) {
                Navigator.pop(Get.context!);
              }
              Get.to(ScanQr(), transition: Transition.cupertino);
            });
          },
        },
        {
          'label': 'Marchands',
          'icon': 'asset/marchands.svg',
          'color': const Color(0xFFf7931e),
          'onTap': () =>
              Get.to(MerchantPage(), transition: Transition.cupertino),
        },
        // {
        //   'label': 'Cartes',
        //   'icon': 'asset/cartes.svg',
        //   'color': const Color(0xFF355AD0),
        //   'onTap': () =>
        //       Get.to(ManageCardsPage(), transition: Transition.cupertino),
        // },
        {
          'label': 'Recharge',
          'icon': 'asset/charge-extra-money-svgrepo-com.svg',
          'color': Colors.teal,
          'onTap': () =>
              Get.to(RechargePage(), transition: Transition.cupertino),
        },
        {
          'label': 'Bonus',
          'icon': 'asset/bonus.svg',
          'color': const Color(0xFF7198FE),
          'onTap': () => _showComingSoon(),
        },
        {
          'label': 'Coffre',
          'icon': 'asset/coffre-2.svg',
          'color': const Color(0xFF7969D2),
          'onTap': () =>
              Get.to(CoffreAccueilScreen(), transition: Transition.cupertino),
        },
        {
          'label': 'Epargne',
          'icon': 'asset/epargne.svg',
          'color': const Color(0xFF34AB73),
          'onTap': () => _showComingSoon(),
        },
        {
          'label': 'Crédit',
          'icon': 'asset/credit.svg',
          'color': const Color(0xFF000000),
          'onTap': () => _showComingSoon(),
        },
        {
          'label': 'Virement',
          'icon': 'asset/virement.svg',
          'color': const Color(0xFFC1272D),
          'onTap': () => _showComingSoon(),
        },
        {
          'label': 'Factures',
          'icon': 'asset/iconefacture.svg',
          'color': const Color(0xFFF44336),
          'onTap': () =>_showComingSoon()
            //  Get.to(FactureWallet(), transition: Transition.cupertino),
        },
      ];

  List<Map<String, dynamic>> get _filtered => _query.isEmpty
      ? _services
      : _services
          .where((s) => s['label']
              .toString()
              .toLowerCase()
              .contains(_query.toLowerCase()))
          .toList();

  void _showComingSoon() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── AppBar ──
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Row(
                        children: [
                          Icon( 
        Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios_new,
                              color: const Color(0xFF1A1A2E)),
                          Text(
                            'Menu',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                  ],
                ),
              ),

              // ── Titre ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'Services',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ),

              SizedBox(height: 2.h),

              // ── Barre de recherche ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    style: TextStyle(fontSize: 11.sp),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un service...',
                      hintStyle: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[400],
                      ),
                      prefixIcon: Icon(Icons.search,
                          color: Colors.grey[400], size: 5.w),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 2.5.h),

              // ── Grille ──
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 3.w,
                      mainAxisSpacing: 2.h,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final service = _filtered[index];
                      return _ServiceTile(
                        label: service['label'],
                        iconPath: service['icon'],
                        color: service['color'],
                        onTap: service['onTap'],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final String label;
  final String iconPath;
  final Color color;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.label,
    required this.iconPath,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Cercle gris externe ──
            Container(
              width: 20.w,
              height: 20.w,
              decoration: const BoxDecoration(
                color: Color(0xFFEEEEEE),
                shape: BoxShape.circle,
              ),
              child: Center(
                // ── Cercle coloré interne ──
                child: Container(
                  width: 13.w,
                  height: 13.w,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(2.8.w),
                    child: SvgPicture.asset(
                      iconPath,
                      color: Colors.white,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 1.2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}