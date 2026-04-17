// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../Controller/empreintecontroller.dart';

// class Empreinte extends StatelessWidget {
//   final EmpreinteController controller = Get.find();

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => controller.isLocked.value ? _buildLockScreen() : _buildHomeScreen());
//   }

//   Widget _buildLockScreen() {
//     return Scaffold(
//       backgroundColor: Colors.grey[900],
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.lock_outline, size: 80, color: Colors.white),
//             const SizedBox(height: 20),
//             const Text(
//               'Application Verrouillée',
//               style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 30),
//             Obx(() {
//               if (controller.showPinPad.value) {
//                 return _buildPinPad();
//               } else {
//                 return _buildUnlockOptions();
//               }
//             }),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildUnlockOptions() {
//     return Column(
//       children: [
//         if (controller.authMethod.value == AuthMethod.biometric)
//           ElevatedButton.icon(
//             icon: const Icon(Icons.fingerprint, size: 30),
//             label: const Text('Déverrouiller avec empreinte'),
//             onPressed: controller.onUnlockPressed,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue[700],
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             ),
//           ),
//         const SizedBox(height: 15),
//         TextButton(
//           onPressed: () {
//             controller.authMethod.value = AuthMethod.pin;
//             controller.showPinInput();
//           },
//           child: const Text(
//             'Utiliser le code PIN',
//             style: TextStyle(color: Colors.white, fontSize: 16),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPinPad() {
//     return Container(
//       width: 300,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.grey[800],
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Column(
//         children: [
//           Obx(() => Text(
//             controller.pinError.value.isEmpty 
//                 ? 'Entrez votre code PIN' 
//                 : controller.pinError.value,
//             style: TextStyle(
//               color: controller.pinError.value.isEmpty ? Colors.white : Colors.red,
//               fontSize: 18,
//             ),
//             textAlign: TextAlign.center,
//           )),
//           const SizedBox(height: 20),
//           Obx(() => Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(4, (index) => Container(
//               margin: const EdgeInsets.symmetric(horizontal: 10),
//               width: 20,
//               height: 20,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: index < controller.tempPin.value.length 
//                     ? Colors.blue 
//                     : Colors.grey,
//               ),
//             )),
//           )),
//           const SizedBox(height: 30),
//           GridView.count(
//             shrinkWrap: true,
//             crossAxisCount: 3,
//             childAspectRatio: 1.5,
//             physics: const NeverScrollableScrollPhysics(),
//             children: List.generate(9, (index) => _buildNumberButton((index + 1).toString()))
//               ..insertAll(9, [
//                 const SizedBox(),
//                 _buildNumberButton('0'),
//                 IconButton(
//                   icon: const Icon(Icons.backspace, color: Colors.white),
//                   onPressed: controller.onPinDeleted,
//                 ),
//               ]),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNumberButton(String number) {
//     return TextButton(
//       onPressed: () => controller.onPinEntered(number),
//       child: Text(
//         number,
//         style: const TextStyle(fontSize: 24, color: Colors.white),
//       ),
//       style: TextButton.styleFrom(
//         backgroundColor: Colors.blue[600],
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }

//   Widget _buildHomeScreen() {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Accueil Sécurisé'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.lock),
//             onPressed: controller.lockApp,
//           ),
//         ],
//       ),
//       body: GestureDetector(
//         behavior: HitTestBehavior.translucent,
//         onTap: () => controller.resetInactivityTimer(),
//         onPanDown: (_) => controller.resetInactivityTimer(),
//         child: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.verified_user, size: 60, color: Colors.green),
//               SizedBox(height: 20),
//               Text('Application déverrouillée', style: TextStyle(fontSize: 24)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }