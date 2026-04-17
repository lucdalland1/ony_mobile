import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/Controller/EpargneIndividuelController.dart';
import '../../../Controller/savingcontroller.dart';

class EpargneIndividuelleSuite extends StatefulWidget {
  const EpargneIndividuelleSuite({super.key});

  @override
  State<EpargneIndividuelleSuite> createState() => _EpargneIndividuelleSuiteState();
}

class _EpargneIndividuelleSuiteState extends State<EpargneIndividuelleSuite> {
  final VerrouillageController verrouillageController = Get.put(VerrouillageController());
  final EpargneIndividuelleController controller = Get.find<EpargneIndividuelleController>();

  String frequenceDepot = 'Mensuelle';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController montantController = TextEditingController();

  bool get isFormValid {
    return nomController.text.isNotEmpty &&
           endDateController.text.isNotEmpty &&
           montantController.text.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0A2149),
        leading: BackButton(color: Colors.white),
        title: Text('Épargne', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: body(),
      ),
    );
  }

  Widget body() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Créer une épargne individuelle", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            DropdownButtonFormField(
              value: frequenceDepot,
              items: ['Hebdomadaire', 'Mensuelle', 'Trimestrielle']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              decoration: InputDecoration(labelText: 'Fréquence des dépôts'),
              onChanged: (val) => setState(() => frequenceDepot = val.toString()),
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: montantController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Montant'),
            ),
            SizedBox(height: 16),

            Obx(() => DropdownButtonFormField(
              value: verrouillageController.verrouillage.value,
              items: ["Aucune", "Jusqu'à une date", "Jusqu'à un objectif atteint"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              decoration: InputDecoration(labelText: 'Verrouillage'),
              onChanged: (val) {
                verrouillageController.verrouillage.value = val.toString();
                verrouillageController.selectedDate.value = null;
                verrouillageController.amount.value = '';
              },
            )),
            Obx(() => verrouillageController.verrouillage.value == "Jusqu'à une date"
                ? TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Sélectionnez une date',
                      hintText: 'Appuyez pour choisir une date',
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: verrouillageController.selectedDate.value ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        verrouillageController.selectedDate.value = pickedDate;
                      }
                    },
                    controller: TextEditingController(
                      text: verrouillageController.selectedDate.value != null
                          ? "${verrouillageController.selectedDate.value!.toLocal()}".split(' ')[0]
                          : '',
                    ),
                  )
                : SizedBox.shrink()),
            Obx(() => verrouillageController.verrouillage.value == "Jusqu'à un objectif atteint"
                ? TextFormField(
                    decoration: InputDecoration(labelText: 'Insérez votre argent'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      verrouillageController.amount.value = val;
                    },
                  )
                : SizedBox.shrink()),

            SizedBox(height: 230.dp),

            Text("Créer un Objectif", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            Obx(() => TextFormField(
              controller: nomController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(labelText: 'nom'),
              enabled: !controller.isLoading.value,
            )),
            SizedBox(height: 16),

            Obx(() => TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Sélectionnez une date',
                hintText: 'Appuyez pour choisir une date',
              ),
              onTap: controller.isLoading.value ? null : () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (pickedDate != null) {
                  endDateController.text = pickedDate.toString();
                }
              },
              controller: TextEditingController(
                text: "${DateTime.now().toLocal()}".split(' ')[0],
              ),
              enabled: !controller.isLoading.value,
            )),
            SizedBox(height: 16),

            Obx(() => TextFormField(
              controller: montantController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'montant cible'),
              enabled: !controller.isLoading.value,
            )),
            SizedBox(height: 230.dp),

            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: isFormValid && !controller.isLoading.value
                    ? () {
                        var result = controller.createObjectif(
                          nom: nomController.text,
                          endDate: endDateController.text,
                          montantCible: montantController.text,
                        );
                        print('Nom: ${nomController.text}');
                        print('End Date: ${endDateController.text}');
                        print('Montant: ${montantController.text}');
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorModel.Bluecolor242,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isLoading.value
                    ? CupertinoActivityIndicator()
                    : Text(
                        "Continuer",
                        style: TextStyle(
                            fontSize: 18.dp,
                            fontWeight: FontWeight.bold,
                            color: AppColorModel.WhiteColor),
                      ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
