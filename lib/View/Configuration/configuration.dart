// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:get/get.dart';
// import 'package:onyfast/Api/user_inscription.dart';
// import 'package:onyfast/View/Configuration/codePin.dart';
// import 'package:onyfast/View/Configuration/empreinte.dart';
// import 'package:onyfast/View/Configuration/faceid.dart';
// import 'package:onyfast/View/Configuration/monProfile.dart';
// import 'package:onyfast/View/BottomView/activite.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/url_launcher_string.dart';
// import 'package:whatsapp_unilink/whatsapp_unilink.dart';

// import '../../../Color/app_color_model.dart';
// import '../../../Widget/container.dart';
// import '../../../Widget/icon.dart';
// import '../../../Controller/languescontroller.dart';
// import '../../Controller/datecontrollerProfil.dart';
// import '../../Controller/switchcontroller.dart';
// import '../../Langue/languescontroller.dart';

// class Configuration extends StatefulWidget {
//  Configuration({super.key});

//   final AuthController deconnexion = Get.find();

//   @override
//   _ConfigurationState createState() => _ConfigurationState();
// }
//  final Uri _siteweb = Uri.parse('https://onyfast.com/');
//    final Uri _email = Uri.parse('mailto:contact@onyfast.com');
//   final Uri _phone = Uri.parse('tel:+242 06 589 14 93');

final Uri _siteweb = Uri.parse('https://onyfast.com/');
final Uri _email = Uri.parse('mailto:contact@onyfast.com');
final Uri _phone = Uri.parse('tel:+242 06 589 14 93');

//   //Fonction pour les URLs
//   Future<void> _validerUrl() async {
//     if (await canLaunchUrl(_siteweb)) {
//       throw Exception('Could not launch $_siteweb');
//     }
//     //Fonction pour les Emails

//     Future<void> _ValiderEmail() async {
//       if (await canLaunchUrl(_email)) {
//         await launchUrl(_email);
//       } else {
//         throw 'Could not launch $_email';
//       }
//     }
//   }
//   //Fonction pour les Appels

//   Future<void> _makePhoneCall(String phoneNumber) async {
//     final url = Uri.parse('tel:$phoneNumber');
//     if (await canLaunchUrl(_phone)) {
//       await launchUrl(_phone);
//   } else {
//     print('Impossible de lancer l\'appel téléphonique.');
//   }}
//   //Fonction pour les whatsapp
//   launchWhatsAppString() async {
//   final link = WhatsAppUnilink(
//     phoneNumber: '+242-057757406',
//     text: "Salut ! Je me renseigne sur onyfast.",
//   );
//   await launchUrlString('$link'); 
// }

// class _ConfigurationState extends State<Configuration> {
//   final TextEditingController idCarteController = TextEditingController();
//   final TextEditingController chiffreCarteController = TextEditingController();
//   final TextEditingController montantController = TextEditingController();
//   final LanguageController languageController = Get.put(LanguageController());

//   void _showDialog(BuildContext context) {
//     final AppController appState = Get.put(AppController());
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Center(child: Text('Voici nos contacts')),
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
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pushNamed(context, "/associercompte");
//                   },
//                   child: TextButton(onPressed: () async {
//  if (!await launchUrl(_phone)) {
//                         throw Exception('Could not launch $_phone');
//                       }
//                     } , child:Text(
//                     "Appeler le service client ☎️",
//                     style: TextStyle(color: AppColorModel.black),
//                   ),
//                 )),
//                TextButton(
//   onPressed: () {
//     launchWhatsAppString();
//   },
//   child: Text(
//     "Écrire sur WhatsApp 📱",
//     style: TextStyle(color: AppColorModel.black),
//   ),
// ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pushNamed(context, "/parametre");
//                   },
//                   child: TextButton(onPressed:  () async {
//                        if (!await launchUrl(_email)) {
//                         throw Exception('Could not launch $_email');
//                       }
//                     }, child:Text("Laisser un message sur Email ✉️",
//                     style: TextStyle(color: AppColorModel.black),),
//                 )),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final AppController appState = Get.find<AppController>();
//     final DateController dateController = Get.put(DateController());

//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     final SwitchController switchController = Get.put(SwitchController());
//     final LanguageController languageController = Get.put(LanguageController());

//     return Scaffold(
//       backgroundColor: AppColorModel.GreyWhite,
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return SingleChildScrollView(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(minHeight: constraints.maxHeight),
//               child: Column(
//                 children: [
//                   ContainerWidget(
//                     height: screenHeight * 0.08,
//                     width: screenWidth,
//                     color: AppColorModel.BlueColor,
//                   ),
//                   ContainerWidget(
//                     height: screenHeight * 0.1,
//                     width: screenWidth,
//                     color: AppColorModel.WhiteColor,
//                     child: Row(
//                       children: [
//                         Image.asset(
//                           "asset/favicon.png",
//                           height: screenHeight * 0.08,
//                           width: screenHeight * 0.08,
//                         ),
//                         Text(
//                           'Paramètre de configuration'.tr,
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: AppColorModel.BlueColor,
//                             fontSize: screenWidth * 0.05,
//                           ),
//                         ),
//                         Spacer(),
//                         IconButtonWidget(
//                           onPressed: () {},
//                           icon: Icon(Icons.notifications_sharp, color: AppColorModel.BlueColor),
//                         ),
//                       ],
//                     ),
//                   ),
//                   _buildListTile(
//                     context: context,
//                     icon: Icons.person,
//                     title: 'Modifier mon Profil'.tr,
//                     onTap: () => Get.to(Monprofile()),
//                   ),
//                   _buildDivider(),
//                   _buildListTile(
//                     context: context,
//                     icon: Icons.lock,
//                     title: "Reinitialiser le code PIN".tr,
//                     onTap: () => Get.to(CodePin()),
//                   ),
//                   _buildDivider(),
//                   InkWell(
//                 onTap: (){
                  
//             Get.bottomSheet(
//               Container(
//                 color: Colors.white,
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text('change_language'.tr, style: TextStyle(fontSize: 20)),
//                     SizedBox(height: 20),
//                     ListTile(
//                       title: Text('language_english'.tr),
//                       onTap: () {
//                         languageController.changeLanguage('en');
//                         Get.back();
//                       },
//                     ),
//                     ListTile(
//                       title: Text('language_french'.tr),
//                       onTap: () {
//                         languageController.changeLanguage('fr');
//                         Get.back();
//                       },
//                     ),
//                     ListTile(
//                       title: Text('language_spanish'.tr),
//                       onTap: () {
//                         languageController.changeLanguage('es');
//                         Get.back();
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             );
//                 },
//                 child: ListTile(
//                   leading: IconButton(
//                     icon: Icon(Icons.language_outlined,
//                         color: AppColorModel.BlueColor),
//                     onPressed: () {
                                            
//             Get.bottomSheet(
//               Container(
//                 color: Colors.white,
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text('change_language'.tr, style: TextStyle(fontSize: 20)),
//                     SizedBox(height: 20),
//                     ListTile(
//                       title: Text('language_english'.tr),
//                       onTap: () {
//                         languageController.changeLanguage('en');
//                         Get.back();
//                       },
//                     ),
//                     ListTile(
//                       title: Text('language_french'.tr),
//                       onTap: () {
//                         languageController.changeLanguage('fr');
//                         Get.back();
//                       },
//                     ),
//                     ListTile(
//                       title: Text('language_spanish'.tr),
//                       onTap: () {
//                         languageController.changeLanguage('es');
//                         Get.back();
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             );
//                     },
//                   ),
//                   title: Text("Changer langue de l'application".tr,
//                       style: TextStyle(
//                           color: AppColorModel.BlueColor,
//                           fontWeight: FontWeight.bold)),
//                   trailing: IconButton(
//                     icon: Icon(Icons.arrow_forward_ios,
//                         color: AppColorModel.BlueColor),
//                     onPressed: () {
                                            
//             Get.bottomSheet(
//               Container(
//                 color: Colors.white,
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text('change_language'.tr, style: TextStyle(fontSize: 20)),
//                     SizedBox(height: 20),
//                     ListTile(
//                       title: Text('language_english'.tr),
//                       onTap: () {
//                         languageController.changeLanguage('en');
//                         Get.back();
//                       },
//                     ),
//                     ListTile(
//                       title: Text('language_french'.tr),
//                       onTap: () {
//                         languageController.changeLanguage('fr');
//                         Get.back();
//                       },
//                     ),
//                     ListTile(
//                       title: Text('language_spanish'.tr),
//                       onTap: () {
//                         languageController.changeLanguage('es');
//                         Get.back();
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             );
//                     },
//                   ),
//                 ),
//               ),
//                   _buildDivider(),
//                   InkWell(
//                 onTap: (){
//                   Get.to(Empreinte());
//                 },
//                 child: ListTile(
//                   leading: IconButton(
//                     icon: Icon(Icons.fingerprint,
//                         color: AppColorModel.BlueColor),
//                     onPressed: () {
//                                             Get.to(Empreinte());
//                     },
//                   ),
//                   title: Text("Protection de l'application".tr,
//                       style: TextStyle(
//                           color: AppColorModel.BlueColor,
//                           fontWeight: FontWeight.bold)),
//                   trailing: IconButton(
//                     icon: Icon(Icons.arrow_forward_ios,
//                         color: AppColorModel.BlueColor),
//                     onPressed: () {
//                        Get.to(Empreinte());
//                     },
//                   ),
//                 ),
//               ),
//                   _buildDivider(),
//                    InkWell(
//                 onTap: () => Get.to(FaceId()),
//                 child: ListTile(
//                   leading: IconButton(
//                     icon: Icon(Icons.face_retouching_natural_outlined,
//                         color: AppColorModel.BlueColor),
//                     onPressed: () {
//                       Get.to(FaceId());
//                     },
//                   ),
//                   title: Text("Protection avec Face Id".tr,
//                       style: TextStyle(
//                           color: AppColorModel.BlueColor,
//                           fontWeight: FontWeight.bold)),
//                   trailing: IconButton(
//                     icon: Icon(Icons.arrow_forward_ios,
//                         color: AppColorModel.BlueColor),
//                     onPressed: () {
//                       Get.to(FaceId());
//                     },
//                   ),
//                 ),
//               ),
//                   _buildDivider(),
//                   ListTile(
//                 leading: IconButton(
//                   icon: Icon(Icons.article_outlined,
//                       color: AppColorModel.BlueColor),
//                   onPressed: () {},
//                 ),
//                 title: Text("Condition d'utilisation".tr,
//                     style: TextStyle(
//                         color: AppColorModel.BlueColor,
//                         fontWeight: FontWeight.bold)),
//                 trailing: IconButton(
//                   icon: Icon(Icons.arrow_forward_ios,
//                       color: AppColorModel.BlueColor),
//                   onPressed: () {

//                   },
//                 ),
//               ),
//                   _buildDivider(),
//                   _buildContactTile(context),
//                   _buildDivider(),
//                   _buildListTile(
//                     context: context,
//                     icon: Icons.info_outline,
//                     title: "A propos".tr,
//                     onTap: (){},
//                   ),
//                   _buildDivider(),
//                   _buildListTile(
//                     context: context,
//                     icon: Icons.web_rounded,
//                     title: "Site web".tr,
//                     onTap: ()   async {
//                        if (!await launchUrl(_siteweb)) {
//                         throw Exception('Could not launch $_siteweb');
//                       }
//                     },
//                   ),
//                   _buildDivider(),//modifi
//                   Gap(10),
//                   InkWell(
//       onTap: () {
//         AuthController().logout(); 
//       },
//       child: ContainerWidget(
//         height: 40,
//         width: 200,
//         color: AppColorModel.Grey,
//         borderRadius: BorderRadius.circular(10),
//         child: TextButton.icon(
//           onPressed: () {
//             AuthController().logout(); 
//           },
//           label: Text("Deconnexion".tr, style: TextStyle(color: AppColorModel.blackColor, fontSize: 16)),
//           icon: Icon(Icons.logout_outlined, size: 24, color: AppColorModel.blackColor),
//         ),
//       ),
//     ),
//                   Gap(10),
//                   Text("Version 3.0".tr, style: TextStyle(color: AppColorModel.blackColor)),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildListTile({required BuildContext context, required IconData icon, required String title, required VoidCallback onTap}) {
//     return InkWell(
//       onTap: ()   {
//         Get.to(Monprofile());
//                     },
//       child: ListTile(
//         leading: IconButton(
//           icon: Icon(icon, color: AppColorModel.BlueColor),
//           onPressed: onTap,
//         ),
//         title: Text(title, style: TextStyle(color: AppColorModel.BlueColor, fontWeight: FontWeight.bold)),
//         trailing: IconButton(
//           icon: Icon(Icons.arrow_forward_ios, color: AppColorModel.BlueColor),
//           onPressed: ()   async {
//                        if (!await launchUrl(_siteweb)) {
//                         throw Exception('Could not launch $_siteweb');
//                       }
//                     }
//         ),
//       ),
//     );
//   }

//   Widget _buildDivider() {
//     return Divider(color: AppColorModel.BlueColor);
//   }

  
//   Widget _buildLanguageOption(LanguageController languageController, String languageKey, String languageCode) {
//     return ListTile(
//       title: Text(languageKey.tr),
//       onTap: () {
//         languageController.changeLanguage(languageCode);
//         Get.back();
//       },
//     );
//   }

//   Widget _buildContactTile(BuildContext context) {
//     return InkWell(
//       onTap: () => _showDialog(context),
//       child: ListTile(
//         leading: IconButton(
//           icon: Icon(Icons.phone_android_outlined, color: AppColorModel.BlueColor),
//           onPressed: () => _showDialog(context),
//         ),
//         title: Text("Nous contacter".tr, style: TextStyle(color: AppColorModel.BlueColor, fontWeight: FontWeight.bold)),
//         trailing: IconButton(
//           icon: Icon(Icons.arrow_forward_ios, color: AppColorModel.BlueColor),
//           onPressed: () => _showDialog(context),
//         ),
//       ),
//     );
//   }
// }
