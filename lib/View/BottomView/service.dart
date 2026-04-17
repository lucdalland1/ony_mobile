// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_sizer/flutter_sizer.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:onyfast/Controller/numero_status_mobile_money.dart';
// import 'package:onyfast/Controller/verou/verroucontroller.dart';
// import 'package:onyfast/View/Activité/recharger_mon_compte.dart';
// import 'package:onyfast/View/Coffre/coffre.dart' as coffre;
// import 'package:onyfast/View/Coffre/coffre.dart';
// import 'package:onyfast/View/Epargne/epargne.dart';
// import 'package:onyfast/View/Factures/facturewallet.dart';
// import 'package:onyfast/View/Gerer_cartes/gerer_mes_cartes.dart';
// import 'package:onyfast/View/Merchand/view/merchant_view.dart';
// import 'package:onyfast/View/Notification/notification.dart';
// import 'package:onyfast/View/Recevoir/Qr%20Code/scan_qr.dart';
// import 'package:onyfast/View/const.dart';
// import 'package:onyfast/View/menuscreen.dart';
// import 'package:onyfast/Widget/notificationWidget.dart';
// import 'package:onyfast/verificationcode.dart';

// class ServicesPage extends StatefulWidget {
//   const ServicesPage({super.key});

//   @override
//   State<ServicesPage> createState() => _ServicesPageState();
// }

// class _ServicesPageState extends State<ServicesPage> {
  

//    @override
//   void initState() {
//     super.initState();
//     AppSettingsController.to.setInactivity(true);
//     Get.put(RechargeStatusController()).fetchRechargeStatus();
//   }
//   @override
//   Widget build(BuildContext context) {
//     AppSettingsController.to.setInactivity(true);
//     return Scaffold(
//         backgroundColor:globalColor,
//         body: GestureDetector(
//           onTap: () {
//             FocusScope.of(context).unfocus();
//           },
//           child: SafeArea(
//             child: Container(
//               color: Colors.white,
//               child: Column(
//               children: [
//                 _buildAppBar(context),
//                 Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.all(4.w),
//                     child: GridView.count(
//                       crossAxisCount: 3,
//                       mainAxisSpacing: 2.h,
//                       crossAxisSpacing: 6.w,
//                       childAspectRatio: 0.8,
//                       children: _buildServiceCards(context),
//                     ),
//                   ),
//                 ),
//               ],
//             )
//             ),
//           ),
//         ));
//   }

//   Widget _buildAppBar(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFF1E3A8A), globalColor],
//           begin: Alignment.bottomCenter,
//           end: Alignment.topCenter,
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 30.dp,
//             height: 30.dp,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white,
//               border: Border.all(color: Colors.white, width: 2),
//             ),
//             child: Center(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(10.dp),
//                 child: Image.asset(
//                   "asset/onylogo.png",
//                   height: 27.dp,
//                   width: 27.dp,
//                 ),
//               ),
//             ),
//           ),
//           Spacer(),
//           Text(
//             'Services',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 16.sp,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Spacer(),
//           NotificationWidget(),
//           SizedBox(width: 2.w),
//           //

//           IconButton(
//             onPressed: () {
//               Get.find<GlobalDrawerController>().openDrawer();
//             },
//             icon: Icon(CupertinoIcons.ellipsis_vertical, color: Colors.white),
//           )
//         ],
//       ),
//     );
//   }

//   List<Widget> _buildServiceCards(BuildContext context) {
//     return [
//       _serviceCard(
//         context,
//         'Transfert',
//         'asset/transfert-qr.svg',
//         Color(0xFF17338D),
//         (){
//             CodeVerification().show(context, () async {
//                                           if (Navigator.of(context).canPop()) {
//  Navigator.pop(context);} 

//                                           Get.to(ScanQr(),
//                                             transition: Transition.cupertino); });
//         },
//       ),
//       _serviceCard(
//         context,
//         'Marchands',
//         'asset/marchands.svg',
//         Color(0xFFf7931e),
//         () => Get.to(MerchantPage(), transition: Transition.cupertino),
//       ),
//       _serviceCard(
//           context,
//           'Cartes',
//           'asset/cartes.svg',
//           Color(0xFF355AD0),
//           () => Get.to(
//                 ManageCardsPage(),
//                 transition: Transition.cupertino,
//               )),
//       _serviceCard(
//         context,
//         'Virement',
//         'asset/virement.svg',
//         Color(0xFFC1272D),
//         () => _showComingSoon(context),
//       ),
//       _serviceCard(
//         context,
//         'Bonus',
//         'asset/bonus.svg',
//         Color(0xFF7198FE),
//         () => _showComingSoon(context),
//       ),
//       _serviceCard(
//         context,
//         'Coffre',
//         'asset/coffre-2.svg',
//         Color(0xFF7969D2),
//         () => Get.to(
//           CoffreAccueilScreen(),
//           transition: Transition.cupertino,
//         ),
//       ),
//       _serviceCard(
//         context,
//         'Epargne',
//         'asset/epargne.svg',
//         Color(0xFF34AB73),
//         () => _showComingSoon(context),
//       ),
//       _serviceCard(
//         context,
//         'Crédit',
//         'asset/credit.svg',
//         Color(0xFF000000),
//         () => _showComingSoon(context),
//       ),
//       _serviceCard(
//           context,
//           'Recharge',
//           'asset/charge-extra-money-svgrepo-com.svg',
//           Colors.teal,
//           () => Get.to(RechargePage(), transition: Transition.cupertino)),

//      _serviceCard(
//           context,
//           'Factures',
//           'asset/iconefacture.svg',
//           Color(0xFFF44336),  // Material Red,
//           () => Get.to(FactureWallet(), transition: Transition.cupertino)),
//     ];
//   }

//   Widget _serviceCard(BuildContext context, String title, String iconPath,
//       Color color, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             width: 20.w,
//             height: 20.w,
//             padding: EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: color,
//               shape: BoxShape.circle,
//             ),
//             child: SvgPicture.asset(
//               iconPath,
//               color: Colors.white,
//             ),
//           ),
//           SizedBox(height: 1.h),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w900,
//               color: globalColor,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   void _showComingSoon(BuildContext context) {
//     showCupertinoDialog(
//       context: context,
//       builder: (_) => CupertinoAlertDialog(
//         title: Text('Bientôt disponible'),
//         content: Text('Cette fonctionnalité sera disponible prochainement'),
//         actions: [
//           CupertinoDialogAction(
//             child: Text('OK'),
//             onPressed: () => Get.back(),
//           )
//         ],
//       ),
//     );
//   }
// }
