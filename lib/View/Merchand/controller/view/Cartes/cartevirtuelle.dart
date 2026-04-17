import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/View/Merchand/controller/view/Cartes/cartevirtuelle2.dart';
import 'package:onyfast/Widget/notificationWidget.dart';

import '../../../../../Color/app_color_model.dart';
import '../../../../../Controller/datecontrollerProfil.dart';
import '../../../../../Controller/dropgenrecontroller.dart';
import '../../../../../Widget/container.dart';
import '../../../../../Widget/icon.dart';
import '../../../../../Controller/formcontroller.dart';
import '../../../../Notification/notification.dart'; // Importer le contrôleur

class CarteVirtuelle extends StatefulWidget {
  const CarteVirtuelle({super.key});

  @override
  State<CarteVirtuelle> createState() => _CarteVirtuelleState();
}

class _CarteVirtuelleState extends State<CarteVirtuelle> {
  final _formKey = GlobalKey<FormState>();
  final DateController dateController = Get.put(DateController());
  final DropGenreController genreController = Get.put(DropGenreController());
  final FormController formController =
      Get.put(FormController()); // Initialiser le contrôleur

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Emettre une carte Onyfast",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Gap(5),
                  Text(
                      "Ne manquez pas votre chance de transformer"),
                      Text("vos paiements quotidiens en expérience fluides"),
                      Text("et sans accroc. Emettre votre carte virtuelle en"),
                       Text("un clic."),
                       Gap(03),
                      Text("Remplissez le formulaire ci-dessous 👇"),
                  Gap(10),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Ville",
                      labelStyle:
                          TextStyle(color: AppColorModel.BlueColor),
                    ),
                    onChanged: (value) =>
                        formController.city.value = value,
                    validator: (value) => value!.isEmpty
                        ? 'Veuillez entrer une ville'
                        : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Nom(s)",
                      labelStyle:
                          TextStyle(color:AppColorModel.Bluecolor242,),
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
                          TextStyle(color: AppColorModel.Bluecolor242,),
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
                          TextStyle(color: AppColorModel.Bluecolor242,),
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
                          TextStyle(color: AppColorModel.Bluecolor242,),
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
                          TextStyle(color: AppColorModel.Bluecolor242,),
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
                          TextStyle(color: AppColorModel.Bluecolor242,),
                    ),
                    onChanged: (value) =>
                        formController.address.value = value,
                    validator: (value) => value!.isEmpty
                        ? 'Veuillez entrer une adresse'
                        : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Autre Téléphone",
                      labelStyle:
                          TextStyle(color: AppColorModel.Bluecolor242,),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        formController.phone.value = value,
                    validator: (value) => value!.isEmpty
                        ? 'Veuillez entrer un numéro de téléphone'
                        : null,
                  ),
                  Gap(screenHeight * 0.03),
                 
                    // bool isFormValid = formController.validate();
                    InkWell(
                      onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>CarteVirtuelle2()));
                      },
                      child: ContainerWidget(
                        height: 06.h,
                        width: 120.w,
                        color: AppColorModel.Bluecolor242,
                        borderRadius: BorderRadius.circular(10.dp),
                        child: Center(
                          child: Text("Valider", style: TextStyle(fontSize: 17.dp, color: AppColorModel.WhiteColor, fontWeight: FontWeight.bold),),
                        ),
                      ),
                    ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
