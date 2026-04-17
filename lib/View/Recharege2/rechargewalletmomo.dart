import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/View/Recharege2/recheroperateur.dart';
import 'package:onyfast/Widget/container.dart';


class RechargeMomo extends StatefulWidget {
  const RechargeMomo({super.key});

  @override
  State<RechargeMomo> createState() => _RechargeMomoState();
}

class _RechargeMomoState extends State<RechargeMomo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorModel.GreyWhite,
      appBar: AppBar(
        title: Text("Recharger votre wallet", style: TextStyle(fontSize: 16.dp, color: AppColorModel.GreyBlack, fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Gap(50.dp),
            Padding(
              padding: EdgeInsets.all(8.0.dp),
              child: ContainerWidget(height: 60.h,width: 120.w,borderRadius: BorderRadius.circular(10.dp),
              color: AppColorModel.WhiteColor,
              child: Column(
                children: [
                  Gap(08.dp),
                  Container(
                                key: const ValueKey(1),
                                width: 90.w,
                                height: 27.h,
                                decoration: BoxDecoration(
                                  color: AppColorModel.BlueColor,
                                  borderRadius: BorderRadius.circular(10.dp),
                                ),
                                child: Image.asset(
                                  "asset/image_ony.png",
                                  width: 50.w,
                                  height: 100.h,fit: BoxFit.fill,
                                )),
                                Gap(12),
                                Text("Recharger votre wallet à travers votre", style: TextStyle(fontSize: 13.dp, color: AppColorModel.GreyBlack, fontWeight: FontWeight.bold),),
                                Text("compte Mobile Money", style: TextStyle(fontSize: 13.dp, color: AppColorModel.GreyBlack, fontWeight: FontWeight.bold),),
                                Padding(
                                  padding: EdgeInsets.only(left: 27.dp,right: 28.dp,top: 10.dp,bottom: 10.dp),
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        decoration: InputDecoration(
                                          label: Text("Numéro de téléphone")
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                ),
                               
                                Gap(30.dp),
                                InkWell(
                                  onTap: (){  
                                    Get.to(RechargeOperateur());
                                  },
                                  child: ContainerWidget(height: 07.h,width: 90.w,color: AppColorModel.BlueColor,borderRadius: BorderRadius.circular(10.dp),
                                  child: Center(
                                    child: Text("Recharge votre wallet",style: TextStyle(color: AppColorModel.WhiteColor,fontSize: 17.dp, fontWeight: FontWeight.bold),),
                                  ),
                                  ),
                                )
                ],
              ),
              ),
            )
          ],
        ),
      ),
    );
  }
}