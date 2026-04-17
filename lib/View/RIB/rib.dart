import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/ribcontroller.dart';
import 'package:onyfast/Widget/container.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import '../../Color/app_color_model.dart';
import '../Notification/notification.dart';

class Rib extends StatefulWidget {
  const Rib({super.key});

  @override
  State<Rib> createState() => _RibState();
}

class _RibState extends State<Rib> {
  final  controller = Get.put(RibController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorModel.WhiteColor,
      appBar: AppBar(
        backgroundColor: AppColorModel.Bluecolor242,
        leading: BackButton(color: Colors.white),
        title: Text("Mon RIB", style: TextStyle(fontSize: 17.dp, fontWeight: FontWeight.bold, color: AppColorModel.WhiteColor),),
        centerTitle: true,
        actions: [
         NotificationWidget(),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gap(70.dp),
              // Text("SWIFT", style: TextStyle(fontSize: 16.dp,)),
              // Text("ABCDEFGHKRY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.dp)),
              // Gap(20.dp),
              // Text("CODE DE LA BANQUE", style: TextStyle(fontSize: 16.dp,)),
              // Text("12345", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.dp)),
              // Gap(20.dp),
              // Text("NOM DE LA BANQUE", style: TextStyle(fontSize: 16.dp,)),
              // Text("UBA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.dp)),
              // Gap(20.dp),
              // Text("TITULAIRE DU COMPTE", style: TextStyle(fontSize: 16.dp,)),
              // Text("Rosca OPIMBA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.dp)),
              // Gap(20.dp),
              // Text("NUMERO DE COMPTE", style: TextStyle(fontSize: 16.dp,)),
              // Text("0142612345", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.dp)),
              // Gap(115.dp),
              // InkWell(
              //   onTap: () {
              //     controller.shareRibAsPdf(
              //       swift: "ABCDEFGHKRY",
              //       codebank: 12345,
              //       nombank: "UBA",
              //       titulairecompte: "Rosca OPIMBA",
              //       numcompte: "0142612345",
              //     );
              //   },
              //   child: ContainerWidget(
              //     height: 07.h,
              //     width: 120.w,
              //     borderRadius: BorderRadius.circular(06.dp),
              //     color: AppColorModel.Bluecolor242,
              //     child: Center(
              //       child: Text(
              //         "Partager",
              //         style: TextStyle(
              //           fontSize: 17.dp,
              //           color: AppColorModel.WhiteColor,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}