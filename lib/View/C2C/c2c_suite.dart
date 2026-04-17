// Flutter UI for Onyfast Wallet - Contacts Onyfast Screen

import 'package:flutter/material.dart';

class ContactsOnyfastPage extends StatelessWidget {
  final List<Map<String, String>> contacts = [
    {'name': 'Annette Henry', 'image': 'https://randomuser.me/api/portraits/women/1.jpg'},
    {'name': 'Courtney Palmer', 'image': 'https://randomuser.me/api/portraits/men/2.jpg'},
    {'name': 'Danny Lambert', 'image': 'https://randomuser.me/api/portraits/men/3.jpg'},
    {'name': 'Jennifer Nguyen', 'image': 'https://randomuser.me/api/portraits/women/4.jpg'},
    {'name': 'Joseph Garcia', 'image': 'https://randomuser.me/api/portraits/men/5.jpg'},
    {'name': 'Katherine Turner', 'image': 'https://randomuser.me/api/portraits/women/6.jpg'},
    {'name': 'Marvin Cooper', 'image': 'https://randomuser.me/api/portraits/men/7.jpg'},
    {'name': 'Paul Russell', 'image': 'https://randomuser.me/api/portraits/men/8.jpg'},
    {'name': 'Roberta Cox', 'image': 'https://randomuser.me/api/portraits/women/9.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0A2149),
        title: Text('ONYFAST', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contacts Onyfast', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text('Voir vos contacts utilisant Onyfast', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: contacts.length,
                separatorBuilder: (context, index) => Divider(height: 1),
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(contact['image']!),
                    ),
                    title: Text(contact['name']!),
                    onTap: () {},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



