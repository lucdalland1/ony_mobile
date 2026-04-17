import 'package:flutter/material.dart';
import 'package:onyfast/View/Factures/Widget/appbarcomposant.dart';


// ==================== PAGE 3: Informations Client ====================

// ==================== PAGE 4: Sélection du forfait ====================

// ==================== PAGE 5: Confirmation ====================

// ==================== PAGE 6: Mode de paiement ====================

// ==================== PAGE 7: Paiement Mobile Money ====================


// ==================== PAGE 8: Succès ====================
class SuccessPage extends StatelessWidget {
  final String phoneNumber;
  final String packageName;
  final int price;
  const SuccessPage({super.key, required this.phoneNumber, required this.packageName, required this.price});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: buildAppBar(context, '✅', 'Paiement réussi', hideBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 40),
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8))],
              ),
              child: const Center(child: Text('✓', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white))),
            ),
            const Text('Paiement réussi !', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1F2937), fontFamily: 'Poppins')),
            const SizedBox(height: 8),
            const Text('Votre abonnement a été renouvelé avec succès', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Color(0xFF6B7280))),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Text('🧾', style: TextStyle(fontSize: 32)),
                      SizedBox(width: 12),
                      Text('Reçu de paiement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(height: 2, color: Color(0xFFF9FAFB)),
                  const SizedBox(height: 16),
                  _buildReceiptRow('Transaction ID', '#CT2026012801432'),
                  const Divider(height: 24),
                  _buildReceiptRow('Service', 'Congo Telecom'),
                  const Divider(height: 24),
                  _buildReceiptRow('Forfait', packageName),
                  const Divider(height: 24),
                  _buildReceiptRow('Numéro', '+242 $phoneNumber'),
                  const Divider(height: 24),
                  _buildReceiptRow('Mode de paiement', 'Mobile Money'),
                  const Divider(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Montant payé', style: TextStyle(fontSize: 15)),
                        Text('$price FCFA', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0066CC))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 6, color: Color(0xFF10B981)),
                        SizedBox(width: 6),
                        Text('Validé', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF10B981))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: const Text('📥 Téléchargement du reçu...\n\nVotre reçu a été enregistré dans vos téléchargements !\n\nNuméro de transaction: #CT2026012801432'),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066CC), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📥', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('Télécharger le reçu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: const BorderSide(color: Color(0xFF0066CC), width: 2)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🏠', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('Retour à l\'accueil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0066CC))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
      ],
    );
  }
}
