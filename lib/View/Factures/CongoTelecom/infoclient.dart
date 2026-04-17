import 'package:flutter/material.dart';
import 'package:onyfast/View/Factures/CongoTelecom/confirmationpayement.dart';
import 'package:onyfast/View/Factures/Widget/appbarcomposant.dart';
import 'package:onyfast/View/Factures/onyfast_payment_complete.dart';
import 'package:onyfast/View/const.dart';

class ClientInfoPage extends StatelessWidget {
  final String phoneNumber;
  const ClientInfoPage({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: buildAppBar(context, '👤', 'Informations client'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [globalColor, const Color(0xFF0052A3)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 24, offset: const Offset(0, 8))],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                        child: const Center(child: Text('👤', style: TextStyle(fontSize: 28))),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jean MOUKOKO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins')),
                          SizedBox(height: 4),
                          Text('Client vérifié', style: TextStyle(fontSize: 13, color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow('Téléphone', '+242 $phoneNumber'),
                  _buildDetailRow('Type', 'Internet Fixe'),
                  _buildDetailRow('Status', 'Actif'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
                border: Border(left: BorderSide(color: const Color(0xFFEF4444), width: 4)),
              ),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 13, color: Color(0xFF991B1B)),
                  children: [
                    TextSpan(text: '⚠️  Votre forfait expire dans '),
                    TextSpan(text: '3 jours', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: '. Renouvelez maintenant pour ne pas perdre votre connexion !'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ConfirmationPage(phoneNumber: phoneNumber, packageName: 'Forfait basic', price: 10000))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: globalColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('📦', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text('Continuer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('✕', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('Annuler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85))),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}
