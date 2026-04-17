import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/View/Bonus/cercle.dart';
import 'package:onyfast/Widget/container.dart';

import '../../Controller/colorcerclecontroller.dart';

class Bonus extends StatefulWidget {
  const Bonus({super.key});

  @override
  State<Bonus> createState() => _BonusState();
}

class _BonusState extends State<Bonus> {
  @override
  Widget build(BuildContext context) {
     double screenWidth = MediaQuery.of(context).size.width;
      final controller = Get.put(SemiArcController());
    return Scaffold(
              appBar: AppBar(
  title: Text(
    'Bonus',
    style: TextStyle(
      color: AppColorModel.GreyBlack,
    ),
  ),
  backgroundColor: AppColorModel.WhiteColor,
  centerTitle: true,
  leading: IconButton(
    icon: Icon(
      Icons.arrow_back,
      color: AppColorModel.GreyBlack,
    ),
    onPressed: () {
      Navigator.of(context).pop();
    },
  ),
  actions: [
    ContainerWidget(
      height: 03.h,
      width: 12.w,
      child: Image.asset(
        "asset/nodification.png",
        color: AppColorModel.BlueColor,
      ),
    ),
   SizedBox(width: 03.w), 
  ],
),
      body: Column(
        children: [
ContainerWidget(
  height: 23.h,
  width: screenWidth,
  color: AppColorModel.GreyWhite,
  child: Column(
    
    children: [
      Gap(10.dp),
      ContainerWidget(height: 20.h,width: 94.w,
      borderRadius: BorderRadius.circular(15.dp),
      color: AppColorModel.WhiteColor,
      child: Center(
        child: Column(
          children: [
            Gap(48.dp),
            SemiCircleChart(percentage: 89)
          ],
        ),
      ),
      ),
      
      ],
  )
        
),
Gap(10.dp),
ContainerWidget(height: 15.h,
borderRadius: BorderRadius.circular(10.dp),
width:95.w,
color: AppColorModel.GreyWhite,
child: Column(
  children: [
    Gap(04.dp),
    Row(
      children: [
        Gap(10.dp),
        Text("Cash back", style: TextStyle(fontSize: 12.dp, color: AppColorModel.BlueColor,fontWeight: FontWeight.bold),),
        Gap(05.dp),
        Text("ONYFAST", style: TextStyle(fontSize: 12.dp,fontWeight: FontWeight.bold, color: AppColorModel.BlueColor),),
      ],
    ),
    Gap(07.dp),
    Row(
      children: [
        Gap(10.dp),
        ContainerWidget(
          height: 07.h,
          width: 25.w,
          color: AppColorModel.WhiteColor,
          borderRadius: BorderRadius.circular(05.dp),
          child: Column(
            children: [
              Gap(15.dp),
              Text("Nombre d’opérations", style: TextStyle(fontSize: 08.dp),),
              Gap(03.dp),
                Text("0", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),),
            ],
          ),
        ),
        Gap(10.dp),
        ContainerWidget(
          height: 07.h,
          width: 25.w,
          color: AppColorModel.WhiteColor,
          borderRadius: BorderRadius.circular(05.dp),
          child: Column(
            children: [
              Gap(15.dp),
              Text("Nombre de points", style: TextStyle(fontSize: 08.dp),),
              Gap(03.dp),
                Text("0", style: TextStyle(fontSize: 13.dp, fontWeight: FontWeight.bold),),
            ],
          ),
        ),
        Gap(10.dp),
        ContainerWidget(
          height: 07.h,
          width: 25.w,
          color: AppColorModel.WhiteColor,
          borderRadius: BorderRadius.circular(05.dp),
          child: Column(
            children: [
              Gap(15.dp),
              Text("Jusqu’à", style: TextStyle(fontSize: 08.dp),),
              Gap(03.dp),
                Text("50.000 XAF", style: TextStyle(fontSize: 12.dp, fontWeight: FontWeight.bold),),
            ],
          ),
        ),
      ],
    ),
    Gap(10.dp),
    Row(
      children: [
        Gap(10.dp),
        ContainerWidget(
          height: 00.50.h,
          width: 30.w,
          borderRadius: BorderRadius.circular(03.dp),
          color: AppColorModel.BlueColor,
        ),
        ContainerWidget(
          height: 00.50.h,
          width: 21.w,
          borderRadius: BorderRadius.circular(03.dp),
          color: AppColorModel.WhiteColor,
        ),
        Gap(16.dp),
        ContainerWidget(
          height: 02.h,
          width: 25.w,
          color: AppColorModel.BlueColor,
          borderRadius: BorderRadius.circular(02.dp),
        )
      ],
    ),
    
  ],
),
),
Gap(05.dp),
ContainerWidget(height: 15.h,
borderRadius: BorderRadius.circular(10.dp),
width:95.w,
color: AppColorModel.GreyWhite,
child: Column(
  children: [
    Gap(04.dp),
    Row(
      children: [
        Gap(10.dp),
        Text("Cash back", style: TextStyle(fontSize: 12.dp, color: AppColorModel.BlueColor,fontWeight: FontWeight.bold),),
        Gap(05.dp),
        Text("Orca", style: TextStyle(fontSize: 12.dp,fontWeight: FontWeight.bold, color: AppColorModel.BlueColor),),
      ],
    ),
    Gap(07.dp),
    Row(
      children: [
        Gap(10.dp),
       Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Le nom du produit :", style: TextStyle(fontSize: 09.dp),),
                    Text("Informations :", style: TextStyle(fontSize: 09.dp),),
        ],
       ),
        Gap(114.dp),
        ContainerWidget(
          height: 05.50.h,
          width: 25.w,
          color: AppColorModel.WhiteColor,
          borderRadius: BorderRadius.circular(05),
          child: Center(
            child: Text("50.000 XAF", style: TextStyle(fontSize: 11.dp, fontWeight: FontWeight.bold),),
          )
        ),
      ],
    ),
    Gap(10.dp),
    Row(
      children: [
        Gap(10.dp),
        ContainerWidget(
          height: 00.50.h,
          width: 30.w,
          borderRadius: BorderRadius.circular(03),
          color: AppColorModel.BlueColor,
        ),
        ContainerWidget(
          height: 00.50.h,
          width: 21.w,
          borderRadius: BorderRadius.circular(03),
          color: AppColorModel.WhiteColor,
        ),
        Gap(16.dp),
        ContainerWidget(
          height: 02.h,
          width: 25.w,
          color: AppColorModel.BlueColor,
          borderRadius: BorderRadius.circular(02),
        )
      ],
    ),
    
  ],
),
),
Gap(05.dp),
ContainerWidget(height: 15.h,
borderRadius: BorderRadius.circular(10.dp),
width:95.w,
color: AppColorModel.GreyWhite,
child: Column(
  children: [
    Gap(04.dp),
    Row(
      children: [
        Gap(10.dp),
        Text("Cash back Canal Box", style: TextStyle(fontSize: 12.dp, color: AppColorModel.BlueColor,fontWeight: FontWeight.bold),),
        
      
      ],
    ),
    Gap(07.dp),
    Row(
      children: [
        Gap(10.dp),
       Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Le nom du produit :", style: TextStyle(fontSize: 09.dp),),
                    Text("Informations :", style: TextStyle(fontSize: 09.dp),),
        ],
       ),
        Gap(114.dp),
        ContainerWidget(
          height: 05.50.h,
          width: 25.w,
          color: AppColorModel.WhiteColor,
          borderRadius: BorderRadius.circular(05),
          child: Center(
            child: Text("30 000 XAF", style: TextStyle(fontSize: 11.dp, fontWeight: FontWeight.bold),),
          )
        ),
      ],
    ),
    Gap(10.dp),
    Row(
      children: [
        Gap(10.dp),
        ContainerWidget(
          height: 00.50.h,
          width: 30.w,
          borderRadius: BorderRadius.circular(03),
          color: AppColorModel.BlueColor,
        ),
        ContainerWidget(
          height: 00.50.h,
          width: 21.w,
          borderRadius: BorderRadius.circular(03),
          color: AppColorModel.WhiteColor,
        ),
        Gap(16.dp),
        ContainerWidget(
          height: 02.h,
          width: 25.w,
          color: AppColorModel.BlueColor,
          borderRadius: BorderRadius.circular(02),
        )
      ],
    ),
    
  ],
),
),
Gap(05.dp),
ContainerWidget(height: 15.h,
borderRadius: BorderRadius.circular(10.dp),
width:95.w,
color: AppColorModel.GreyWhite,
child: Column(
  children: [
    Gap(04.dp),
    Row(
      children: [
        Gap(10.dp),
        Text("Cash back Congo telecom", style: TextStyle(fontSize: 12.dp, color: AppColorModel.BlueColor,fontWeight: FontWeight.bold),),
        
      
      ],
    ),
    Gap(07.dp),
    Row(
      children: [
        Gap(10.dp),
       Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Le nom du produit :", style: TextStyle(fontSize: 09.dp),),
                    Text("Informations :", style: TextStyle(fontSize: 09.dp),),
        ],
       ),
        Gap(114.dp),
        ContainerWidget(
          height: 05.50.h,
          width: 25.w,
          color: AppColorModel.WhiteColor,
          borderRadius: BorderRadius.circular(05),
          child: Center(
            child: Text("20 000 XAF", style: TextStyle(fontSize: 11.dp, fontWeight: FontWeight.bold),),
          )
        ),
      ],
    ),
    Gap(10.dp),
    Row(
      children: [
        Gap(10.dp),
        ContainerWidget(
          height: 00.50.h,
          width: 30.w,
          borderRadius: BorderRadius.circular(03),
          color: AppColorModel.BlueColor,
        ),
        ContainerWidget(
          height: 00.50.h,
          width: 21.w,
          borderRadius: BorderRadius.circular(03),
          color: AppColorModel.WhiteColor,
        ),
        Gap(16.dp),
        ContainerWidget(
          height: 02.h,
          width: 25.w,
          color: AppColorModel.BlueColor,
          borderRadius: BorderRadius.circular(02),
        )
      ],
    ),
    
  ],
),
),
        ],
      ),
    );
  }
}

