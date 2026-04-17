import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:onyfast/Controller/OnypayController/onypayController.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import 'package:onyfast/model/Onypay/payementEnAttente.dart';

// ─── HELPERS ADAPTATIFS ───────────────────────────────────────────────────────

bool get _isIOS => Platform.isIOS;
BorderRadius get _cardRadius => BorderRadius.circular(_isIOS ? 18 : 12);
BorderRadius get _buttonRadius => BorderRadius.circular(_isIOS ? 14 : 8);
BorderRadius get _badgeRadius => BorderRadius.circular(_isIOS ? 20 : 6);

List<BoxShadow> get _cardShadow => _isIOS
    ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 3))]
    : [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))];

// ─── PAGE PRINCIPALE ──────────────────────────────────────────────────────────

class PaiementsEnAttentePage extends StatefulWidget {
  const PaiementsEnAttentePage({super.key});

  @override
  State<PaiementsEnAttentePage> createState() => _PaiementsEnAttentePageState();
}

class _PaiementsEnAttentePageState extends State<PaiementsEnAttentePage>
    with TickerProviderStateMixin {
  final OnyPayController ctrl = Get.find<OnyPayController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.loadPendingOtp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isIOS
          ? CupertinoColors.systemGroupedBackground
          : const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // ─── APPBAR ───────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: globalColor,
      elevation: _isIOS ? 0 : 2,
      surfaceTintColor: globalColor,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: _isIOS
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Get.back(),
              child: const Icon(CupertinoIcons.back, color: Colors.white),
            )
          : IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
      title: Text(
        'Paiements en attente',
        style: TextStyle(
          color: Colors.white,
          fontSize: MediaQuery.of(Get.context!)!.size.width > 600?18.sp : 16.sp,
          letterSpacing: _isIOS ? -0.3 : 0,
        ),
      ),
      centerTitle: true,
      actions: const [NotificationWidget()],
    );
  }

  // ─── BODY ─────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return Obx(() {
      if (ctrl.isLoading.value) {
        return Center(
          child: _isIOS
              ? CupertinoActivityIndicator(color: globalColor, radius: 14)
              : CircularProgressIndicator(color: globalColor),
        );
      }

      final liste = ctrl.pendingPayments;
      if (liste.isEmpty) return _buildEmptyState();

      return RefreshIndicator(
        color: globalColor,
        onRefresh: ctrl.loadPendingOtp,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          physics: const BouncingScrollPhysics(),
          itemCount: liste.length,
          itemBuilder: (context, index) {
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 350 + index * 70),
              tween: Tween(begin: 0, end: 1),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                    offset: Offset(0, 24 * (1 - value)), child: child),
              ),
              child: _buildCard(liste[index]),
            );
          },
        ),
      );
    });
  }

  // ─── EMPTY STATE ──────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                color: globalColor.withOpacity(0.08), shape: BoxShape.circle),
            child: Icon(
              _isIOS
                  ? CupertinoIcons.checkmark_circle
                  : Icons.check_circle_outline_rounded,
              size: 40,
              color: globalColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Aucun paiement en attente',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54)),
          const SizedBox(height: 8),
          const Text('Tous vos paiements sont à jour',
              style: TextStyle(fontSize: 13, color: Colors.black38)),
        ],
      ),
    );
  }

  // ─── CARD ─────────────────────────────────────────────────────────────────

  Widget _buildCard(PendingPayment p) {
  return _PaymentCard(p: p, ctrl: ctrl);
}

}
class _PaymentCard extends StatefulWidget {
  final PendingPayment p;
  final OnyPayController ctrl;
  const _PaymentCard({required this.p, required this.ctrl});

  @override
  State<_PaymentCard> createState() => _PaymentCardState();
}

class _PaymentCardState extends State<_PaymentCard> {
  late Timer _timer;
  late double _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.p.expiresAt
        .difference(DateTime.now())
        .inSeconds
        .toDouble()
        .clamp(0, widget.p.ttlSeconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining = widget.p.expiresAt
            .difference(DateTime.now())
            .inSeconds
            .toDouble()
            .clamp(0, widget.p.ttlSeconds);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _remaining <= 0;
    final couleur = isExpired
        ? const Color(0xFFFF3B30)
        : _remaining < 300
            ? const Color(0xFFFF9500)
            : const Color(0xFF34C759);
    final attemptsLeft = widget.p.attemptsLeft;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: _cardRadius, boxShadow: _cardShadow),
      child: Material(
        color: Colors.transparent,
        borderRadius: _cardRadius,
        child: InkWell(
          borderRadius: _cardRadius,
          splashColor: _isIOS ? Colors.transparent : globalColor.withOpacity(0.05),
          highlightColor: _isIOS ? Colors.transparent : globalColor.withOpacity(0.03),
          onTap: () {
            HapticFeedback.lightImpact();
            showDetailSheetPaiement(widget.p, widget.ctrl);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: globalColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(_isIOS ? 14 : 10),
                  ),
                  child: Icon(
                    _isIOS ? CupertinoIcons.creditcard_fill : Icons.payment_rounded,
                    color: globalColor, size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(widget.p.merchant,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                                  color: Colors.black87, letterSpacing: _isIOS ? -0.2 : 0),
                              overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          Text(_formatMontant(widget.p.amount, widget.p.currency),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (widget.p.description.isNotEmpty)
                        Text(widget.p.description,
                          style: const TextStyle(fontSize: 12, color: Colors.black45),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // ✅ TTL qui se met à jour chaque seconde
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: couleur.withOpacity(0.12), borderRadius: _badgeRadius),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_isIOS ? CupertinoIcons.timer : Icons.timer_outlined,
                                    size: 11, color: couleur),
                                const SizedBox(width: 4),
                                Text(
                                  isExpired ? 'Expiré' : _formatTtl(_remaining),
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: couleur),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // ✅ Tentatives colorées si critique
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: attemptsLeft <= 1
                                  ? const Color(0xFFFF3B30).withOpacity(0.1)
                                  : Colors.black.withOpacity(0.05),
                              borderRadius: _badgeRadius,
                            ),
                            child: Text(
                              '$attemptsLeft essai${attemptsLeft > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w500,
                                color: attemptsLeft <= 1 ? const Color(0xFFFF3B30) : Colors.black45),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            _isIOS ? CupertinoIcons.forward : Icons.chevron_right_rounded,
                            size: _isIOS ? 14 : 18, color: Colors.black26),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── DETAIL SHEET ─────────────────────────────────────────────────────────────
 void showDetailSheetPaiement(PendingPayment p, OnyPayController ctrl) {
    showModalBottomSheet(
      isDismissible: false,
      context: Get.context! ,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _DetailSheet(p: p, ctrl: ctrl),
    );
  }
class _DetailSheet extends StatelessWidget {
  final PendingPayment p;
  final OnyPayController ctrl;
  const _DetailSheet({required this.p, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isExpired = p.expiresAt.isBefore(DateTime.now());

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 20),

          Text(
            'Détails du paiement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: _isIOS ? -0.3 : 0,
            ),
          ),
          const SizedBox(height: 20),

          // Bloc montant + barre TTL
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: BoxDecoration(
              color: globalColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(_isIOS ? 16 : 10),
            ),
            child: Column(
              children: [
                Text(
                  _formatMontant(p.amount, p.currency),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: globalColor,
                    letterSpacing: _isIOS ? -0.5 : 0,
                  ),
                ),
                const SizedBox(height: 12),
                _TtlBar(ttlSeconds: p.ttlSeconds, expiresAt: p.expiresAt),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _infoRow(
              _isIOS ? CupertinoIcons.building_2_fill : Icons.store_rounded,
              'Marchand', p.merchant),
          _infoRow(
              _isIOS ? CupertinoIcons.doc_text : Icons.description_outlined,
              'Description', p.description),
          _infoRow(
              _isIOS ? CupertinoIcons.tag : Icons.label_outline_rounded,
              'Réf. paiement', p.paymentId),
          _infoRow(
              _isIOS ? CupertinoIcons.money_dollar_circle : Icons.currency_exchange_rounded,
              'Devise', p.currency),
          _infoRow(
            _isIOS ? CupertinoIcons.refresh : Icons.replay_rounded,
            'Tentatives restantes',
            '${p.attemptsLeft} essai${p.attemptsLeft > 1 ? 's' : ''}',
            valueColor: p.attemptsLeft <= 1 ? const Color(0xFFFF3B30) : null,
          ),
          _infoRow(
            _isIOS ? CupertinoIcons.time : Icons.access_time_rounded,
            'Expire à',
            _formatDateTime(p.expiresAt),
            valueColor: isExpired ? const Color(0xFFFF3B30) : null,
          ),

          const SizedBox(height: 20),

          if (!isExpired && p.attemptsLeft > 0) ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _isIOS
                  ? CupertinoButton(
                      color: globalColor,
                      borderRadius: _buttonRadius,
                      padding: EdgeInsets.zero,
                      onPressed: () => _goToOtp(context),
                      child: const Text('Confirmer le paiement',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: globalColor,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: _buttonRadius),
                      ),
                      onPressed: () => _goToOtp(context),
                      child: const Text('Confirmer le paiement',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
            ),
            const SizedBox(height: 10),
          ],

          SizedBox(
            width: double.infinity,
            height: 44,
            child: _isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54)),
                  )
                : TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54)),
                  ),
          ),
        ],
      ),
    );
  }

  void _goToOtp(BuildContext context) async {
    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 300));
    showModalBottomSheet(
      // ignore: use_build_context_synchronously
      context:  Get.context!, 
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _OtpSheet(p: p, ctrl: ctrl),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 18, color: globalColor.withOpacity(0.7)),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(fontSize: 13, color: Colors.black45)),
          const Spacer(),
          Flexible(
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.black87),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ─── BARRE TTL ANIMÉE ─────────────────────────────────────────────────────────

class _TtlBar extends StatefulWidget {
  final double ttlSeconds;
  final DateTime expiresAt;
  const _TtlBar({required this.ttlSeconds, required this.expiresAt});

  @override
  State<_TtlBar> createState() => _TtlBarState();
}

class _TtlBarState extends State<_TtlBar> {
  late Timer _timer;
  late double _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.expiresAt
        .difference(DateTime.now())
        .inSeconds
        .toDouble()
        .clamp(0, widget.ttlSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining = widget.expiresAt
            .difference(DateTime.now())
            .inSeconds
            .toDouble()
            .clamp(0, widget.ttlSeconds);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = widget.ttlSeconds > 0
        ? (_remaining / widget.ttlSeconds).clamp(0.0, 1.0)
        : 0.0;
    final color = ratio > 0.5
        ? const Color(0xFF34C759)
        : ratio > 0.2
            ? const Color(0xFFFF9500)
            : const Color(0xFFFF3B30);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: Colors.black.withOpacity(0.08),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _remaining <= 0
              ? 'Expiré'
              : 'Expire dans ${_formatTtl(_remaining)}',
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// ─── OTP SHEET ────────────────────────────────────────────────────────────────

class _OtpSheet extends StatefulWidget {
  final PendingPayment p;
  final OnyPayController ctrl;
  const _OtpSheet({required this.p, required this.ctrl});

  @override
  State<_OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends State<_OtpSheet> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isSending = false;
  String _error = '';
  int _secondes = 60;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    for (final f in _focusNodes) f.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _envoyerOtp();
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  Future<void> _envoyerOtp() async {
  setState(() { _isSending = true; _error = ''; });
  
  try {
    final result = await widget.ctrl.renvoyerOtp(paymentId: widget.p.otpId);
    
    if (!mounted) return;
    
    final success = result?['success'] == true;
    
    if (!success) {
      // ✅ isSending = false ICI dans le cas d'échec
      setState(() {
        _isSending = false;
        _error = result?['message'] as String? ?? 'Impossible de renvoyer le code.';
      });
      return; // on sort sans démarrer le countdown
    }
    
  } catch (_) {}
  
  if (!mounted) return;
  
  // ✅ isSending = false ICI dans le cas de succès
  setState(() => _isSending = false);
  _startCountdown();
}

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _secondes = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() { if (_secondes > 0) _secondes--; else t.cancel(); });
    });
  }

  String get _codeComplet => _controllers.map((c) => c.text).join();

  void _onDigitEntered(int index, String value) {
    if (value.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _valider();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _valider() async {
    if (_codeComplet.length < 6) {
      setState(() => _error = 'Veuillez saisir les 6 chiffres du code.');
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() { _isLoading = true; _error = ''; });

    final result = await widget.ctrl.validateOtp(
      paymentId: widget.p.paymentId,
      code: _codeComplet,
    );
     widget.ctrl.loadPendingOtp();

    if (!mounted) return;

    final success = result?['success'] == true;
final message = result?['message'] as String? ?? 'Erreur inconnue.';
final attemptsLeft = result?['data']?['attempts_left'] as int?;

    if (success) {
      HapticFeedback.heavyImpact();
      widget.ctrl.pendingPayments
          .removeWhere((item) => item.paymentId == widget.p.paymentId);
      setState(() => _isLoading = false);
      Navigator.pop(context);
      _showSuccessDialog();
    } else {
      HapticFeedback.vibrate();
       setState(() {
        _isLoading=false;
    _error = attemptsLeft != null
        ? '$message' // déjà formaté par le backend ex: "Code incorrect. 3 tentative(s) restante(s)."
        : message;
  });
  for (final c in _controllers) c.clear();
  _focusNodes[0].requestFocus();
    }
  }

  void _showSuccessDialog() {
    final title = 'Paiement confirmé ✅';
    final content =
        'Le paiement de ${_formatMontant(widget.p.amount, widget.p.currency)} '
        'à ${widget.p.merchant} a été confirmé avec succès.';
    if (_isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Get.back(),
              child: Text('Super !',
                  style: TextStyle(
                      color: globalColor, fontWeight: FontWeight.w700)),
            )
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Super !',
                  style: TextStyle(
                      color: globalColor, fontWeight: FontWeight.w700)),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return 
    Padding(
    // ✅ Gère le clavier proprement
    padding: EdgeInsets.only(
      // bottom: MediaQuery.of(context).viewInsets.bottom,
    ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          left: 24,
          right: 24,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 24),
      
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: globalColor.withOpacity(0.08), shape: BoxShape.circle),
              child: Icon(
                  _isIOS
                      ? CupertinoIcons.lock_shield_fill
                      : Icons.shield_rounded,
                  size: 32,
                  color: globalColor),
            ),
            const SizedBox(height: 16),
      
            Text(
              'Confirmation OTP',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: _isIOS ? -0.3 : 0,
              ),
            ),
            const SizedBox(height: 6),
      
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 13, color: Colors.black45, height: 1.5),
                children: [
                  const TextSpan(text: 'Confirmez le paiement de '),
                  TextSpan(
                    text: _formatMontant(widget.p.amount, widget.p.currency),
                    style:
                        TextStyle(fontWeight: FontWeight.w700, color: globalColor),
                  ),
                  const TextSpan(text: ' à '),
                  TextSpan(
                    text: widget.p.merchant,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
      
            if (_isSending)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isIOS
                        ? CupertinoActivityIndicator(
                            color: globalColor, radius: 10)
                        : SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: globalColor, strokeWidth: 2)),
                    const SizedBox(width: 8),
                    const Text('Envoi du code...',
                        style:
                            TextStyle(fontSize: 12, color: Colors.black45)),
                  ],
                ),
              )
            else
              const Text(
                'Un code à 6 chiffres a été envoyé\nà votre adresse email',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: Colors.black45, height: 1.5),
              ),
      
            const SizedBox(height: 24),
      
            // Cases OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) {
                final w = <Widget>[];
                if (i == 3) {
                  w.add(Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text('-',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                            color: Colors.black38)),
                  ));
                }
                w.add(_buildOtpBox(i));
                return Row(children: w);
              }),
            ),
      
            const SizedBox(height: 10),
      
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: Text(_error,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFFF3B30),
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center),
              )
            else
              const SizedBox(height: 8),
      
            const SizedBox(height: 8),
      
            // Bouton valider
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _isIOS
                  ? CupertinoButton(
                      color: _codeComplet.length == 6 && !_isLoading
                          ? globalColor
                          : globalColor.withOpacity(0.35),
                      borderRadius: _buttonRadius,
                      padding: EdgeInsets.zero,
                      onPressed:
                          _codeComplet.length == 6 && !_isLoading ? _valider : null,
                      child: _isLoading
                          ? const CupertinoActivityIndicator(color: Colors.white)
                          : const Text('Valider le paiement',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _codeComplet.length == 6 && !_isLoading
                            ? globalColor
                            : globalColor.withOpacity(0.35),
                        foregroundColor: Colors.white,
                        elevation: _codeComplet.length == 6 ? 2 : 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: _buttonRadius),
                      ),
                      onPressed:
                          _codeComplet.length == 6 && !_isLoading ? _valider : null,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                          : const Text('Valider le paiement',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
            ),
      
            const SizedBox(height: 12),
      
            // Renvoyer
            _isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _secondes == 0 && !_isSending ? _envoyerOtp : null,
                    child: Text(
                      _secondes > 0
                          ? 'Renvoyer le code dans ${_secondes}s'
                          : 'Renvoyer le code',
                      style: TextStyle(
                          fontSize: 13,
                          color: _secondes == 0 ? globalColor : Colors.black38,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                : TextButton(
                    onPressed:
                        _secondes == 0 && !_isSending ? _envoyerOtp : null,
                    child: Text(
                      _secondes > 0
                          ? 'Renvoyer le code dans ${_secondes}s'
                          : 'Renvoyer le code',
                      style: TextStyle(
                          fontSize: 13,
                          color: _secondes == 0 ? globalColor : Colors.black38,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
      
            const SizedBox(height: 4),
      
            _isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler',
                        style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFFF3B30),
                            fontWeight: FontWeight.w500)),
                  )
                : TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler',
                        style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFFF3B30),
                            fontWeight: FontWeight.w500)),
                  ),
          ],
        ),
      
        )
      ),
    )
    ;
  
  
  
  }

  Widget _buildOtpBox(int index) {
    final isFocused = _focusNodes[index].hasFocus;
    final filled = _controllers[index].text.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 44,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: filled
            ? globalColor.withOpacity(0.06)
            : (_isIOS ? CupertinoColors.systemGrey6 : const Color(0xFFF0F0F0)),
        borderRadius: BorderRadius.circular(_isIOS ? 12 : 8),
        border: Border.all(
          color: isFocused
              ? globalColor
              : filled
                  ? globalColor.withOpacity(0.4)
                  : (_isIOS ? Colors.transparent : Colors.grey.shade300),
          width: isFocused ? 2 : 1.5,
        ),
        boxShadow: !_isIOS && isFocused
            ? [BoxShadow(
                color: globalColor.withOpacity(0.25),
                blurRadius: 6,
                offset: const Offset(0, 2))]
            : null,
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: globalColor),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (v) => _onDigitEntered(index, v),
        ),
      ),
    );
  }
}

// ─── HELPERS GLOBAUX ─────────────────────────────────────────────────────────

String _formatMontant(double montant, String devise) {
  final str = montant.toStringAsFixed(2);
  final parts = str.split('.');
  final buffer = StringBuffer();
  for (int i = 0; i < parts[0].length; i++) {
    if (i != 0 && (parts[0].length - i) % 3 == 0) buffer.write(' ');
    buffer.write(parts[0][i]);
  }
  return '${buffer.toString()}.${parts[1]} $devise';
}

String _formatTtl(double seconds) {
  final s = seconds.toInt();
  if (s >= 3600) return '${s ~/ 3600}h ${(s % 3600) ~/ 60}min';
  if (s >= 60) return '${s ~/ 60}min ${s % 60}s';
  return '${s}s';
}

String _formatDateTime(DateTime dt) {
  return '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year} '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}