// Flutter UI for Onyfast Wallet - Boutique Screen

import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:onyfast/Widget/notificationWidget.dart';

import '../../Color/app_color_model.dart';
import '../Notification/notification.dart';

class BoutiquePage extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'label': 'Cartes cadeaux', 'icon': Icons.card_giftcard, 'color': Colors.redAccent},
    {'label': 'Shopping', 'icon': Icons.shopping_cart, 'color': Colors.green},
    {'label': 'Billet', 'icon': Icons.directions_car, 'color': Colors.lightGreen},
    {'label': 'Événement', 'icon': Icons.event, 'color': Colors.deepPurple},
    {'label': 'Crédit mobile', 'icon': Icons.phone_android, 'color': Colors.teal},
    {'label': 'Musique', 'icon': Icons.music_note, 'color': Colors.orange},
    {'label': 'Streaming', 'icon': Icons.play_circle, 'color': Colors.blueAccent},
    {'label': 'Service', 'icon': Icons.settings, 'color': Colors.lightBlue},
  ];

  final List<Map<String, String>> featured = [
    {'label': 'Amazon', 'price': '10 000 FCFA'},
    {'label': 'Netflix', 'price': '10 000 FCFA'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        backgroundColor: AppColorModel.Bluecolor242,

        leading: BackButton(color: Colors.white),
        title: Text("Boutique", style: TextStyle(fontSize: 17.dp, fontWeight: FontWeight.bold, color: AppColorModel.WhiteColor),),
        centerTitle: true,
        actions: [
           NotificationWidget(),
  ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Boutique', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Achetez des cartes prépayées et des produits digitaux'),
              SizedBox(height: 24),
              Text('Catégories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              GridView.count(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 4,
                childAspectRatio: 0.85,
                children: categories.map((item) => _categoryItem(item)).toList(),
              ),
              SizedBox(height: 30),
              Text('Cartes cadeaux', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...featured.map((item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item['label']!),
                    trailing: Text(item['price']!, style: TextStyle(fontWeight: FontWeight.bold)),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryItem(Map<String, dynamic> category) => Column(
        children: [
          CircleAvatar(
            backgroundColor: category['color'].withOpacity(0.2),
            child: Icon(category['icon'], color: category['color']),
            radius: 24,
          ),
          SizedBox(height: 6),
          Text(category['label'], style: TextStyle(fontSize: 12), textAlign: TextAlign.center),
        ],
      );
}



