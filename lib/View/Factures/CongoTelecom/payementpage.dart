import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:onyfast/View/Factures/Widget/appbarcomposant.dart';
import 'package:onyfast/View/Factures/onyfast_payment_complete.dart';

class PaymentPage extends StatelessWidget {
  final String phoneNumber;
  final String packageName;
  final int price;
  const PaymentPage({super.key, required this.phoneNumber, required this.packageName, required this.price});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: buildAppBar(context, '💳', 'Mode de paiement'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Choisissez votre mode de paiement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1F2937), fontFamily: 'Poppins')),
            const SizedBox(height: 16),
            // _buildPaymentMethod(context, '📱', 'Mobile Money', 'Airtel Money, MTN, Vodacom', const Color(0xFF10b981), const Color(0xFF059669), () {
            //   Navigator.push(context, MaterialPageRoute(builder: (context) => MobilePaymentPage(phoneNumber: phoneNumber, packageName: packageName, price: price)));
            // }),
            // const SizedBox(height: 12),
            // _buildPaymentMethod(context, '💳', 'Carte bancaire', 'Visa, Mastercard', const Color(0xFF3b82f6), const Color(0xFF2563eb), () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => SuccessPage(phoneNumber: phoneNumber, packageName: packageName, price: price)))),
            // const SizedBox(height: 12),
            _buildPaymentMethod(context, '👛', 'Wallet Onyfast', 'Solde: 12 500 FCFA', const Color(0xFFf59e0b), const Color(0xFFd97706), () => _processWallet(context)),
            const SizedBox(height: 12),
            // _buildPaymentMethod(context, '🏦', 'Virement bancaire', 'Transfert direct', const Color(0xFF8b5cf6), const Color(0xFF7c3aed), () => _showComingSoon(context, 'Virement bancaire')),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(10),
                border: Border(left: BorderSide(color: const Color(0xFF3B82F6), width: 4)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🔒', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 12),
                  Expanded(child: Text('Vos paiements sont sécurisés et cryptés. Aucune donnée bancaire n\'est conservée sur nos serveurs.', style: TextStyle(fontSize: 13, color: Color(0xFF1E40AF)))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(BuildContext context, String icon, String name, String desc, Color color1, Color color2, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(gradient: LinearGradient(colors: [color1, color2], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                  Text(desc, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            const Text('→', style: TextStyle(fontSize: 20, color: Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text('💳 Mode de paiement "$method" sera bientôt disponible !'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _processWallet(BuildContext context) {
    if (price > 12500) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('❌ Solde insuffisant'),
          content: Text('Solde disponible: 12 500 FCFA\nMontant requis: $price FCFA\n\nVeuillez recharger votre portefeuille ou choisir un autre mode de paiement.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmer le paiement'),
          content: Text('Confirmer le paiement de $price FCFA depuis votre portefeuille Onyfast ?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => SuccessPage(phoneNumber: phoneNumber, packageName: packageName, price: price)));
              },
              child: const Text('Confirmer'),
            ),
          ],
        ),
      );
    }
  }
}
