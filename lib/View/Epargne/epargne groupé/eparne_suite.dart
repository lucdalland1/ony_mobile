import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/Controller/savingcontroller.dart';

class CreerGroupePage extends StatefulWidget {
  @override
  _CreerGroupePageState createState() => _CreerGroupePageState();
}

  final VerrouillageController controller=Get.put(VerrouillageController());

class _CreerGroupePageState extends State<CreerGroupePage> {
  String typeGroupe = 'Épargne commune';
  String frequenceDepot = 'Mensuelle';
  String verrouillage = 'Aucune';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController membresController = TextEditingController();
  final TextEditingController montantController = TextEditingController();

  @override
  Widget build(BuildContext context) {       
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0A2149),
        title: Text('Épargne', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding( 
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text('Créer un groupe', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 10.dp),
                TextFormField(
                  controller: nomController,
                  decoration: InputDecoration(labelText: 'Nom du groupe'),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: membresController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Nombre de membres'),
                ),
                SizedBox(height: 20),
                Text('Type de groupe', style: TextStyle(fontWeight: FontWeight.bold)),
                RadioListTile(
                  value: 'Épargne commune',
                  groupValue: typeGroupe,
                  title: Text('Épargne commune'),
                  onChanged: (val) => setState(() => typeGroupe = val.toString()),
                ),
                RadioListTile(
                  value: 'Tontine rotative',
                  groupValue: typeGroupe,
                  title: Text('Tontine rotative'),
                  onChanged: (val) => setState(() => typeGroupe = val.toString()),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField(
                  value: frequenceDepot,
                  items: ['Hebdomadaire', 'Mensuelle', 'Trimestrielle']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  decoration: InputDecoration(labelText: 'Fréquence des dépôts'),
                  onChanged: (val) => setState(() => frequenceDepot = val.toString()),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: montantController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Montant'),
                ),
                SizedBox(height: 10.dp),
  Obx(() => DropdownButtonFormField(
                value: controller.verrouillage.value,
                items: ["Aucune", "Jusqu'à une date", "Jusqu'à un objectif atteint"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                decoration: InputDecoration(labelText: 'Verrouillage'),
                onChanged: (val) {
                  controller.verrouillage.value = val.toString();
                  controller.selectedDate.value = null; // Reset date
                  controller.amount.value = ''; // Reset amount
                },
              )),
              Obx(() => controller.verrouillage.value == "Jusqu'à une date"
                  ? TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Sélectionnez une date',
                        hintText: 'Appuyez pour choisir une date',
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: controller.selectedDate.value ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          controller.selectedDate.value = pickedDate;
                        }
                      },
                      controller: TextEditingController(
                        text: controller.selectedDate.value != null
                            ? "${controller.selectedDate.value!.toLocal()}".split(' ')[0]
                            : '',
                      ),
                    )
                  : SizedBox.shrink()),
              Obx(() => controller.verrouillage.value == "Jusqu'à un objectif atteint"
                  ? TextFormField(
                      decoration: InputDecoration(labelText: 'Insérez votre argent'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        controller.amount.value = val;
                      },
                    )
                  : SizedBox.shrink()),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor:AppColorModel.Bluecolor242,
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Continuer', style: TextStyle(fontWeight: FontWeight.bold, color: AppColorModel.WhiteColor, fontSize: 17.dp),),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
