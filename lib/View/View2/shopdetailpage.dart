import 'package:flutter/material.dart';

class ShopDetailPage extends StatelessWidget {
  final String shopName;

  ShopDetailPage({required this.shopName});

  @override
  Widget build(BuildContext context) {
    final TextEditingController priceController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text(shopName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Achat chez $shopName', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Entrez le prix',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Récupérer le prix saisi
                final price = double.tryParse(priceController.text);
                if (price != null) {
                  // Logique d'achat
                  print('Achat effectué chez $shopName pour $price FCFA');
                  Navigator.pop(context); // Retourner à la page précédente
                } else {
                  // Afficher un message d'erreur si le prix n'est pas valide
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez entrer un prix valide')),
                  );
                }
              },
              child: Text('Acheter'),
            ),
          ],
        ),
      ),
    );
  }
}