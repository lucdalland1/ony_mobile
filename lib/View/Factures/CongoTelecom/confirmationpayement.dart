import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:onyfast/View/Factures/CongoTelecom/payementpage.dart';
import 'package:onyfast/View/Factures/Widget/appbarcomposant.dart';
import 'package:onyfast/View/Factures/onyfast_payment_complete.dart';

class ConfirmationPage extends StatelessWidget {
  final String phoneNumber;
  final String packageName;
  final int price;
  const ConfirmationPage(
      {super.key,
      required this.phoneNumber,
      required this.packageName,
      required this.price});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: buildAppBar(context, '✅', 'Confirmation'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Récapitulatif de votre commande',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                    fontFamily: 'Poppins')),
            const SizedBox(height: 16),
            _buildSummaryCard('👤', 'Informations client', [
              ('Nom', 'Jean MOUKOKO'),
              ('Téléphone', '+242 $phoneNumber'),
            ]),
            const SizedBox(height: 16),
            _buildSummaryCard('📦', 'Forfait sélectionné', [
              ('Forfait', packageName),
              ('Validité', '30 jours'),
              ('Début', '16 Février 2026'),
              ('Expiration', '17 Mars 2026'),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                children: [
                  _buildPriceRow('Sous-total', '$price FCFA'),
                  const SizedBox(height: 12),
                  _buildPriceRow('Frais de service', '0 FCFA'),
                  const SizedBox(height: 12),
                  _buildPriceRow('Taxe', '500 FCFA'),
                  const Divider(height: 24, thickness: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total à payer',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0066CC))),
                      Text('${price + 500} FCFA',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0066CC))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PaymentPage(
                          phoneNumber: phoneNumber,
                          packageName: packageName,
                          price: price))),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066CC),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('💳', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('Continuer vers le paiement',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String icon, String title, List<(String, String)> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937))),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.$1,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF6B7280))),
                    Text(item.$2,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        Text(value,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937))),
      ],
    );
  }
}
