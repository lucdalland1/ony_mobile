import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:onyfast/Widget/notificationWidget.dart';

import '../../Color/app_color_model.dart';
import '../Notification/notification.dart';

class FacturesPaiementsPage extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'label': 'Électricité', 'icon': Icons.bolt, 'color': Colors.orange},
    {
      'label': 'Eau',
      'icon': Icons.water_drop,
      'color': Colors.lightBlue,
      'page': EauPage()
    },
    {
      'label': 'Internet',
      'icon': Icons.wifi,
      'color': Colors.purple,
      'page': InternetPage()
    },
    {'label': 'Abonnement TV', 'icon': Icons.tv, 'color': Colors.deepPurple},
    {'label': 'Crédit - \nforfait', 'icon': Icons.phone_android, 'color': Colors.redAccent},
    {'label': 'École', 'icon': Icons.school, 'color': Colors.blue},
    {
      'label': 'Santé',
      'icon': Icons.local_hospital,
      'color': Colors.green,
      'page': SantePage()
    },
    {'label': 'Autres',
     'icon': Icons.more_horiz,
      'color': Colors.grey,
      //'page': MerchantPage()
      },
  ];

  final Map<String, String> aPayer = {
    'provider': 'ÉNERCité',
    'due': '25 000 FCFA',
    'date': 'Échéancé 25 avr.'
  };

  final Map<String, String> historique = {
    'provider': 'Canal+',
    'paid': '15 000 FCFA',
    'date': 'Payé 2 avr.'
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColorModel.Bluecolor242,
        leading: BackButton(color: Colors.white),
        title: Text("Abonnement", 
          style: TextStyle(
            fontSize: 17.dp, 
            fontWeight: FontWeight.bold, 
            color: AppColorModel.WhiteColor
          ),
        ),
        centerTitle: true,
        actions: [
         NotificationWidget(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Factures & Paiements', 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Payez vos factures et gérez vos abonnements récurrents'),
            SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              childAspectRatio: 0.9,
              physics: NeverScrollableScrollPhysics(),
              children: categories.map((item) => _categoryItem(item, context)).toList(),
            ),
            SizedBox(height: 30),
            Text('Factures à payer', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.orange.withOpacity(0.2),
                child: Icon(Icons.bolt, color: Colors.orange),
              ),
              title: Text(aPayer['provider']!),
              subtitle: Text(aPayer['date']!),
              trailing: Text(aPayer['due']!, 
                style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 20),
            Text('Historique', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.black,
                child: Text('C+', style: TextStyle(color: Colors.white)),
              ),
              title: Text(historique['provider']!),
              subtitle: Text(historique['date']!),
              trailing: Text(historique['paid']!, 
                style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryItem(Map<String, dynamic> category, BuildContext context) => InkWell(
    onTap: () {
      if (category['page'] != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => category['page']),
        );
      }
    },
    child: Column(
      children: [
        CircleAvatar(
          backgroundColor: category['color'].withOpacity(0.2),
          child: Icon(category['icon'], color: category['color']),
          radius: 24,
        ),
        SizedBox(height: 6),
        Text(category['label'], 
          style: TextStyle(fontSize: 12), 
          textAlign: TextAlign.center),
      ],
    ),
  );
}

// Pages spécifiques pour chaque catégorie
class SantePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Santé'),
      ),
      body: Center(
        child: Text('Page des factures de santé'),
      ),
    );
  }
}

class EauPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eau'),
      ),
      body: Center(
        child: Text('Page des factures d\'eau'),
      ),
    );
  }
}

class InternetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Internet'),
      ),
      body: Center(
        child: Text('Page des factures d\'internet'),
      ),
    );
  }
}