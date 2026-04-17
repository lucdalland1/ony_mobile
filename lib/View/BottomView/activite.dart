// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/verou/verroucontroller.dart';
import 'package:onyfast/View/Notification/notification.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Controller/history/history_activiticontroller.dart';
import 'package:onyfast/View/menuscreen.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import 'package:onyfast/model/history/historymodel.dart';
import 'package:intl/intl.dart';

class ActivityPage extends StatefulWidget {
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  TransactionsController controller = Get.find();
  final ScrollController _scrollController = ScrollController();
  String selectedPeriod = 'Cette semaine';
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        _loadMoreTransactions();
      }
    });
  }

  Future<void> _loadMoreTransactions() async {
    if (isLoadingMore || !controller.canLoadMore) return;
    setState(() => isLoadingMore = true);
    try {
      await controller.loadMoreTransactions();
    } catch (e) {
      debugPrint('Erreur chargement: $e');
    } finally {
      setState(() => isLoadingMore = false);
    }
  }

  void _navigateToTransactionDetails(TransactionData transaction) {
    Get.to(
      TransactionDetailsPage(transaction: transaction),
      transition: Transition.downToUp,
    );
  }

  Map<String, List<TransactionData>> _groupTransactionsByDate() {
    Map<String, List<TransactionData>> grouped = {};

    for (TransactionData transaction in controller.transactions) {
      try {
        DateTime date = DateTime.parse(transaction.date).toLocal();
        DateTime now = DateTime.now();
        bool shouldInclude = false;

        switch (selectedPeriod) {
          case "Aujourd'hui":
            shouldInclude = _isSameDay(date, now);
            break;
          case "Hier":
            shouldInclude = _isSameDay(date, now.subtract(Duration(days: 1)));
            break;
          case "Cette semaine":
            DateTime monday = now.subtract(Duration(days: now.weekday - 1));
            DateTime sunday = monday.add(Duration(days: 6));
            shouldInclude = date.isAfter(monday.subtract(Duration(seconds: 1))) &&
                date.isBefore(sunday.add(Duration(days: 1)));
            break;
          case "Ce mois":
            shouldInclude = date.year == now.year && date.month == now.month;
            break;
          case "Les 3 derniers mois":
            shouldInclude = date.isAfter(
                DateTime(now.year, now.month - 3, now.day)
                    .subtract(Duration(seconds: 1)));
            break;
          case "Cette année":
            shouldInclude = date.year == now.year;
            break;
          default:
            shouldInclude = true;
        }

        if (!shouldInclude) continue;

        String dateKey = _getDateLabel(date, now);
        grouped.putIfAbsent(dateKey, () => []).add(transaction);
      } catch (e) {
        debugPrint('Erreur parsing date: $e');
      }
    }

    var sorted = grouped.entries.toList()
      ..sort((a, b) {
        if (a.key == "Aujourd'hui") return -1;
        if (b.key == "Aujourd'hui") return 1;
        if (a.key == "Hier") return -1;
        if (b.key == "Hier") return 1;
        try {
          return DateFormat('dd/MM/yyyy')
              .parse(b.key)
              .compareTo(DateFormat('dd/MM/yyyy').parse(a.key));
        } catch (_) {
          return 0;
        }
      });

    return Map.fromEntries(sorted);
  }

  bool _isSameDay(DateTime d1, DateTime d2) =>
      d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;

  String _getDateLabel(DateTime date, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return "Aujourd'hui";
    if (dateOnly == yesterday) return "Hier";
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _getAvatar(TransactionData transaction) {
    final isCredit = transaction.signe == '+';
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCredit ? Colors.blue : globalColor,
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: SvgPicture.asset(
          isCredit ? 'asset/fleche-bas.svg' : 'asset/fleche-retrait.svg',
          color: Colors.white,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            CupertinoIcons.arrow_up_down,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getTransactionStyle(TransactionData transaction) {
    bool isPositive = transaction.signe == '+';
    return {
      'color': isPositive ? Colors.green : Colors.red,
    };
  }

  String _getTransactionLabel(TransactionData transaction) {
    final from = transaction.emetteur.from;
    final nom = transaction.destinataire.nomComplet;
    final to = transaction.destinataire.to;

    if (transaction.signe == '+') {
      return from?.isNotEmpty == true ? 'Reçu de $from' : 'Argent reçu';
    } else {
      if (nom?.isNotEmpty == true) return 'Transfert $nom';
      if (to?.isNotEmpty == true) return 'Transfert $to';
      return 'Transfert envoyé';
    }
  }

  String _getTransactionDescription(TransactionData transaction) {
    final op = transaction.operateur ?? 'Opérateur';
    switch (transaction.typeTransaction) {
      case 9:
        return transaction.signe == '+'
            ? 'Transfert reçu via $op'
            : 'Transfert envoyé via $op';
      case 2:
        return 'Retrait d\'espèces';
      case 3:
        return 'Dépôt d\'espèces';
      case 4:
        return 'Transaction';
      default:
        return 'Transaction';
    }
  }

  @override
  Widget build(BuildContext context) {
    AppSettingsController.to.setInactivity(true);

    // Breakpoints responsifs
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final hPadding = isTablet ? 8.w : 4.w;

    return Scaffold(
      backgroundColor: globalColor,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              _buildAppBar(isTablet),
              SizedBox(height: isTablet ? 2.h : 4.h),
              _buildPeriodSelector(hPadding, isTablet),
              SizedBox(height: 2.h),
              Expanded(
                child: Obx(() => _buildTransactionList(hPadding, isTablet)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 6.w : 4.w,
        vertical: isTablet ? 1.5.h : 2.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), globalColor],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Row(
        children: [

          Container(
            width: isTablet ? 36.dp : 30.dp,
            height: isTablet ? 36.dp : 30.dp,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: SizedBox(
            width: 30.dp,
            height: 30.dp,
            child: Center(
              child: ClipRRect(
                child: Image.asset(
                  "asset/onylogo.png",
                  height: 27.dp,
                  width: 27.dp,
                ),
              ),
            ),
          ),
          ),
          Spacer(),
          Text(
            'Activité',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold
              
            ),
          ),
          Spacer(),
          NotificationWidget(),
          SizedBox(width: 2.w),
          IconButton(
            onPressed: () => Get.find<GlobalDrawerController>().openDrawer(),
            icon: Icon(
              CupertinoIcons.ellipsis_vertical,
              color: Colors.white,
              size: isTablet ? 22 : 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(double hPadding, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: globalColor),
        ),
        child: PopupMenuButton<String>(
          color: Colors.white,
          offset: Offset(0, 50),
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            setState(() => selectedPeriod = value);
            controller.loadTransactionsByPeriod(value);
          },
          itemBuilder: (_) => [
            "Aujourd'hui",
            'Cette semaine',
            'Ce mois',
            'Les 3 derniers mois',
            'Cette année',
          ].map((value) {
            final isSelected = selectedPeriod == value;
            return PopupMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Color(0xFF1D348C)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? Color(0xFF1D348C)
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Icon(CupertinoIcons.check_mark,
                            color: Colors.white, size: 12)
                        : null,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        color: isSelected
                            ? Color(0xFF1D348C)
                            : Colors.grey.shade700,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        fontSize: isTablet ? 12.sp : 10.sp,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 5.w : 4.w,
              vertical: isTablet ? 1.5.h : 1.8.h,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1D348C).withOpacity(0.05),
                  Color(0xFF1D348C).withOpacity(0.02),
                ],
              ),
              border: Border.all(
                color: Color(0xFF1D348C).withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(CupertinoIcons.calendar,
                    color: Color(0xFF1D348C),
                    size: isTablet ? 22 : 18),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    selectedPeriod,
                    style: TextStyle(
                      fontSize: isTablet ? 12.sp : 10.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D348C),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Color(0xFF1D348C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(CupertinoIcons.chevron_down,
                      size: isTablet ? 18 : 16,
                      color: Color(0xFF1D348C)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(double hPadding, bool isTablet) {
    if (controller.isLoading.value && controller.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(
              color: Color(0xFF1D348C),
              radius: isTablet ? 18 : 15,
            ),
            SizedBox(height: 16),
            Text(
              'Chargement des transactions...',
              style: TextStyle(
                color: globalColor,
                fontSize: isTablet ? 12.sp : 10.sp,
              ),
            ),
          ],
        ),
      );
    }

    final grouped = _groupTransactionsByDate();

    if (grouped.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.doc_text,
                  size: isTablet ? 72 : 64, color: globalColor),
              SizedBox(height: 16),
              Text(
                'Aucune transaction trouvée',
                style: TextStyle(
                  fontSize: isTablet ? 12.sp : 10.sp,
                  color: globalColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Aucune transaction pour la période sélectionnée',
                style: TextStyle(
                  fontSize: isTablet ? 12.sp : 10.sp,
                  color: globalColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshTransactions,
      color: Color(0xFF1D348C),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: hPadding),
        itemCount: grouped.length + (controller.canLoadMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == grouped.length) {
            return Container(
              padding: EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Obx(() => controller.isLoadingMore.value
                  ? Column(
                      children: [
                        CupertinoActivityIndicator(
                          color: Color(0xFF1D348C),
                          radius: isTablet ? 18 : 15,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Chargement...',
                          style: TextStyle(
                            color: globalColor,
                            fontSize: isTablet ? 12.sp : 10.sp,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Tirez pour charger plus',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: isTablet ? 12.sp : 10.sp,
                      ),
                      textAlign: TextAlign.center,
                    )),
            );
          }

          final entry = grouped.entries.elementAt(index);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? 10 : 12,
                ),
                child: Row(
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 12.sp : 10.sp,
                        color: Color(0xFF1D348C),
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFF1D348C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${entry.value.length} transaction${entry.value.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: isTablet ? 12.sp : 10.sp,
                          color: Color(0xFF1D348C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...entry.value.map((t) => _buildTransactionItem(t, isTablet)),
              SizedBox(height: 1.h),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(TransactionData transaction, bool isTablet) {
    final style = _getTransactionStyle(transaction);
    final label = _getTransactionLabel(transaction);
    final description = _getTransactionDescription(transaction);
    final avatarSize = isTablet ? 52.0 : 44.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 5 : 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToTransactionDetails(transaction),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(isTablet ? 14 : 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: transaction.signe == '+' ? Colors.blue : globalColor,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 12 : 10),
                    child: SvgPicture.asset(
                      transaction.signe == '+'
                          ? 'asset/fleche-bas.svg'
                          : 'asset/fleche-retrait.svg',
                      color: Colors.white,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        CupertinoIcons.arrow_up_down,
                        color: Colors.white,
                        size: isTablet ? 18 : 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 4.w : 3.w),

                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: globalColor,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 10.sp : 9.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          color: globalColor,
                          fontSize: isTablet ? 10.sp : 8.sp,
                        ),
                      ),
                      if (transaction.statut != 'completed') ...[
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: transaction.statut == 'pending'
                                ? globalColor
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            transaction.statut == 'pending'
                                ? 'En attente'
                                : transaction.statut == 'failed'
                                    ? 'Échoué'
                                    : transaction.statut,
                            style: TextStyle(
                              fontSize: isTablet ? 10.sp : 8.sp,
                              color: transaction.statut == 'pending'
                                  ? Colors.white
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(width: 2.w),

                // Montant + chevron
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${NumberFormat('#,##0', 'fr_FR').format(double.tryParse(transaction.montant.toString()) ?? 0.0).replaceAll(',', ' ')} FCFA',
                      style: TextStyle(
                        color: style['color'],
                        fontSize: isTablet ? 12.sp : 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (transaction.frais != '0.00') ...[
                      SizedBox(height: 2),
                      Text(
                        'Frais: ${transaction.frais} FCFA',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: isTablet ? 12.sp : 10.sp,
                        ),
                      ),
                    ],
                    SizedBox(height: 4),
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: isTablet ? 12.sp : 10.sp,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Transaction Details ───────────────────────────────────────────────────

class TransactionDetailsPage extends StatelessWidget {
  final TransactionData transaction;
  const TransactionDetailsPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Détails de la transaction',
          style: TextStyle(fontSize: isTablet ? 12.sp : 10.sp),
        ),
        backgroundColor: Color(0xFF1D348C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Résumé', isTablet),
            _buildInfoTile('Référence', transaction.reference, isTablet),
            _buildInfoTile('Date', transaction.date, isTablet),
            _buildInfoTile(
                'Montant',
                '${NumberFormat("#,##0", "fr_FR").format(double.tryParse(transaction.montant.toString()) ?? 0.0)} FCFA',
                isTablet),
            _buildInfoTile(
                'Frais',
                '${NumberFormat("#,##0", "fr_FR").format(double.tryParse(transaction.frais.toString()) ?? 0.0)} FCFA',
                isTablet),
            _buildInfoTile('Type', transaction.typeTransaction.toString(), isTablet),
            _buildInfoTile('Statut', transaction.statut, isTablet),
            _buildInfoTile('Opérateur', transaction.operateur ?? 'Non défini', isTablet),
            _buildInfoTile('Pays', transaction.pays ?? 'Non défini', isTablet),
            _buildInfoTile(
                'Solde avant',
                '${NumberFormat("#,##0", "fr_FR").format(double.tryParse(transaction.soldes.avant.toString()) ?? 0.0)} FCFA',
                isTablet),
            _buildInfoTile(
                'Solde après',
                '${NumberFormat("#,##0", "fr_FR").format(double.tryParse(transaction.soldes.apres.toString()) ?? 0.0)} FCFA',
                isTablet),
            SizedBox(height: 24),
            _buildSectionTitle('Émetteur', isTablet),
            _buildInfoTile('User ID', transaction.emetteur.userId.toString(), isTablet),
            _buildInfoTile('Source', transaction.emetteur.from ?? 'Non défini', isTablet),
            _buildInfoTile('Wallet', transaction.emetteur.wallet?.toString() ?? 'Non défini', isTablet),
            SizedBox(height: 24),
            _buildSectionTitle('Destinataire', isTablet),
            _buildInfoTile('Nom complet', transaction.destinataire.nomComplet ?? 'Non défini', isTablet),
            _buildInfoTile('Destination', transaction.destinataire.to ?? 'Non défini', isTablet),
            _buildInfoTile('Compte', transaction.destinataire.compte?.toString() ?? 'Non défini', isTablet),
            _buildInfoTile('Wallet', transaction.destinataire.wallet?.toString() ?? 'Non défini', isTablet),
            if (transaction.operations.isNotEmpty) ...[
              SizedBox(height: 24),
              _buildSectionTitle('Opérations', isTablet),
              ...transaction.operations.asMap().entries.map((entry) {
                final op = entry.value;
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Opération #${entry.key + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 12.sp : 10.sp,
                          color: Color(0xFF1D348C),
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildInfoTile('ID', op.id.toString(), isTablet),
                      _buildInfoTile(
                          'Montant',
                          '${NumberFormat("#,##0", "fr_FR").format(double.tryParse(op.montant.toString()) ?? 0.0)} FCFA',
                          isTablet),
                      _buildInfoTile('Sens', op.sensOperation, isTablet),
                      _buildInfoTile('Précision', op.precision, isTablet),
                      _buildInfoTile('Début', op.dates.debut, isTablet),
                      _buildInfoTile('Fin', op.dates.fin ?? 'Non défini', isTablet),
                    ],
                  ),
                );
              }),
            ],
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isTablet ? 12.sp : 10.sp,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1D348C),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String? value, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 6 : 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$label :',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isTablet ? 12.sp : 10.sp,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value ?? 'Non défini',
              style: TextStyle(
                fontSize: isTablet ? 12.sp : 10.sp,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivitySettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres'),
        backgroundColor: Color(0xFF1D348C),
        foregroundColor: Colors.white,
      ),
      body: Center(child: Text('Paramètres d\'activité')),
    );
  }
}