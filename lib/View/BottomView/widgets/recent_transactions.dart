import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:onyfast/Controller/%20manage_cards_controller_v2.dart';
import 'package:onyfast/Controller/RecenteTransaction/recenttransactcontroller.dart';
import 'package:onyfast/View/BottomView/widgets/colors.dart';

String formatDateFrCustom(DateTime date) {
  const mois = [
    '', 'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
  ];
  final d = date.toLocal();
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${mois[d.month]} ${d.year} à $hh:$mm';
}

// ── Skeleton shimmer ──
class _SkeletonBox extends StatefulWidget {
  final double width, height, radius;
  const _SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: C.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
      ),
    );
  }
}

// ── Skeleton d'une ligne ──
class _TxSkeletonTile extends StatelessWidget {
  const _TxSkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
      child: Row(
        children: [
          _SkeletonBox(width: 11.w, height: 11.w, radius: 12),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(width: 25.w, height: 1.5.h),
                SizedBox(height: 0.8.h),
                _SkeletonBox(width: 35.w, height: 1.2.h),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _SkeletonBox(width: 20.w, height: 1.5.h),
              SizedBox(height: 0.8.h),
              _SkeletonBox(width: 14.w, height: 1.2.h),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Liste skeleton réutilisable ──
Widget _buildSkeletonList() {
  return Column(
    children: List.generate(
      3,
      (i) => Column(
        children: [
          const _TxSkeletonTile(),
          if (i < 2)
            const Divider(
              height: 1,
              thickness: 1,
              color: C.divider,
              indent: 16,
              endIndent: 16,
            ),
        ],
      ),
    ),
  );
}

// ── Widget principal ──
class RecentTransactionsSection extends StatefulWidget {
  const RecentTransactionsSection({super.key});

  @override
  State<RecentTransactionsSection> createState() =>
      _RecentTransactionsSectionState();
}

class _RecentTransactionsSectionState
    extends State<RecentTransactionsSection> {
  late final RecentTransactionsController ctrl;
  late final ManageCardsController cardCtrl;

  Worker? _cardLoadingWorker;
  Worker? _cardIndexWorker;
  bool _hasFetched = false;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find();
    cardCtrl = Get.find();

    _cardLoadingWorker = ever(cardCtrl.isLoading, (bool isLoading) {
      if (cardCtrl.isCardDisplayed && !_hasFetched) {
        _hasFetched = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) ctrl.fetchTransactions();
        });
      }
      if (isLoading) _hasFetched = false;
    });

    _cardIndexWorker = ever(cardCtrl.currentCardIndex, (_) {
      if (cardCtrl.isCardDisplayed) {
        _hasFetched = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) ctrl.fetchTransactions();
        });
      }
    });
  }

  @override
  void dispose() {
    _cardLoadingWorker?.dispose();
    _cardIndexWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            spreadRadius: 2,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transactions récentes',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: C.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Obx(() {
                  if (!cardCtrl.isCardDisplayed) return const SizedBox.shrink();
                  return GestureDetector(
                    onTap: () {
                      _hasFetched = false;
                      ctrl.fetchTransactions();
                    },
                    child: Text(
                      'Tout voir',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: C.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: 1.h),

          // ── Corps ──
          Obx(() {
            if (!cardCtrl.isCardDisplayed) return _buildSkeletonList();
            if (ctrl.isLoading.value) return _buildSkeletonList();

            if (ctrl.transactions.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 9.w,
                        color: C.textGrey.withOpacity(0.4),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Aucune transaction récente',
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: C.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ctrl.transactions.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                thickness: 1,
                color: C.divider,
                indent: 4.w,
                endIndent: 4.w,
              ),
              itemBuilder: (_, i) {
                final tx = ctrl.transactions[i];
                final bool isPositive =
                    tx['sens_utilisateur']?.toString() == '+';

                String precision =
                    tx['type_transaction_designation']?.toString() ??
                        'Transaction';
                final operations = tx['operations'];
                if (operations is List && operations.isNotEmpty) {
                  final p = operations[0]?['precision']?.toString();
                  if (p != null && p.isNotEmpty) precision = p;
                }

                final String montantRaw =
                    tx['montant_numerique']?.toString() ?? '0';
                final double montantVal =
                    double.tryParse(montantRaw) ?? 0.0;
                final String montantFormate =
                    '${isPositive ? '+' : '-'}${NumberFormat('#,##0', 'fr_FR').format(montantVal)} FCFA';

                String dateFormatee = '--';
                final String dateRaw = tx['date']?.toString() ?? '';
                if (dateRaw.isNotEmpty) {
                  final DateTime? parsed = DateTime.tryParse(dateRaw);
                  if (parsed != null) {
                    dateFormatee = formatDateFrCustom(parsed);
                  }
                }

                final String statut = tx['statut']?.toString() ?? '';

                return _TxTile(
                  isPositive: isPositive,
                  title: isPositive ? 'Réception' : 'Envoi',
                  date: dateFormatee,
                  amount: montantFormate,
                  type: precision,
                  statut: statut,
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

// ── Tuile de transaction ──
class _TxTile extends StatelessWidget {
  final bool isPositive;
  final String title, date, amount, type, statut;

  const _TxTile({
    required this.isPositive,
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
    required this.statut,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
      child: Row(
        children: [
          // ── Icône ──
          Container(
            padding: EdgeInsets.all(1.5.w),
            width: 11.w,
            height: 11.w,
            decoration: BoxDecoration(
              color: C.txIconBg,
              borderRadius: BorderRadius.circular(50),
            ),
            child: isPositive
                ? SvgPicture.asset(
                    'asset/bas.svg',
                    colorFilter: const ColorFilter.mode(
                      Colors.green,
                      BlendMode.srcIn,
                    ),
                    fit: BoxFit.scaleDown,
                  )
                : SvgPicture.asset(
                    'asset/droite.svg',
                    colorFilter: ColorFilter.mode(
                      C.primary,
                      BlendMode.srcIn,
                    ),
                    fit: BoxFit.scaleDown,
                  ),
          ),
          SizedBox(width: 3.w),

          // ── Titre + Date ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: C.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 8.sp,
                    color: C.textGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),

          // ── Montant + Type ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isPositive ? C.green : C.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                type,
                style: TextStyle(
                  fontSize: 8.sp,
                  color: C.textGrey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (statut == 'failed')
                Container(
                  margin: EdgeInsets.only(top: 0.5.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 1.5.w,
                    vertical: 0.3.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Échoué',
                    style: TextStyle(
                      fontSize: 8.sp,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}