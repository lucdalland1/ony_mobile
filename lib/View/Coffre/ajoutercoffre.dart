import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/Controller/CoffreController.dart';
import 'package:onyfast/Widget/container.dart';

class AjouterCoffreScreen extends StatefulWidget {
  const AjouterCoffreScreen({super.key});

  @override
  State<AjouterCoffreScreen> createState() => _AjouterCoffreScreenState();
}

class _AjouterCoffreScreenState extends State<AjouterCoffreScreen> {
  // ignore: prefer_typing_uninitialized_variables
  late final CoffreController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CoffreController>();
    controller.clearForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Ajouter au coffre",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon:
                Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading1.value) {
            return Center(child: CupertinoActivityIndicator());
          }

          if (controller.coffre.value != null) {
            return SafeArea(
                top: true, bottom: true, child: body()); // ton widget
          }

          return Text("Erreur lors du chargement");
        }));
  }

  Padding body() => Padding(
      padding: const EdgeInsets.all(20.0),
      child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Center(
                  child: Column(
                    children: [
                      Text(
                        "Mettez de l’argent de côté de manière\nsécurisée et automatique.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                      SizedBox(height: 20),
                      Icon(Icons.lock, size: 60, color: Colors.orange),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                 Text("Nom de l’objectif",
                    style: TextStyle(fontWeight: FontWeight.bold,
                    fontSize: 10.sp)),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.objectifController,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.withOpacity(0.5), // plus clair / flou
                    ),
                    hintText: "Frais école",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                 Text("Montant à atteindre",
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 10.sp)),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.montantController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.withOpacity(0.5), // plus clair / flou
                    ),
                    hintText: "75 000 FCFA",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                 Text("Délai",
                    style: TextStyle(fontSize: 10.sp,fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    controller.showMyCupertinoModalPopup();
                  },
                  child: ContainerWidget(
                    height: 50,
                    width: MediaQuery.of(context).size.height * 0.78,
                    color: Colors.transparent,
                    border: Border.all(
                      color: AppColorModel.black,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    child: Center(
                      child: Obx(() => Text(
                            controller.selectedDateAjouter,
                            style: TextStyle(
                              fontSize:
                                  11.sp,
                            ),
                          )),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                InkWell(
                  onTap: () {
                    controller.ajouterCoffre();
                  },
                  child: ContainerWidget(
                    height: 50,
                    width: MediaQuery.of(context).size.height * 0.78,
                    color: AppColorModel.BlueColor,
                    borderRadius: BorderRadius.circular(10),
                    child: Center(
                      child: Text(
                        "Ajouter",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColorModel.WhiteColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )));
}
