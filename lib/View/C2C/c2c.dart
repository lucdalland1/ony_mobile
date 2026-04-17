// Flutter UI for Onyfast Wallet - Envoyer Screen

import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:onyfast/View/C2C/c2c_suite.dart';

import '../../Color/app_color_model.dart';
import '../Notification/notification.dart';
import '../../Widget/notificationWidget.dart';

class SendMoneyPage extends StatefulWidget {
  @override
  _SendMoneyPageState createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  final TextEditingController phoneController = TextEditingController();
  String userName = 'Victor Martin';
  String currency = 'XAF';
  final TextEditingController amountController = TextEditingController(text: '50000');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColorModel.Bluecolor242,
        title: Text("C2C", style: TextStyle(fontSize: 17.dp, fontWeight: FontWeight.bold, color: AppColorModel.WhiteColor),),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
        actions: [
    NotificationWidget(),
  ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Envoyer', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: 'Numéro du destinataire',
                  suffixIcon: Icon(Icons.person_search),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
                  ),
                  SizedBox(width: 12),
                   Text(userName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                ],
              ),
              SizedBox(height: 30),
              Text('MONTANT', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 8),

              // Text('${amountController.text} $currency', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
               TextField(
                // controller: phoneController,
                
                // keyboardType: TextInputType.phone,
                // style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                // decoration: InputDecoration(
                //   hintText: '${amountController.text} $currency',
                  
                // ),
                controller: amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Montant',
                   suffixText: currency,
                  // suffixIcon: Icon(Icons.attach_money),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorModel.Bluecolor242,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Continuer', style: TextStyle(fontSize: 17.dp,fontWeight: FontWeight.bold, color: AppColorModel.WhiteColor)),
              ),
              SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Get.to(ContactsOnyfastPage());
                  },
                  child: Text('Voir tous les contacts Onyfast', style: TextStyle(color: AppColorModel.Bluecolor242)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}



