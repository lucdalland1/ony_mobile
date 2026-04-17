import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/View/Transfert/recuBank.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/Widget/notificationWidget.dart';

import '../../Color/app_color_model.dart';
import '../../Controller/bankcontroller.dart';
import '../../Controller/formulaircontroller.dart';
import '../../Controller/transfert/FraisFixeController.dart';
import '../Notification/notification.dart';

class Transfert4 extends StatefulWidget {
  const Transfert4({super.key});

  @override
  State<Transfert4> createState() => _Transfert4State();
}

class _Transfert4State extends State<Transfert4> {
  final FraisFixeController fraisFixeController = Get.put(FraisFixeController());
  final BankController bankController = Get.find();
  final FormController controller = Get.put(FormController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: AppColorModel.Bluecolor242,
        title: Text(
          "Transfert Local", 
          style: TextStyle(
            fontSize: 17.dp, 
            fontWeight: FontWeight.bold, 
            color: AppColorModel.WhiteColor
          ),
        ),
        centerTitle: true,
        actions: [
         NotificationWidget(),
        ],
      ),
      backgroundColor: AppColorModel.GreyWhite,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(16.dp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(10.dp),
                
                // Section Bénéficiaire
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.dp),
                  decoration: BoxDecoration(
                    color: AppColorModel.WhiteColor,
                    borderRadius: BorderRadius.circular(12.dp),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      // Avatar/Logo de la banque
                      Container(
                        height: 50.dp,
                        width: 50.dp,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.dp),
                          color: Colors.grey.shade200,
                        ),
                        child: Obx(() => bankController.selectedImagePath.isNotEmpty
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25.dp),
                                image: DecorationImage(
                                  image: AssetImage(bankController.selectedImagePath.value),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          : Icon(Icons.account_balance, color: Colors.grey)),
                      ),
                      Gap(12.dp),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() => Text(
                              bankController.selectedBankName.value.isNotEmpty 
                                ? bankController.selectedBankName.value 
                                : "BENEFICIAIRE",
                              style: TextStyle(
                                fontSize: 16.dp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            )),
                            Gap(4.dp),
                            Text(
                              "Compte Onyfast trouvé",
                              style: TextStyle(
                                fontSize: 12.dp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              "+24706587034",
                              style: TextStyle(
                                fontSize: 12.dp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              "masurand@gmail.com",
                              style: TextStyle(
                                fontSize: 12.dp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                Gap(20.dp),
                
                // Section Montant
                Text(
                  "MONTANT",
                  style: TextStyle(
                    fontSize: 12.dp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Gap(8.dp),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "400",
                          hintStyle: TextStyle(
                            fontSize: 36.dp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 36.dp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        keyboardType: TextInputType.number,
                        onSaved: (value) => controller.amount.value = value!,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un montant';
                          }
                          return null;
                        },
                      ),
                    ),
                    Text(
                      "XAF",
                      style: TextStyle(
                        fontSize: 24.dp,
                        fontWeight: FontWeight.bold,
                        color: AppColorModel.Bluecolor242,
                      ),
                    ),
                  ],
                ),
                
                // Ligne de séparation
                Container(
                  height: 2.dp,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.blue],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(1.dp),
                  ),
                ),
                
                Gap(20.dp),
                
                // Section Frais calculés
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.dp),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12.dp),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calculate, color: Colors.green, size: 16.dp),
                          Gap(8.dp),
                          Text(
                            "Frais calculés",
                            style: TextStyle(
                              fontSize: 14.dp,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      Gap(12.dp),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Montant:",
                            style: TextStyle(
                              fontSize: 14.dp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            "400 XAF",
                            style: TextStyle(
                              fontSize: 14.dp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Gap(8.dp),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Frais:",
                            style: TextStyle(
                              fontSize: 14.dp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            "-4 XAF",
                            style: TextStyle(
                              fontSize: 14.dp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      
                      Divider(color: Colors.green.shade300),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Montant à envoyer:",
                            style: TextStyle(
                              fontSize: 16.dp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Text(
                            "404 XAF",
                            style: TextStyle(
                              fontSize: 16.dp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Gap(12.dp),
                
                Center(
                  child: Text(
                    "% frais: 1%",
                    style: TextStyle(
                      fontSize: 12.dp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                
                Gap(40.dp),
                
                // Bouton Continuer
                InkWell(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Get.to(RecuBank());
                    } else {
                       SnackBarService.warning(
                        'Veuillez remplir tous les champs',
                        
                       
                      );
                    }
                  },
                  child: Container(
                    height: 50.dp,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.dp),
                      color: AppColorModel.Bluecolor242,
                    ),
                    child: Center(
                      child: Text(
                        "Continuer",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColorModel.WhiteColor,
                          fontSize: 16.dp,
                        ),
                      ),
                    ),
                  ),
                ),
                
                Gap(20.dp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}