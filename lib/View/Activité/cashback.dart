import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:onyfast/Widget/notificationWidget.dart';

import '../../Color/app_color_model.dart';
import '../Notification/notification.dart';

class CashbackPage extends StatelessWidget {
 final List<Map<String, dynamic>> gainCategories = [
  {'label': 'Commerçants', 'icon': Icons.store, 'color': Colors.orange},
  {'label': 'Virement', 'icon': Icons.attach_money, 'color': Colors.blue},
  {'label': 'Boutique', 'icon': Icons.shopping_bag, 'color': Colors.purple},
  {
    'label': 'Offres sponsorisées',
    'icon': Icons.campaign,
    'color': Colors.redAccent,
  },
];

  final List<Map<String, dynamic>> cashbackOffers = [
    {
      'label': '5% remboursé sur Canal+',
      'action': 'Continuer',
      'logo': Icons.tv
    },
    {
      'label': '5% en bonus',
      'action': 'Activer',
      'logo': Icons.local_offer,
      'logoColor': Colors.orange
    },
    {
      'label': 'Invite un ami\n3 000 FCFA offerts',
      'action': 'Inviter',
      'avatar': 'https://randomuser.me/api/portraits/women/44.jpg'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
 appBar: AppBar(
        backgroundColor: AppColorModel.Bluecolor242,
        title: Text("Cashback", style: TextStyle(fontSize: 17.dp, fontWeight: FontWeight.bold, color: AppColorModel.WhiteColor),),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
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
              Text('Cashback & Récompenses', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _cashbackBox('Total cashback', '7 500 FCFA'),
                  _cashbackBox('Montant disponible', '2 500 FCFA')
                ],
              ),
              SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Retirer'),
                ),
              ),
              SizedBox(height: 20),
              Text('Gagner du cashback sur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceAround,
              //   children: gainCategories.map((cat) => _gainItem(cat)).toList(),
                
              // ),
               GridView.count(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 4,
                childAspectRatio: 0.85,
                children: gainCategories.map((cat) => _gainItem(cat)).toList(),
              ),
              SizedBox(height: 30),
              Text('Offres de cashback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('EN CE MOMENT', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 10),
              ...cashbackOffers.map((offer) => _offerItem(offer)).toList()
            ],
          ),
        ),
      ),
    );
  }

  Widget _cashbackBox(String title, String value) => Container(
        width: 150,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
          ],
        ),
      );

  Widget _gainItem(Map<String, dynamic> item) => Column(
        children: [
          CircleAvatar(
            backgroundColor: item['color'].withOpacity(0.2),
            child: Icon(item['icon'], color: item['color']),
            radius: 24,
          ),
          SizedBox(height: 4),
          Text(item['label'], style: TextStyle(fontSize: 12), textAlign: TextAlign.center)
        ],
      );

  Widget _offerItem(Map<String, dynamic> offer) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            offer.containsKey('avatar')
                ? CircleAvatar(backgroundImage: NetworkImage(offer['avatar']), radius: 20)
                : CircleAvatar(
                    backgroundColor: offer['logoColor'] ?? Colors.grey.shade300,
                    child: Icon(offer['logo'], color: Colors.white),
                    radius: 20,
                  ),
            SizedBox(width: 12),
            Expanded(child: Text(offer['label']!)),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(offer['action']),
            )
          ],
        ),
      );
}
