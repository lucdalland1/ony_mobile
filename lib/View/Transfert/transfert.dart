import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/Controller/transfertcountry.dart';
import 'package:onyfast/View/Transfert/transfert2.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Widget/notificationWidget.dart';

import '../../Widget/container.dart';
import '../Notification/notification.dart';

class Transfert extends StatefulWidget {
  const Transfert({super.key});

  @override
  State<Transfert> createState() => _TransfertState();
}

class _TransfertState extends State<Transfert> {
  var select ="";
  @override
  Widget build(BuildContext context) {
    final TransfertCountryController controller = Get.put(TransfertCountryController());
    
    
    return Scaffold(
      backgroundColor: AppColorModel.GreyWhite,
       appBar: AppBar(
        backgroundColor:globalColor,
        title: Text("Transfert", style: TextStyle(fontSize: 17.dp, fontWeight: FontWeight.bold, color: AppColorModel.WhiteColor),),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
        actions: [
        NotificationWidget(),
  ],
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 10.dp, top: 10.dp, right: 10.dp, bottom: 1.dp),
        child: Container(
          height: 85.h,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColorModel.Bluecolor242, width: 1.dp),
            borderRadius: BorderRadius.circular(5.dp),
            color: AppColorModel.WhiteColor,
          ),
          child: Padding(
            padding: EdgeInsets.all(10.dp),
            child: Column(
              children: [
                Gap(10.dp),
                Row(
                  children: [
                    Gap(10.dp),
                    Text(
                      "Transfert d’argent",
                      style: TextStyle(fontSize: 25.dp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Gap(10.dp),
                Row(
                  children: [
                    Gap(10),
                    Text(
                      "Étape 1",
                      style: TextStyle(fontSize: 17.dp, color: AppColorModel.Grey),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Gap(5.dp),
                    Text(
                      "Sélectionner le pays",
                      style: TextStyle(fontSize: 12.dp, color: AppColorModel.black),
                    ),
                  ],
                ),
                Gap(20.dp),
                Expanded(
                  child: Obx(() => DropdownButtonFormField<Country>(
                    decoration: InputDecoration(
                      labelText: 'Pays',
                      border: OutlineInputBorder(),
                    ),
                    value: controller.selectedCountry.value,
                    onChanged: (Country? newValue) {
                      if (newValue != null && newValue.idContries != null) {
                        print("voila la nouvelle valeur  ${newValue.idContries}");
                        print('voila son indicatif ${newValue.indicatif}');
                        select=newValue.indicatif;
                        controller.selectCountry(newValue);
                      }
                    },
                    items: controller.countries.map<DropdownMenuItem<Country>>((Country country) {
                      return DropdownMenuItem<Country>(
                        value: country,
                        child: Text(
                          '${country.flag} ${country.name}',
                          style: TextStyle(fontSize: 16.dp),
                        ),
                      );
                    }).toList(),
                  )),
                ),
               SizedBox(height: 20.h),
                Obx(() {
                  bool isButtonEnabled = controller.selectedCountry.value != null;
                  return InkWell(
                    onTap: isButtonEnabled ? () {


                      Get.to(Transfert2(), arguments: {"indicatif": select});
                      // Action à effectuer lorsque le bouton est cliqué
                       // const SizedBox(height: 20),
            // Obx(() => controller.selectedCountry.value != null
            //     ? Text(
            //         'Pays sélectionné: ${controller.selectedCountry.value!.flag} '
            //         '${controller.selectedCountry.value!.name}',
            //         style: TextStyle(fontSize: 18),
            //       )
            //     : Container()),
                    } : null,
                    child: Container(
                      height: 06.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.dp),
                        color: isButtonEnabled ? globalColor : Colors.grey, // Couleur grise si désactivé
                      ),
                      child: Center(
                        child: Text(
                          "Suivant",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,fontSize: 19.dp,
                            color: AppColorModel.WhiteColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}