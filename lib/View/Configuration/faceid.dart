// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:gap/gap.dart';
// import 'package:get/get.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:onyfast/Controller/faceidcontroller.dart';

// import '../../Color/app_color_model.dart';
// import '../../Widget/container.dart';
// import '../../Widget/icon.dart';

// class FaceId extends StatefulWidget {
//   const FaceId({super.key});

//   @override
//   _FaceIdState createState() => _FaceIdState();
// }

// class _FaceIdState extends State<FaceId> {
//    late final LocalAuthentication auth;
//   bool _supportState=false;
   
//     @override
//   void initState() {
//     super.initState();
//     auth=LocalAuthentication();
//     auth.isDeviceSupported().then(
//       (bool isSupported)=>setState(() {
//         _supportState=isSupported;
//       })
//     );
//   }
//   Future<void> _getAvailableBiometrics() async {
//     late List<BiometricType> availableBiometrics;
//     try {
//       availableBiometrics = await auth.getAvailableBiometrics();
//       print("Liste des biométries disponibles : $availableBiometrics");
//     } on PlatformException catch (e) {
//       availableBiometrics = <BiometricType>[];
//       print(e);
//     }
//     if (!mounted) {
//       return;
//     }}
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;


//   final FaceIdController faceIdController = Get.put(FaceIdController());

//     // Démarrer le timer de verrouillage au démarrage de l'application
//     faceIdController.startLockTimer();

//     return Material(
//       child: Column(
//         children: [
//           ContainerWidget(
//             height: screenHeight * 0.08,
//             width: screenWidth,
//             color: AppColorModel.BlueColor,
//           ),
//           ContainerWidget(
//             height: screenHeight * 0.1,
//             width: screenWidth,
//             color: AppColorModel.WhiteColor,
//             child: Row(
//               children: [
//                 Image.asset(
//                   "asset/favicon.png",
//                   height: screenHeight * 0.08,
//                   width: screenHeight * 0.08,
//                 ),
//                 Text(
//                   "Votre empreinte digital",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: AppColorModel.BlueColor,
//                     fontSize: screenWidth * 0.05,
//                   ),
//                 ),
//                 Spacer(),
//                 IconButtonWidget(
//                   onPressed: () {},
//                   icon: Icon(
//                     Icons.notifications_sharp,
//                     color: AppColorModel.BlueColor,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Gap(50),
//            Obx(() {
//               if (faceIdController.isLocked.value) {
//                 return ElevatedButton(
//                   onPressed: () {
//                     faceIdController.authenticate(); // Authentification pour déverrouiller
//                   },
//                   child: Text('Actuver la sécurité avec le Face ID ou Touch ID', style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold),),
//                 );
//               } else {
//                 return Text(
//                   'Application déverrouillée',
//                   style: TextStyle(fontSize: 24),
//                 );
//               }
//             }),
//           ElevatedButton(
//               onPressed: () {
//                 // Réinitialiser le timer à chaque interaction utilisateur
//                 faceIdController.resetLockTimer();
//                 Get.snackbar(
//                   'Interaction',
//                   'Timer réinitialisé',
//                   snackPosition: SnackPosition.BOTTOM,
//                 );
//               },
//               child: Text('Interagir avec l\'application'),
//             ),
//           ElevatedButton(
//               onPressed: () async {
//                 await faceIdController.authenticate();
//               },
//               child: Text('Authentifier avec Face ID ou Touch ID'),
//             ),
//         ],
//       ),
//     );
//   }
// }