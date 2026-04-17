
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/Controller/CoffreController.dart';
import 'package:onyfast/View/Coffre/model/coffreModel.dart';
import 'package:onyfast/Widget/container.dart';


class Modifiercoffre extends StatefulWidget {
  final ObjectifModel objectif  ;
  
  const Modifiercoffre({super.key , required this.objectif});

  @override
  State<Modifiercoffre> createState() => _ModifiercoffreState();
}

class _ModifiercoffreState extends State<Modifiercoffre> {
   // ignore: prefer_typing_uninitialized_variables
   late final CoffreController controller ;
   var isLoading=false ;
   
@override
  void initState() {
    super.initState();
 controller = Get.find<CoffreController>(); 
 

  WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.clearForm();
      controller.objectifController.text=widget.objectif.nom;
      controller.montantController.text = widget.objectif.montantCible.toInt().toString();
      controller.isLoading1.value=false;
 
    });
} 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
       title: const Text("Modifier l'objectif"),
       leading: IconButton(
         icon: const Icon(Icons.arrow_back),
         onPressed: () => Navigator.pop(context),
       ),
     ),
     body: Obx(() {
      
        if(isLoading)return Center(child: CupertinoActivityIndicator(
          radius: 30,
        ));

  if (controller.coffre.value != null) {
         return body(); // ton widget
       }

  return Text("Erreur lors du chargement");     })

   );

  }

  body ()=>Padding(
       padding: const EdgeInsets.all(20.0),
       child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
        child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const Center(
             child: Column(
               children: [
                 Text(
                   "Mettez de l’argent de côté de manière\nsécurisée et automatique.",
                   textAlign: TextAlign.center,
                   style: TextStyle(fontSize: 16, color: Colors.grey),
                 ),
                 SizedBox(height: 20),
                 Icon(Icons.lock, size: 60, color: Colors.orange),
               ],
             ),
           ),
           const SizedBox(height: 30),
           const Text("Nom de l’objectif", style: TextStyle(fontWeight: FontWeight.bold)),
           const SizedBox(height: 8),
           TextField(
            controller: controller.objectifController,
             decoration: InputDecoration(
              hintStyle: TextStyle(
      color: Colors.grey.withOpacity(0.5), // plus clair / flou
    ),
               hintText: "Frais école",
               border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
             ),
           ),
           const SizedBox(height: 20),
           const Text("Montant à atteindre", style: TextStyle(fontWeight: FontWeight.bold)),
           const SizedBox(height: 8),
           TextField(
            controller: controller.montantController,
             keyboardType: TextInputType.number,
             decoration: InputDecoration(
              hintStyle: TextStyle(
      color: Colors.grey.withOpacity(0.5), // plus clair / flou
    ),
               hintText: "75 000 FCFA",
               border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
             ),
           ),
           const SizedBox(height: 20),
           const Text("Délai", style: TextStyle(fontWeight: FontWeight.bold)),
           const SizedBox(height: 8),
          InkWell(
                onTap: () {
                 controller.showMyCupertinoModalPopup();
                },
                child: ContainerWidget(
                  height: 50,
                  width:MediaQuery.of(context).size.height * 0.78,
                  color: Colors.transparent,
                  border: Border.all(color: AppColorModel.black,),
                  borderRadius: BorderRadius.circular(10),
                 child: Center(
                    child: Obx(() => Text(
                      controller.selectedDateAjouter,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    )),
                  ),
                ),
              ),
           const SizedBox(height: 30),
          InkWell(
                onTap: () {
                //  controller.ajouterCoffre();
                  setState(() {
                    isLoading=true;
                  });
                 controller.modifierCoffre(widget.objectif.id);
 setState(() {
                    isLoading=false;
                  });

                  
                },
                child: ContainerWidget(
                  height: 50,
                  width:MediaQuery.of(context).size.height * 0.78,
                  color: AppColorModel.BlueColor,
                  borderRadius: BorderRadius.circular(10),
                  child: Center(
                    child: Text(
                      "Modifier",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: AppColorModel.WhiteColor,
                      ),
                    ),
                  ),
                ),
              ),
         ],
       ),
       )
       )
     );
}
