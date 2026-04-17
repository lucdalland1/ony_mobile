// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:gap/gap.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// // import 'package:onyfast/View/Configuration/configuration.dart';
// import 'package:onyfast/View/Merchand/controller/view/merchant.dart';
// import 'package:onyfast/View/Payer/Payerphone.dart';
// import 'package:onyfast/View/Payer/Payerscan.dart';
// import 'package:onyfast/View/Recharge/recharge.dart';
// import 'package:onyfast/View/Recevoir/onyfast.dart';
// import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
// import '../Color/app_color_model.dart';
// import '../Controller/containercontroller.dart';
// import '../Api/user_inscription.dart';
// import '../Controller/usermodelcontroller.dart';
// import '../View/Configuration/platfond.dart';
// import 'container.dart';

// class MenuWallet extends StatelessWidget {
//   MenuWallet({
//     super.key,
//     required this.screenWidth,
//     required this.controller,
//   });
//   final box = GetStorage(); // Instance de GetStorage
//   final UserController userController = Get.put(UserController());

//   final AuthController connexion = Get.find();

//   SliverWoltModalSheetPage page1(
//       BuildContext modalSheetContext, TextTheme textTheme) {
//     return WoltModalSheetPage(
//         hasSabGradient: false,
//         stickyActionBar: Padding(
//           padding: const EdgeInsets.all(08),
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(
//                     left: 09, top: 10, right: 10, bottom: 1),
//                 child: InkWell(
//                   onTap: () {
//                     Get.to(Onyfast());
//                   },
//                   child: Row(
//                     children: [
//                       ContainerWidget(
//                         height: 40,
//                         width: 70,
//                         child: Image.asset(
//                           "asset/oony.jpeg",
//                           height: 7,
//                           width: 8,
//                         ),
//                       ),
//                       Gap(10),
//                       Text(
//                         "Onyfast",
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 15),
//                       ),
//                       Divider(color: AppColorModel.BlueColor),
//                     ],
//                   ),
//                 ),
//               ),
//               Divider(color: AppColorModel.GreyWhite),
//               Gap(5),
//               Padding(
//                 padding: const EdgeInsets.only(
//                     left: 30, top: 10, right: 10, bottom: 10),
//                 child: InkWell(
//                   onTap: () {
//                     Get.to(Recharge());
//                   },
//                   child: Row(
//                     children: [
//                       Text(
//                         "💰",
//                         style: TextStyle(fontSize: 20),
//                       ),
//                       Gap(20),
//                       Text(
//                         "Mobile Money",
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 15),
//                       ),
//                       Divider(color: AppColorModel.BlueColor),
//                     ],
//                   ),
//                 ),
//               ),
//               Gap(30),
//             ],
//           ),
//         ));
//   }

// SliverWoltModalSheetPage page2(
//       BuildContext modalSheetContext, TextTheme textTheme) {
//     return WoltModalSheetPage(
//         hasSabGradient: false,
//         stickyActionBar: Padding(
//           padding: const EdgeInsets.all(08),
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left: 09, top: 10, right:10, bottom: 1),
//                 child: InkWell(
//                   onTap: () {
//                     Get.to(PayerScan());
//                   },
//                   child: Row(
//                     children: [
//                       ContainerWidget(
//                         height:40 ,
//                         width: 70,
//                         child: SvgPicture.asset(
//                                     "asset/scanner.svg",
//                                     height:7,
//                                     width: 8,
//                                   ),
//                       ),
//                       Gap(10),
//                       Text("Scan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
//                       Divider(color: AppColorModel.BlueColor),
//                     ],
//                   ),
//                 ),
//               ),
//               Divider(color: AppColorModel.GreyWhite),
//               Gap(5),
//                 Padding(
//                 padding: const EdgeInsets.only(left: 30, top: 10, right:10, bottom: 10),
//                 child: InkWell(
//                   onTap: () {
//                     Get.to(PayerPhone());                  },
//                   child: Row(
//                     children: [
//                       Text("📱", style: TextStyle(fontSize: 20),),
//                       Gap(20),
//                       Text("Par le numéro de téléphone", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
//                       Divider(color: AppColorModel.BlueColor),
//                     ],
//                   ),
//                 ),
//               ),
//               Gap(30),
//             ],
//           ),
//         ));
//   }
//  void _showDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           actions: [
//             Column(
//               children: [
//                 Container(
//                   height: 2,
//                   width: 250,
//                   decoration: BoxDecoration(
//                     color: AppColorModel.Grey,
//                   ),
//                 ),
//                 const Gap(10),
//                 TextButton(
//                   onPressed: () {
//                     // Navigator.push(
//                     //     context,
//                     //     MaterialPageRoute(
//                     //         builder: (context) => Configuration()));
//                   },
//                   child: Text(
//                     "configuration".tr,
//                     style: TextStyle(color: AppColorModel.black, fontSize: 19),
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => Platfond()));
//                   },
//                   child: Text(
//                     "augmenter son plafond".tr,
//                     style: TextStyle(color: AppColorModel.black, fontSize: 18),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }

//   final double screenWidth;
//   final ContainerController controller;

//   final AuthController authController = Get.find();
//   final AuthController connexionController = Get.find();

//   @override
//   Widget build(BuildContext context) {
//     // Récupérer les informations stockées
//     var user = connexion.getUser();
//     var wallet = connexion.getWallet();
//     var token = connexion.getToken();
//     return Stack(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(10),
//           child: Container(
//             height: 530,
//             width: screenWidth,
//             child: Image.asset(
//               'asset/APPLICATION ONYFAST 3.png',
//               height: 530,
//               width: screenWidth,
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//         Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal: screenWidth * 0.03,
//             vertical: screenWidth * 0.05,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               IconButton(
//                 onPressed: () {},
//                 icon: Icon(
//                   Icons.notifications_sharp,
//                   size: 35,
//                   color: AppColorModel.WhiteColor,
//                 ),
//               ),
//               IconButton(
//                 onPressed: () {
//                   _showDialog(context);
//                 },
//                 icon: Icon(
//                   Icons.more_vert,
//                   size: 40,
//                   color: AppColorModel.WhiteColor,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Positioned(
//           bottom: 420,
//           left: screenWidth * 0.4,
//           child: Text(
//             "Wallet".tr,
//             style: TextStyle(
//               fontSize: 35,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         Positioned(
//             bottom: 370,
//             left: screenWidth * 0.22,
//             child: Text(
//               '${wallet?.solde ?? '0'} FCFA',
//               style: TextStyle(
//                 fontSize: 35,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             )),
//         Positioned(
//           bottom: 150,
//           left: 0,
//           child: SizedBox(
//             height: 200,
//             width: screenWidth,
//             child: Obx(() {
//               return ListView.builder(
//                 itemCount: controller.containers.length,
//                 scrollDirection: Axis.horizontal,
//                 itemBuilder: (context, index) {
//                   final secondImage = (index < controller.second.length)
//                       ? controller.second[index]
//                       : 'asset/placeholder.png';

//                   return Row(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: Container(
//                           height: 220,
//                           width: screenWidth * 0.8,
//                           child: Stack(
//                             children: [
//                               Positioned(
//                                 child: Image.asset(
//                                   controller.containers[index],
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: 147,
//                                 left: 200,
//                                 child: Text(
//                                   "2 OOO XAF",
//                                   style: TextStyle(
//                                     color: AppColorModel.WhiteColor,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: 120,
//                                 left: 80,
//                                 child: Row(
//                                   children: [
//                                     Text(
//                                       "IDENTIFIANT :".tr,
//                                       style: TextStyle(
//                                         color: AppColorModel.WhiteColor,
//                                       ),
//                                     ),
//                                     Text(
//                                       "19990088",
//                                       style: TextStyle(
//                                         color: AppColorModel.WhiteColor,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: 100,
//                                 left: 80,
//                                 child: Row(
//                                   children: [
//                                     Text(
//                                       "**** **** ****",
//                                       style: TextStyle(
//                                         color: AppColorModel.WhiteColor,
//                                       ),
//                                     ),
//                                     Gap(5),
//                                     Text(
//                                       "1889",
//                                       style: TextStyle(
//                                         color: AppColorModel.WhiteColor,
//                                         fontSize: 15,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: 70,
//                                 left: 180,
//                                 child: Row(
//                                   children: [
//                                     Column(
//                                       children: [
//                                         Text(
//                                           "EXPIRE",
//                                           style: TextStyle(
//                                             color: AppColorModel.WhiteColor,
//                                             fontSize: 6,
//                                           ),
//                                         ),
//                                         Text(
//                                           "A FIN",
//                                           style: TextStyle(
//                                             color: AppColorModel.WhiteColor,
//                                             fontSize: 6,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     Gap(5),
//                                     Text(
//                                       "06 / 27",
//                                       style: TextStyle(
//                                         color: AppColorModel.WhiteColor,
//                                         fontSize: 15,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: 30,
//                                 left: 160,
//                                 child: Text(
//                                   "OPIMBA Rosca",
//                                   style: TextStyle(
//                                     color: AppColorModel.WhiteColor,
//                                     fontSize: 15,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () {},
//                         icon: Icon(Icons.arrow_back_ios,
//                             color: AppColorModel.WhiteColor),
//                       ),
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: Container(
//                           height: 180,
//                           width: screenWidth * 0.8,
//                           child: Image.asset(
//                             secondImage,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               );
//             }),
//           ),
//         ),
//         Positioned(
//           top: 400,
//           left: 0,
//           child: Padding(
//             padding: const EdgeInsets.only(left: 13, bottom: 10, top: 10, right: 10),
//             child: Row(
//               children: [
//                 InkWell(
//                   onTap: () {
//                     WoltModalSheet.show<void>(
//                       context: context,
//                       pageListBuilder: (modalSheetContext) {
//                         final textTheme = Theme.of(context).textTheme;
//                         return [
//                           page2(modalSheetContext, textTheme),
//                         ];
//                       },
//                     );
//                   },
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Container(
//                       height: 80,
//                       width: (screenWidth - 35) / 3.8,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Stack(
//                         children: [
//                           Image.asset("asset/payer.png"),
//                           Positioned(
//                             bottom: 08,
//                             left: 21,
//                             child: Text(
//                               'Payer',
//                               style: TextStyle(
//                                 color: AppColorModel.BlueColor,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 for (var asset in ["asset/recevoir.png"])
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Container(
//                         height: 80,
//                         width: (screenWidth - 35) / 3.8,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Stack(
//                           children: [
//                             Image.asset(asset),
//                             Positioned(
//                               bottom: 08,
//                               left: 13,
//                               child: Text(
//                                 'Recevoir',
//                                 style: TextStyle(
//                                   color: AppColorModel.BlueColor,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         )),
//                   ),
//                 Stack(
//                   children: [],
//                 ),
//                 InkWell(
//                   onTap: () {
//                     WoltModalSheet.show<void>(
//                       context: context,
//                       pageListBuilder: (modalSheetContext) {
//                         final textTheme = Theme.of(context).textTheme;
//                         return [
//                           page1(modalSheetContext, textTheme),
//                         ];
//                       },
//                     );
//                   },
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Container(
//                       height: 80,
//                       width: (screenWidth - 35) / 3.8,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Stack(
//                         children: [
//                           Image.asset("asset/recharge-1.png"),
//                           Positioned(
//                             bottom: 08,
//                             left: 13,
//                             child: Text(
//                               'Recharger',
//                               style: TextStyle(
//                                 color: AppColorModel.BlueColor,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 InkWell(
//                   onTap: () {
//                     Get.to(Merchand());
//                   },
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Container(
//                       height: 80,
//                       width: (screenWidth - 35) / 4,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Stack(
//                         children: [
//                           Image.asset("asset/Marchand.png"),
//                           Positioned(
//                             bottom: 08,
//                             left: 13,
//                             child: Text(
//                               'Marchand',
//                               style: TextStyle(
//                                 color: AppColorModel.BlueColor,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
