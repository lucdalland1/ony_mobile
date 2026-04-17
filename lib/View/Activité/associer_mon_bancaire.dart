import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/Widget/notificationWidget.dart';

import '../../Controller/select_country_rib.dart';
import '../Notification/notification.dart';

class AssocierCompteBancaireScreen extends StatelessWidget {
  AssocierCompteBancaireScreen({super.key});


    final CountryRIBController countryController = Get.put(CountryRIBController());
void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
            itemCount: countryController.countries.length,
            itemBuilder: (context, index) {
              final country = countryController.countries[index];
              return ListTile(
                leading: CountryFlag.fromCountryCode(
                  country['code']!,
                  height: 03.h,
                  width: 10.w,
                ),
                title: Text(country['name']!),
                onTap: () {
                  countryController.setCountry(
                    country['name']!,
                    country['code']!,
                  );
                  Navigator.pop(context);
                },
                selected: countryController.selectedCountry.value == country['name'],
              );
            },
          );
        
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        backgroundColor: AppColorModel.Bluecolor242,
        title: Text("Associer mon compte bancaire", style: TextStyle(fontSize: 15.dp, fontWeight: FontWeight.bold, color: AppColorModel.WhiteColor),),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
        actions: [
    NotificationWidget(),
  ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            children: [
                 Text("Remplissez le formulaire ci-dessous 👇", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.dp),),
              const SizedBox(height: 30),
                  
              const SizedBox(height: 5),
              TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Pays',
        suffixIcon: Icon(Icons.arrow_drop_down),
        prefixIcon: Obx(() {
  if (countryController.selectedCountryCode.value.isEmpty) {
    return const SizedBox(width: 10);
  }
  return Padding(
    padding: const EdgeInsets.only(left: 10, right: 5),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CountryFlag.fromCountryCode(
          countryController.selectedCountryCode.value,
          height: 16,  
          width: 24,  
        ),
        const SizedBox(width: 20),
        
      ],
    ),
  );
}),
      ),

      onTap: () => _showCountryPicker(context),
    ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Nom de la Banque',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType: TextInputType.name,
              ),
              Gap(10.dp),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Ville de la Banque',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType: TextInputType.name,
              ),
              Gap(10.dp),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Numéro de compte',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType: TextInputType.number,
              ),
              Gap(10.dp),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Code Banque',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType: TextInputType.number,
              ),
              Gap(10.dp),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Code Guichet',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType: TextInputType.number,
              ),
              Gap(10.dp),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Clé Guichet',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType: TextInputType.number,
              ),
          
            Gap(100.dp),      
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Action à ajouter
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorModel.Bluecolor242,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'CONTINUER',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
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
