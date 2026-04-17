// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:get/get.dart';
// import 'package:onyfast/Controller/expediteurcontroller.dart';
// import '../../Api/transactionwallet.dart';
// import '../../Api/user_inscription.dart';
// import '../../Color/app_color_model.dart';
// import '../../Controller/transactionwalletcontroller.dart';
// import '../../Crypte & Decrypte/crypte.dart';
// import '../../Widget/container.dart';
// import '../../Widget/icon.dart';

// /// Classe principale pour le scanner de code-barres
// class PayerScan extends StatefulWidget {
//   const PayerScan({super.key});

//   @override
//   State<PayerScan> createState() => _HomePageState();
// }

// class _HomePageState extends State<PayerScan> {
//   String barcode = 'Appuyez pour scanner';
//   final TextEditingController _controller = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final EncryptionController controller = Get.put(EncryptionController());
//     //final ExpediteurController expediteurcontroller = Get.put(ExpediteurController());
//     final RechargeWalletController rechargeController = Get.put(RechargeWalletController());
//     final TextEditingController montantController = TextEditingController();

//   final AuthController connexion = Get.find();
//     var user = connexion.getUser();
//  TextEditingController textEditingController = TextEditingController();
//     void handleTransaction() async {
//       final result = await TransactionService().makeTransaction(
//           fromTelephone: textEditingController.text,
//           toTelephone:_controller.text,
//           amount: montantController.text,
//           context: context);
//     }

//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     return Material(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ContainerWidget(
//               height: screenHeight * 0.08,
//               width: screenWidth,
//               color: AppColorModel.BlueColor,
//             ),
//             ContainerWidget(
//               height: screenHeight * 0.1,
//               width: screenWidth,
//               color: AppColorModel.WhiteColor,
//               child: Row(
//                 children: [
//                   Gap(10),
//                   Image.asset(
//                     "asset/onylogo.png",
//                     height: screenHeight * 0.05,
//                     width: screenWidth * 0.1,
//                   ),
//                   Gap(20),
//                   Text(
//                     "Payer avec QR code ".tr,
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: AppColorModel.BlueColor,
//                       fontSize: screenWidth * 0.05,
//                     ),
//                   ),
//                   Spacer(),
//                   IconButtonWidget(
//                     onPressed: () {},
//                     icon: Icon(Icons.notifications_sharp,
//                         color: AppColorModel.BlueColor),
//                   ),
//                 ],
//               ),
//             ),
//             Gap(10),
//             ContainerWidget(
//             height: 200,
//             width: 340,
//             color:AppColorModel.DeepPurple,
//             borderRadius: BorderRadius.circular(10),
//             child: Image.asset(
//               "asset/MAQUETTE APPLICATION ONYSAT-19.png",
//               fit: BoxFit.cover,
//             ),
//           ),
//           Gap(50),
//             InkWell(
//               onTap: () async{
//                   await Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (context) => AiBarcodeScanner(
//                     onDispose: () {
//                       debugPrint("Scanner de code-barres supprimé !");
//                     },
//                     controller: MobileScannerController(
//                       detectionSpeed: DetectionSpeed.noDuplicates,
//                     ),
//                     onDetect: (BarcodeCapture capture) {
//                       final String? scannedValue = capture.barcodes.first.rawValue;
//                       if (scannedValue != null) {
//                         // Déchiffrer la donnée scannée
//                         String decryptedValue = controller.decryptData(scannedValue);
//                         debugPrint("Code-barres scanné : $decryptedValue");
      
//                         // Mettre à jour le champ bénéficiaire avec la donnée déchiffrée
//                         _controller.text = decryptedValue;
      
//                         // Affiche le code-barres déchiffré dans un dialogue
//                         showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return AlertDialog(
//                               title: Text("Envoyer de l'argent de façon sécuriser", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),),
//                               content: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                 Column(
//                                     children: [
//                                       TextFormField(
//                                         controller:textEditingController,
//                                         enabled: false, // Champs désactivés
//                                         decoration: InputDecoration(labelText: 'Expéditeur'),
//                                       ),
//                                       SizedBox(height: 16), // Remplacement de Gap par SizedBox
//                                    TextFormField(
//                                         controller:_controller,
//                                         enabled: false, // Champs désactivés
//                                         decoration: InputDecoration(labelText: 'Bénéficiaire'),
//                                       ),
//                                        TextField(
//                                     controller: montantController,
//                                     onChanged: (value) => rechargeController.updateMontant(double.tryParse(value) ?? 0),
//                                     decoration: InputDecoration(
//                                       labelText: 'Montant',
//                                       hintText: "A partir de 1000f",
//                                     ),
//                                     keyboardType: TextInputType.number,
//                                   ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 30), // Remplacement de Gap par SizedBox
//                                    Obx(() => InkWell(
//                       onTap: rechargeController.montant.value >= 1000
//                           ? () {
//                               handleTransaction();
//                             }
//                           : null,
//                       child: Container(
//                         height: 40,
//                         width: 320,
//                         decoration: BoxDecoration(
//                           color: rechargeController.montant.value >= 1000
//                               ? AppColorModel.DeepPurple
//                               : Colors.grey,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Center(
//                           child: Text(
//                             "Effectuer la transaction".tr,
//                             style: TextStyle(
//                                 color: AppColorModel.WhiteColor,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ),
//                     )),
//                                   Gap(10),
//                                   TextButton(
//                                     onPressed: () {
//                                       Navigator.of(context).pop(); // Ferme le dialogue
//                                     },
//                                     child: const Text('Fermer'),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         );
//                       } else {
//                         debugPrint("Aucune donnée scannée !");
//                       }
//                     },
//                   ),
//                 ),
//               );
//               },
//               child: ContainerWidget(
//               height: 40,
//               width: 348,
              
//               color: AppColorModel.DeepPurple,
//                          borderRadius: BorderRadius.circular(10),
              
//               child: Center(
//                 child: Text(
//                   "Faites votre paiement",
//                   style: TextStyle(
//                       color: AppColorModel.WhiteColor,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ),
//                         ),
//             ),

//         ],
//       ),
//     );
//   }
// }