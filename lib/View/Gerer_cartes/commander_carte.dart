import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/formcontroller.dart';
import 'package:onyfast/View/Gerer_cartes/commander_carte2.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import '../../Color/app_color_model.dart';
import '../../Controller/datecontrollerProfil.dart';
import '../../Controller/dropgenrecontroller.dart';
import '../../Controller/identitecartecontroller.dart';
import '../../Widget/container.dart';
import '../Notification/notification.dart';

class CommanderCarte extends StatefulWidget {
  const CommanderCarte({super.key});

  @override
  State<CommanderCarte> createState() => _CommanderCarteState();
}

class _CommanderCarteState extends State<CommanderCarte> {
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
  @override
  Widget build(BuildContext context) {
       final _formKey = GlobalKey<FormState>();
  final DateController dateController = Get.put(DateController());
  final DropGenreController genreController = Get.put(DropGenreController());
  final FormController formController =
      Get.put(FormController()); // Initialiser le contrôleur


  final IdentityFormController controller = Get.put(IdentityFormController());
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
          NotificationWidget()
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Commander une carte Onyfast",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Gap(5),
                  Gap(5),
                  Text(
                      "Ne manquez pas votre chance de transformer"),
                      Text("vos paiements quotidiens en expérience fluides"),
                      Text("et sans accroc. Commandez votre carte dès"),
                       Text("aujourd'hui et faites-vous livrer en 2 heures."),
                       Gap(03),
                      Text("Remplissez le formulaire ci-dessous 👇"),
                  Gap(10),
                   
                      const SizedBox(height: 8),
                       TextFormField(
                    decoration: InputDecoration(
                      labelText: "Téléphone",
                      labelStyle:
                          TextStyle(color: AppColorModel.Bluecolor242),
                    ),
                    onChanged: (value) =>
                        formController.firstName.value = value,
                    validator: (value) => value!.isEmpty
                        ? 'Veuillez entrer un numéro'
                        : null,
                  ),
             TextFormField(decoration: InputDecoration(
                      labelText: "identifiant de la carte de votre parrain(face arrière)",
                      labelStyle: TextStyle(color: AppColorModel.Bluecolor242),
                    ),
                    keyboardType: TextInputType.number,
                    ),
                    Text("Les 10 chiffres inscrits en bas sur la face arrière de la carte", style: TextStyle(fontSize: 10),),
                      // Sélection du type de pièce d'identité
                                      TextFormField(
                    decoration: InputDecoration(
                      labelText: "Nom(s)",
                      labelStyle:
                          TextStyle(color: AppColorModel.Bluecolor242),
                    ),
                    onChanged: (value) =>
                        formController.name.value = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Veuillez entrer un nom' : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Prénom(s)",
                      labelStyle:
                          TextStyle(color: AppColorModel.Bluecolor242),
                    ),
                    onChanged: (value) =>
                        formController.firstName.value = value,
                    validator: (value) => value!.isEmpty
                        ? 'Veuillez entrer un prénom'
                        : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle:
                          TextStyle(color:AppColorModel.Bluecolor242),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) =>
                        formController.email.value = value,
                    validator: (value) => value!.isEmpty
                        ? 'Veuillez entrer un email'
                        : null,
                  ),
                                    TextFormField(
                    controller: dateController.dateController,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      hintText: 'Date de naissance',
                      labelStyle:
                          TextStyle(color: AppColorModel.Bluecolor242),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today,
                            color: AppColorModel.Bluecolor242),
                        onPressed: () =>
                            dateController.selectDate(context),
                      ),
                    ),
                    readOnly: true,
                    validator: (value) =>
                        dateController.validateDate() == null
                            ? null
                            : 'Veuillez choisir une date',
                  ),
                   DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Genre",
                      labelStyle:
                          TextStyle(color:AppColorModel.Bluecolor242),
                    ),
                    items: genreController.genres.map((String genre) {
                      return DropdownMenuItem<String>(
                        value: genre,
                        child: Text(genre),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      genreController.updateGenre(newValue);
                      formController.selectedGenre.value = newValue ?? '';
                    },
                    value: genreController.selectedGenre.value.isNotEmpty
                        ? genreController.selectedGenre.value
                        : null,
                    hint: Text('Sélectionnez un genre'),
                    validator: (value) => value == null
                        ? 'Veuillez sélectionner un genre'
                        : null,
                  ),

                 
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Adresse",
                      labelStyle:
                          TextStyle(color: AppColorModel.Bluecolor242),
                    ),
                    onChanged: (value) =>
                        formController.address.value = value,
                    validator: (value) => value!.isEmpty
                        ? 'Veuillez entrer une adresse'
                        : null,
                  ),
                   TextFormField(
                    decoration: InputDecoration(
                      labelText: "Ville",
                      labelStyle:
                          TextStyle(color: AppColorModel.Bluecolor242),
                    ),
                    keyboardType: TextInputType.name,
                    onChanged: (value) =>
                        formController.phone.value = value,
                    validator: (value) => value!.isEmpty
                        ? 'Veuillez entrer une ville'
                        : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Autre Téléphone",
                      labelStyle:
                          TextStyle(color: AppColorModel.Bluecolor242),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        formController.phone.value = value,
                    validator: (value) => value!.isEmpty
                        ? 'Veuillez entrer un numéro de téléphone'
                        : null,
                  ),
                          
                          Gap(145.dp), // Ajuster l'espacement
                InkWell(
                  onTap: () {
                    Get.to(CommanderCarte2());
                  },
                  child: ContainerWidget(
                    height: 05.50.h, // Ajuster la hauteur
                    width: 120.w, // Ajuster la largeur
                    borderRadius: BorderRadius.circular(10),
                    color: AppColorModel.Bluecolor242,
                    child: Center(
                      child: Text("Ajouter vos pièces",
                        style: TextStyle(
                            color: AppColorModel.WhiteColor,
                            fontSize: 17.dp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
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
            //         height: 05.50.h, // Ajuster la hauteur
            //         width: 120.w, // Ajuster la largeur
            //         borderRadius: BorderRadius.circular(10),
            //         color:AppColorModel.Bluecolor242,
            //         child: Center(
            //           child: Text("📞 (+242) 06 589 14 93",
            //             style: TextStyle(
            //                 color: AppColorModel.WhiteColor,
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.bold),
            //           ),
            //         ),
            //       ),
            //     ),
            //     Gap(10),
            //       InkWell(
            //       onTap: () {
        
            // launchWhatsAppString();
            //       },
            //       child: ContainerWidget(
            //        height: 05.50.h, // Ajuster la hauteur
            //         width: 120.w, // Ajuster la largeur
            //         borderRadius: BorderRadius.circular(10),
            //         color: AppColorModel.Green,
            //         child: Center(
            //           child: Text("💬 (+242) 05 775 74 06",
            //             style: TextStyle(
            //                 color: AppColorModel.WhiteColor,
            //                 fontSize: 16,
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
      ),
    );
  }
}