import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/dropgenrecontroller.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import '../../../../../Color/app_color_model.dart';
import '../../../../../Controller/datecontrollerProfil.dart';
import '../../../../../Widget/container.dart';
import '../../../../../Widget/icon.dart';
import '../../../../Notification/notification.dart';

class CartePhysique extends StatefulWidget {
  const CartePhysique({super.key});

  @override
  State<CartePhysique> createState() => _CartePhysiqueState();
}
final Uri _phone = Uri.parse('tel:+242 06 589 14 93');
Future<void> _makePhoneCall(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(_phone)) {
      await launchUrl(_phone);
  } else {
    print('Impossible de lancer l\'appel téléphonique.');
  }}
  //Fonction pour les whatsapp
  launchWhatsAppString() async {
  final link = WhatsAppUnilink(
    phoneNumber: '+242-057757406',
    text: "Salut ! Je me renseigne sur onyfast.",
  );
  await launchUrlString('$link'); 
}
class _CartePhysiqueState extends State<CartePhysique> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

        final DateController dateController = Get.put(DateController()); // Initialiser le contrôleur

    final DropGenreController controller = Get.put( DropGenreController());

launchWhatsAppString() async {
  final link = WhatsAppUnilink(
    phoneNumber: '+242-057757406',
    text: "Salut ! Je me renseigne sur onyfast.",
  );
  await launchUrlString('$link'); 
}

    return Scaffold(
            appBar: AppBar(
        backgroundColor: AppColorModel.Bluecolor242,
        title: Text(
          "Gérer mes cartes Visa",
          style: TextStyle(
              fontSize: 17.dp,
              fontWeight: FontWeight.bold,
              color: AppColorModel.WhiteColor),
        ),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
        actions: [
        NotificationWidget(),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                  Text("Ajouter ma carte Onyfast", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  Gap(05),
                    Text("Remplissez le formulaire ci-dessous 👇"),
                    Gap(10),
                    TextFormField(decoration: InputDecoration(
                      labelText: "Nom(s)",
                      labelStyle: TextStyle(color: AppColorModel.Bluecolor242),
                    ),),
                     TextFormField(decoration: InputDecoration(
                      labelText: "Prénom(s)",
                      labelStyle: TextStyle(color: AppColorModel.Bluecolor242),
                    ),),
                     TextFormField(decoration: InputDecoration(
                      labelText: "identifiant de la carte face (arrière)",
                      labelStyle: TextStyle(color: AppColorModel.Bluecolor242),
                    ),
                    keyboardType: TextInputType.number,
                    ),
                    Text("Les 10 chiffres inscrits en bas sur la face arrière de la carte", style: TextStyle(fontSize: 10),),
                     TextFormField(decoration: InputDecoration(
                      labelText: "4 derniers chiffres de la carte face (arriere)",
                      labelStyle: TextStyle(color: AppColorModel.Bluecolor242),
                    ),
                    keyboardType: TextInputType.number,
                    ),
            Text("Les 4 derniers chiffres des 16 inscrits sur la face avant de la carte", style: TextStyle(fontSize: 10),),
            
                     TextFormField(decoration: InputDecoration(
                      labelText: "Expire en",
                      labelStyle: TextStyle(color: AppColorModel.Bluecolor242),
                    ),
                    keyboardType: TextInputType.number,
                    ),
                     Text("Sur la carte  c'est écrit VALID THRU", style: TextStyle(fontSize: 10),),
            //          TextFormField(
            //               controller: dateController.dateController,
            //               decoration: InputDecoration(
            // labelText: 'Date',
            // hintText: 'Sélectionnez une date',
            
            //           labelStyle: TextStyle(color: AppColorModel.BlueColor),
            // suffixIcon: IconButton(
            //   icon: Icon(Icons.calendar_today, color: AppColorModel.BlueColor),
            //   onPressed: () => dateController.selectDate(context),
            // ),
            //               ),
            //               readOnly: true, // Empêche la saisie manuelle
            //               validator: (value) {
            // return dateController.validateDate();
            //               },
            //             ),
                      TextFormField(decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: AppColorModel.Bluecolor242),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    ),
                    //                DropdownButtonFormField<String>(
                    //   decoration: InputDecoration(
                    //     labelText: "Genre",
                    //     labelStyle: TextStyle(color: Colors.blue), // Remplacez par AppColorModel.BlueColor
                    //   ),
                    //   items: controller.genres.map((String genre) {
                    //     return DropdownMenuItem<String>(
                    //       value: genre,
                    //       child: Text(genre),
                    //     );
                    //   }).toList(),
                    //   onChanged: (String? newValue) {
                    //     controller.updateGenre(newValue);
                    //   },
                    //   value: controller.selectedGenre.value.isNotEmpty ? controller.selectedGenre.value : null,
                    //   hint: Text('Sélectionnez un genre'),
                    // ),
                    
                    //  TextFormField(decoration: InputDecoration(
                    //   labelText: "Adresse",
                    //   labelStyle: TextStyle(color: AppColorModel.BlueColor),
                    // ),
                    // keyboardType: TextInputType.text,
                    
                    // ),
                    
                    //          TextFormField(decoration: InputDecoration(
                    //   labelText: "Genre",
                    //   labelStyle: TextStyle(color: AppColorModel.BlueColor),
                    // ),
                    // keyboardType: TextInputType.text,
                    // ),
        
                Gap(screenHeight * 0.02), // Ajuster l'espacement
                InkWell(
                  onTap: () {
                    // Soumettre l'action
                  },
                  child: ContainerWidget(
                    height: 06.h, // Ajuster la hauteur
                    width: screenWidth * 0.9, // Ajuster la largeur
                    borderRadius: BorderRadius.circular(10),
                    color: AppColorModel.Bluecolor242,
                    child: Center(
                      child: Text("Ajouter",
                        style: TextStyle(
                            color: AppColorModel.WhiteColor,
                            fontSize: 17.dp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Gap(145.dp),
              
            //       Text("Si vous avez des questions, vous pouvez-nous"),
            //       Text("contacter via les coordonnées suivants 👇"),
            //       Gap(09),
            //        InkWell(
            //       onTap: () async{
            //         if (!await launchUrl(_phone)) {
            //       throw Exception('Could not launch $_phone');
            //     }
            //       },
            //       child: ContainerWidget(
            //         height:  06.h, // Ajuster la hauteur
            //         width: screenWidth * 0.9, // Ajuster la largeur
            //         borderRadius: BorderRadius.circular(10),
            //         color: AppColorModel.Bluecolor242,
            //         child: Center(
            //           child: Text("📞 (+242) 06 589 14 93",
            //             style: TextStyle(
            //                 color: AppColorModel.WhiteColor,
            //                 fontSize: 17.dp,
            //                 fontWeight: FontWeight.bold),
            //           ),
            //         ),
            //       ),
            //     ),
            //     Gap(08.dp),
            //       InkWell(
            //       onTap: () {
        
            // launchWhatsAppString();
            //       },
            //       child: ContainerWidget(
            //         height:  06.h, // Ajuster la hauteur
            //         width: screenWidth * 0.9, // Ajuster la largeur
            //         borderRadius: BorderRadius.circular(10),
            //         color: AppColorModel.Green,
            //         child: Center(
            //           child: Text("💬 (+242) 05 775 74 06",
            //             style: TextStyle(
            //                 color: AppColorModel.WhiteColor,
            //                 fontSize: 17.dp,
            //                 fontWeight: FontWeight.bold),
            //           ),
            //         ),
            //       ),
            //     ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildTextField(TextEditingController controller, AppController appState, String labelFr, String labelEn, String labelEs) {
  //   return TextField(
  //     controller: controller,
  //     keyboardType: TextInputType.text,
  //     decoration: InputDecoration(
  //       labelText: appState.language == AppLanguage.french
  //           ? labelFr
  //           : appState.language == AppLanguage.english
  //               ? labelEn
  //               : labelEs,
  //     ),
  //   );
  // }
  }

