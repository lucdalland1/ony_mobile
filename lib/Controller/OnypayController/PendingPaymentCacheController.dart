import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/model/Onypay/payementEnAttente.dart';

class PendingPaymentCacheController extends GetxController {
  static PendingPaymentCacheController get to => Get.find();

  final _storage = GetStorage();
  Timer? _clearTimer;

  static const String _storageKey = 'pending_payment_courant';
  static const Duration _ttl = Duration(minutes: 5);

  final Rxn<PendingPayment> paymentCourant = Rxn<PendingPayment>();

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage(); // Restaure si l'app a été relancée avant expiration
  }

  /// 💾 Sauvegarder le paiement courant + lancer le timer
  void savePayment(PendingPayment payment) {
    _clearTimer?.cancel();

    // Sauvegarder en mémoire
    paymentCourant.value = payment;

    // Sauvegarder avec timestamp d'expiration
    final data = {
      'payment': {
        'otp_id': payment.otpId,
        'payment_id': payment.paymentId,
        'amount': payment.amount,
        'currency': payment.currency,
        'description': payment.description,
        'merchant': payment.merchant,
        'attempts_left': payment.attemptsLeft,
        'expires_at': payment.expiresAt.toIso8601String(),
        'ttl_seconds': payment.ttlSeconds,
      },
      'expiresAt': DateTime.now().add(_ttl).toIso8601String(),
    };
    _storage.write(_storageKey, jsonEncode(data));

    print('✅ Paiement sauvegardé, expiration dans 5 minutes');

    // Lancer le timer de suppression
    _clearTimer = Timer(_ttl, () {
      clearPayment();
      print('🗑️ Paiement supprimé après 5 minutes');
    });
  }

  /// 🔄 Restaurer depuis le storage (au démarrage)
  void _loadFromStorage() {
    final raw = _storage.read<String>(_storageKey);
    if (raw == null) return;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final expiresAt = DateTime.parse(data['expiresAt'] as String);
      final remaining = expiresAt.difference(DateTime.now());

      if (remaining.isNegative) {
        // Déjà expiré
        clearPayment();
        return;
      }

      // Restaurer en mémoire
      paymentCourant.value = PendingPayment.fromJson(
        data['payment'] as Map<String, dynamic>,
      );

      print('✅ Paiement restauré, expire dans ${remaining.inSeconds}s');

      // Relancer le timer avec le temps restant
      _clearTimer = Timer(remaining, () {
        clearPayment();
        print('🗑️ Paiement supprimé après expiration');
      });
    } catch (e) {
      print('❌ Erreur restauration paiement: $e');
      clearPayment();
    }
  }

  /// 🗑️ Supprimer le paiement
  void clearPayment() {
    _clearTimer?.cancel();
    paymentCourant.value = null;
    _storage.remove(_storageKey);
  }

  /// ✅ Vérifier si un paiement est en cache
  bool get hasPayment => paymentCourant.value != null;

  @override
  void onClose() {
    _clearTimer?.cancel();
    super.onClose();
  }
}
