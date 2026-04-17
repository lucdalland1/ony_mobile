import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:onyfast/Controller/features/features_controller.dart';
import 'package:onyfast/View/Factures/CongoTelecom/infoclient.dart';
import 'package:onyfast/View/Factures/Widget/appbarcomposant.dart';
import 'package:onyfast/View/Factures/onyfast_payment_complete.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/Widget/dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// ========= PAGE CONGO TELECOM ORIGINALE ====================

class CongoTelecomPage extends StatefulWidget {
  const CongoTelecomPage({super.key});

  @override
  State<CongoTelecomPage> createState() => _CongoTelecomPageState();
}

class _CongoTelecomPageState extends State<CongoTelecomPage> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  List<String> _favorites = [];
  bool _showFavorites = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = prefs.getStringList('congotelecom_favorites') ?? [];
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('congotelecom_favorites', _favorites);
  }

  Future<void> _addToFavorites(String number) async {
    if (number.isEmpty || _favorites.contains(number)) return;

    setState(() {
      _favorites.insert(0, number);
      if (_favorites.length > 5) _favorites.removeLast();
    });
    await _saveFavorites();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Numéro ajouté aux favoris'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _removeFromFavorites(String number) async {
    setState(() {
      _favorites.remove(number);
    });
    await _saveFavorites();
  }

  void _selectFavorite(String number) {
    setState(() {
      _phoneController.text = number;
      _showFavorites = false;
    });
  }

  void _validatePhone() async {
    if (_phoneController.text.isEmpty) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    final service = FeaturesService();

    final isActive =
        await service.isFeatureActive(AppFeature.payementFactureCongoTelecom);

    if (isActive) {
      print('✅ La recharge MoMo est disponible');
    } else {
      Get.back();
      SnackBarService.error(
          '❌ Pour des raisons de maintenance, Le service de paiement Congo Telecom est momentainément suspendu. Nos équipes travaillent d\'arrache-pied pour son rétablissement.\nVeuillez réessayer plus tard.');

      return;
    }
    setState(() => _isLoading = false);

    await _addToFavorites(_phoneController.text);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ClientInfoPage(phoneNumber: _phoneController.text)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    final isLargeScreen = screenWidth >= 600;

    // Responsive padding
    final horizontalPadding =
        isSmallScreen ? 16.0 : (isMediumScreen ? 20.0 : 24.0);
    final verticalSpacing = isSmallScreen ? 16.0 : 24.0;

    // Responsive font sizes
    final titleFontSize = isSmallScreen ? 20.0 : (isMediumScreen ? 24.0 : 28.0);
    final subtitleFontSize = isSmallScreen ? 12.0 : 14.0;
    final labelFontSize = isSmallScreen ? 12.0 : 14.0;
    final buttonFontSize = isSmallScreen ? 14.0 : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: buildAppBar(context, '📞', 'Congo Telecom'),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  maxWidth: isLargeScreen ? 600 : double.infinity,
                ),
                child: Center(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: verticalSpacing),
                        Hero(
                          tag: 'congotelecom',
                          child: Container(
                            width: isSmallScreen
                                ? 60
                                : (isMediumScreen ? 80 : 100),
                            height: isSmallScreen
                                ? 60
                                : (isMediumScreen ? 80 : 100),
                            margin:
                                EdgeInsets.only(bottom: verticalSpacing * 0.67),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color(0xFFFF6B35).withValues(alpha: 0.1),
                                Color(0xFFF7931E).withValues(alpha: 0.1)
                              ]),
                              borderRadius: BorderRadius.circular(
                                  isSmallScreen ? 16 : 20),
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xFFFF6B35)
                                        .withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8))
                              ],
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'asset/congotelecom.svg',
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'Congo Telecom',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1F2937),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 4 : 6),
                        Text(
                          'Renouvelez votre abonnement internet',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        SizedBox(height: verticalSpacing * 1.33),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Numéro d\'abonné',
                              style: TextStyle(
                                fontSize: labelFontSize,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            if (_favorites.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showFavorites = !_showFavorites;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 8 : 12,
                                    vertical: isSmallScreen ? 4 : 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: globalColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _showFavorites
                                            ? Icons.keyboard_arrow_up
                                            : Icons.star,
                                        size: isSmallScreen ? 14 : 16,
                                        color: globalColor,
                                      ),
                                      SizedBox(width: isSmallScreen ? 2 : 4),
                                      Text(
                                        'Favoris',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 10 : 12,
                                          fontWeight: FontWeight.w600,
                                          color: globalColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_showFavorites && _favorites.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFE5E7EB), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: _favorites.map((number) {
                                return InkWell(
                                  onTap: () => _selectFavorite(number),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 12 : 16,
                                      vertical: isSmallScreen ? 10 : 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: _favorites.last != number
                                            ? const BorderSide(
                                                color: Color(0xFFE5E7EB),
                                                width: 1)
                                            : BorderSide.none,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: globalColor,
                                          size: isSmallScreen ? 18 : 20,
                                        ),
                                        SizedBox(width: isSmallScreen ? 8 : 12),
                                        Expanded(
                                          child: Text(
                                            number,
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 13 : 15,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF1F2937),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            size: isSmallScreen ? 16 : 18,
                                            color: const Color(0xFF6B7280),
                                          ),
                                          onPressed: () =>
                                              _removeFromFavorites(number),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 12,
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                          decoration: InputDecoration(
                            hintText: 'Ex: 357022399',
                            hintStyle:
                                TextStyle(fontSize: isSmallScreen ? 14 : 16),
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 12 : 16,
                              vertical: isSmallScreen ? 14 : 16,
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFE5E7EB), width: 2)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFE5E7EB), width: 2)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF0066CC), width: 2)),
                          ),
                        ),
                        SizedBox(height: verticalSpacing),
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                            border: const Border(
                                left: BorderSide(
                                    color: Color(0xFFF59E0B), width: 4)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ℹ️',
                                  style: TextStyle(
                                      fontSize: isSmallScreen ? 16 : 18)),
                              SizedBox(width: isSmallScreen ? 8 : 12),
                              Expanded(
                                child: Text(
                                  'Entrez votre numéro d\'abonné Congo Telecom pour vérifier vos informations et renouveler votre forfait.',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 11 : 13,
                                    color: const Color(0xFF92400E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: verticalSpacing),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:(){
                              _showComingSoon(context);
                            },
                            
                            //  _isLoading ? null : _validatePhone,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: globalColor,
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 14 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: isSmallScreen ? 18 : 20,
                                    height: isSmallScreen ? 18 : 20,
                                    child: const CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : Text(
                                    'Valider le numéro',
                                    style: TextStyle(
                                      fontSize: buttonFontSize,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showComingSoon(context);
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) =>
                              //         const SubscriptionManagementPage(),
                              //   ),
                              // );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 14 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: globalColor, width: 2),
                            ),
                            icon: Icon(
                              Icons.settings,
                              color: globalColor,
                              size: isSmallScreen ? 18 : 20,
                            ),
                            label: Text(
                              'Gérer mes abonnements automatiques',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 13 : buttonFontSize,
                                fontWeight: FontWeight.w700,
                                color: globalColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: verticalSpacing),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}

// ========= MODÈLES DE DONNÉES ====================

class AutoSubscription {
  final String id;
  final String phoneNumber;
  final String customName;
  final String planType;
  final double amount;
  final DateTime nextRenewal;
  final bool isActive;
  final int dayOfMonth;
  final List<SubscriptionHistory> history;
  final String? notificationTime;
  final bool notifyBefore;

  AutoSubscription({
    required this.id,
    required this.phoneNumber,
    required this.customName,
    required this.planType,
    required this.amount,
    required this.nextRenewal,
    required this.isActive,
    required this.dayOfMonth,
    required this.history,
    this.notificationTime,
    this.notifyBefore = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'phoneNumber': phoneNumber,
        'customName': customName,
        'planType': planType,
        'amount': amount,
        'nextRenewal': nextRenewal.toIso8601String(),
        'isActive': isActive,
        'dayOfMonth': dayOfMonth,
        'notificationTime': notificationTime,
        'notifyBefore': notifyBefore,
      };

  factory AutoSubscription.fromJson(Map<String, dynamic> json) =>
      AutoSubscription(
        id: json['id'],
        phoneNumber: json['phoneNumber'],
        customName: json['customName'],
        planType: json['planType'],
        amount: json['amount'],
        nextRenewal: DateTime.parse(json['nextRenewal']),
        isActive: json['isActive'],
        dayOfMonth: json['dayOfMonth'],
        history: [],
        notificationTime: json['notificationTime'],
        notifyBefore: json['notifyBefore'] ?? true,
      );
}

class SubscriptionHistory {
  final String id;
  final DateTime date;
  final double amount;
  final String status;
  final String? errorMessage;

  SubscriptionHistory({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
    this.errorMessage,
  });
}

// ========= PAGE DE GESTION DES ABONNEMENTS ====================

class SubscriptionManagementPage extends StatefulWidget {
  const SubscriptionManagementPage({super.key});

  @override
  State<SubscriptionManagementPage> createState() =>
      _SubscriptionManagementPageState();
}

class _SubscriptionManagementPageState extends State<SubscriptionManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AutoSubscription> _subscriptions = [];
  List<SubscriptionHistory> _allHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeDateFormatting();
    _loadData();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('fr_FR', null);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    _subscriptions = [
      AutoSubscription(
        id: '1',
        phoneNumber: '06 123 45 67',
        customName: 'Internet Maison',
        planType: 'Forfait 50 Go',
        amount: 15000,
        nextRenewal: DateTime.now().add(const Duration(days: 5)),
        isActive: true,
        dayOfMonth: 15,
        history: [],
        notificationTime: '08:00',
        notifyBefore: true,
      ),
      AutoSubscription(
        id: '2',
        phoneNumber: '06 987 65 43',
        customName: 'Bureau',
        planType: 'Forfait 100 Go',
        amount: 25000,
        nextRenewal: DateTime.now().add(const Duration(days: 12)),
        isActive: true,
        dayOfMonth: 20,
        history: [],
      ),
    ];

    _allHistory = [
      SubscriptionHistory(
        id: '1',
        date: DateTime.now().subtract(const Duration(days: 15)),
        amount: 15000,
        status: 'success',
      ),
      SubscriptionHistory(
        id: '2',
        date: DateTime.now().subtract(const Duration(days: 20)),
        amount: 25000,
        status: 'success',
      ),
      SubscriptionHistory(
        id: '3',
        date: DateTime.now().subtract(const Duration(days: 45)),
        amount: 15000,
        status: 'failed',
        errorMessage: 'Solde insuffisant',
      ),
    ];

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    final isLargeScreen = screenWidth >= 600;

    final horizontalPadding = isSmallScreen ? 16.0 : 20.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: buildAppBar(context, '⚙️', 'Gestion des Abonnements'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatsCards(),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isSmallScreen ? 12 : 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: globalColor,
                    unselectedLabelColor: const Color(0xFF6B7280),
                    indicatorColor: globalColor,
                    indicatorWeight: 3,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: isSmallScreen ? 11 : 13,
                    ),
                    tabs: const [
                      Tab(text: 'Actifs'),
                      Tab(text: 'Historique'),
                      Tab(text: 'Paramètres'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildActiveSubscriptionsTab(),
                      _buildHistoryTab(),
                      _buildSettingsTab(),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSubscriptionDialog(),
        backgroundColor: globalColor,
        icon:
            Icon(Icons.add, color: Colors.white, size: isSmallScreen ? 20 : 24),
        label: Text(
          isSmallScreen ? 'Nouveau' : 'Nouvel abonnement',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: isSmallScreen ? 12 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final horizontalPadding = isSmallScreen ? 16.0 : 20.0;

    int activeCount = _subscriptions.where((s) => s.isActive).length;
    double totalMonthly = _subscriptions
        .where((s) => s.isActive)
        .fold(0, (sum, s) => sum + s.amount);

    return Container(
      margin: EdgeInsets.all(horizontalPadding),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              '📊',
              '$activeCount',
              'Actifs',
              const Color(0xFF10B981),
            ),
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Expanded(
            child: _buildStatCard(
              '💰',
              '${totalMonthly.toStringAsFixed(0)} F',
              'Total/mois',
              const Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: isSmallScreen ? 20 : 24)),
          SizedBox(height: isSmallScreen ? 6 : 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 20,
                fontWeight: FontWeight.w800,
                color: color,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSubscriptionsTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final horizontalPadding = isSmallScreen ? 16.0 : 20.0;

    var activeSubscriptions = _subscriptions.where((s) => s.isActive).toList();

    if (activeSubscriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📭', style: TextStyle(fontSize: isSmallScreen ? 48 : 64)),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              'Aucun abonnement actif',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(horizontalPadding),
      itemCount: activeSubscriptions.length,
      itemBuilder: (context, index) {
        return _buildSubscriptionCard(activeSubscriptions[index]);
      },
    );
  }

  Widget _buildSubscriptionCard(AutoSubscription subscription) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    final daysUntil =
        subscription.nextRenewal.difference(DateTime.now()).inDays;
    final isUrgent = daysUntil <= 3;

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(
          color: isUrgent ? const Color(0xFFF59E0B) : const Color(0xFFE5E7EB),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isUrgent
                    ? [const Color(0xFFFEF3C7), Colors.white]
                    : [globalColor.withOpacity(0.1), Colors.white],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isSmallScreen ? 10 : 14),
                topRight: Radius.circular(isSmallScreen ? 10 : 14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: isSmallScreen ? 40 : 50,
                  height: isSmallScreen ? 40 : 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [globalColor, globalColor.withOpacity(0.7)],
                    ),
                    borderRadius:
                        BorderRadius.circular(isSmallScreen ? 10 : 12),
                  ),
                  child: Center(
                    child: Text(
                      '📱',
                      style: TextStyle(fontSize: isSmallScreen ? 20 : 24),
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.customName,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        subscription.phoneNumber,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 11 : 13,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: const Color(0xFF6B7280),
                    size: isSmallScreen ? 20 : 24,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.edit,
                              size: 20, color: Color(0xFF6B7280)),
                          const SizedBox(width: 8),
                          Text('Modifier',
                              style:
                                  TextStyle(fontSize: isSmallScreen ? 13 : 14)),
                        ],
                      ),
                      onTap: () => _showEditSubscriptionDialog(subscription),
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.pause,
                              size: 20, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 8),
                          Text('Suspendre',
                              style:
                                  TextStyle(fontSize: isSmallScreen ? 13 : 14)),
                        ],
                      ),
                      onTap: () => _toggleSubscription(subscription),
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.delete,
                              size: 20, color: Color(0xFFEF4444)),
                          const SizedBox(width: 8),
                          Text('Supprimer',
                              style:
                                  TextStyle(fontSize: isSmallScreen ? 13 : 14)),
                        ],
                      ),
                      onTap: () => _deleteSubscription(subscription),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        child: _buildInfoChip('📦', subscription.planType)),
                    SizedBox(width: isSmallScreen ? 6 : 8),
                    Flexible(
                      child: _buildInfoChip(
                        '💵',
                        '${subscription.amount.toStringAsFixed(0)} F',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 10 : 12),
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                  decoration: BoxDecoration(
                    color: isUrgent
                        ? const Color(0xFFFEF3C7)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: isSmallScreen ? 14 : 16,
                        color: isUrgent
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF6B7280),
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      Expanded(
                        child: Text(
                          'Prochain renouvellement : ${DateFormat('dd/MM/yyyy').format(subscription.nextRenewal)}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            fontWeight: FontWeight.w600,
                            color: isUrgent
                                ? const Color(0xFF92400E)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUrgent)
                  Container(
                    margin: EdgeInsets.only(top: isSmallScreen ? 6 : 8),
                    padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Text('⚠️',
                            style:
                                TextStyle(fontSize: isSmallScreen ? 12 : 14)),
                        SizedBox(width: isSmallScreen ? 6 : 8),
                        Expanded(
                          child: Text(
                            'Renouvellement dans $daysUntil jour${daysUntil > 1 ? 's' : ''} !',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 10 : 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF991B1B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String emoji, String text) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 12,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
          SizedBox(width: isSmallScreen ? 4 : 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final horizontalPadding = isSmallScreen ? 16.0 : 20.0;

    if (_allHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📜', style: TextStyle(fontSize: isSmallScreen ? 48 : 64)),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              'Aucun historique disponible',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    Map<String, List<SubscriptionHistory>> groupedHistory = {};
    for (var item in _allHistory) {
      String monthKey = DateFormat('MMMM yyyy', 'fr_FR').format(item.date);
      groupedHistory.putIfAbsent(monthKey, () => []).add(item);
    }

    return ListView.builder(
      padding: EdgeInsets.all(horizontalPadding),
      itemCount: groupedHistory.length,
      itemBuilder: (context, index) {
        String month = groupedHistory.keys.elementAt(index);
        List<SubscriptionHistory> items = groupedHistory[month]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: isSmallScreen ? 10 : 12,
                left: 4,
              ),
              child: Text(
                month,
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
            ...items.map((item) => _buildHistoryItem(item)),
            SizedBox(height: isSmallScreen ? 16 : 20),
          ],
        );
      },
    );
  }

  Widget _buildHistoryItem(SubscriptionHistory item) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    bool isSuccess = item.status == 'success';

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuccess
              ? const Color(0xFF10B981).withOpacity(0.3)
              : const Color(0xFFEF4444).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 36 : 44,
            height: isSmallScreen ? 36 : 44,
            decoration: BoxDecoration(
              color: isSuccess
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                isSuccess ? '✅' : '❌',
                style: TextStyle(fontSize: isSmallScreen ? 16 : 20),
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSuccess ? 'Paiement réussi' : 'Paiement échoué',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 2 : 4),
                Text(
                  DateFormat('dd/MM/yyyy à HH:mm').format(item.date),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                if (!isSuccess && item.errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(top: isSmallScreen ? 2 : 4),
                    child: Text(
                      item.errorMessage!,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 9 : 11,
                        color: const Color(0xFFEF4444),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${item.amount.toStringAsFixed(0)} F',
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 15,
              fontWeight: FontWeight.w800,
              color:
                  isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final horizontalPadding = isSmallScreen ? 16.0 : 20.0;

    return ListView(
      padding: EdgeInsets.all(horizontalPadding),
      children: [
        _buildSettingsSection(
          '🔔 Notifications',
          [
            _buildSettingsTile(
              Icons.notifications_active,
              'Rappels avant renouvellement',
              'Recevoir une notification 3 jours avant',
              true,
              (value) {},
            ),
            _buildSettingsTile(
              Icons.check_circle,
              'Confirmation de paiement',
              'Notification après chaque paiement',
              true,
              (value) {},
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),
        _buildSettingsSection(
          '💳 Paiement',
          [
            _buildSettingsTile(
              Icons.autorenew,
              'Renouvellement automatique',
              'Activer pour tous les abonnements',
              true,
              (value) {},
            ),
            _buildSettingsTile(
              Icons.account_balance_wallet,
              'Vérifier le solde',
              'Vérifier avant chaque renouvellement',
              true,
              (value) {},
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),
        _buildSettingsSection(
          '🔐 Sécurité',
          [
            _buildSettingsTile(
              Icons.lock,
              'Confirmation par PIN',
              'Demander le PIN pour les modifications',
              false,
              (value) {},
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),
        _buildActionButton(
          Icons.download,
          'Exporter l\'historique',
          const Color(0xFF3B82F6),
          () {
            SnackBarService.success('Export en cours...');
          },
        ),
        SizedBox(height: isSmallScreen ? 10 : 12),
        _buildActionButton(
          Icons.delete_sweep,
          'Supprimer tout l\'historique',
          const Color(0xFFEF4444),
          () {
            _showDeleteHistoryDialog();
          },
        ),
      ],
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: isSmallScreen ? 10 : 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 4 : 8,
      ),
      leading: Icon(icon, color: globalColor, size: isSmallScreen ? 20 : 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: isSmallScreen ? 12 : 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: isSmallScreen ? 10 : 12,
          color: const Color(0xFF6B7280),
        ),
      ),
      trailing: Transform.scale(
        scale: isSmallScreen ? 0.8 : 1.0,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: globalColor,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String text,
    Color color,
    VoidCallback onTap,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
            SizedBox(width: isSmallScreen ? 10 : 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: isSmallScreen ? 14 : 16,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSubscriptionDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    final phoneController = TextEditingController();
    final nameController = TextEditingController();
    String selectedPlan = 'Forfait 50 Go';
    int selectedDay = 15;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            '➕ Nouvel abonnement automatique',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nom personnalisé',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                TextField(
                  controller: nameController,
                  style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                  decoration: InputDecoration(
                    hintText: 'Ex: Internet Maison',
                    hintStyle: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 10 : 12,
                      vertical: isSmallScreen ? 10 : 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  'Numéro d\'abonné',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                  decoration: InputDecoration(
                    hintText: 'Ex: 06 123 45 67',
                    hintStyle: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 10 : 12,
                      vertical: isSmallScreen ? 10 : 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  'Forfait',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedPlan,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 10 : 12,
                      vertical: isSmallScreen ? 10 : 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: ['Forfait 50 Go', 'Forfait 100 Go', 'Forfait Illimité']
                      .map((plan) => DropdownMenuItem(
                            value: plan,
                            child: Text(plan),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedPlan = value!);
                  },
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  'Jour de renouvellement',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                DropdownButtonFormField<int>(
                  initialValue: selectedDay,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 10 : 12,
                      vertical: isSmallScreen ? 10 : 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: List.generate(
                    28,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('Le ${index + 1} de chaque mois'),
                    ),
                  ),
                  onChanged: (value) {
                    setDialogState(() => selectedDay = value!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (phoneController.text.isEmpty ||
                    nameController.text.isEmpty) {
                  SnackBarService.error('Veuillez remplir tous les champs');
                  return;
                }
                Navigator.pop(context);
                SnackBarService.success('Abonnement automatique créé !');
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: globalColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Créer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 13 : 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSubscriptionDialog(AutoSubscription subscription) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    Future.delayed(Duration.zero, () {
      final nameController =
          TextEditingController(text: subscription.customName);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            '✏️ Modifier l\'abonnement',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                decoration: InputDecoration(
                  labelText: 'Nom personnalisé',
                  labelStyle: TextStyle(fontSize: isSmallScreen ? 12 : 13),
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                SnackBarService.success('Abonnement modifié !');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: globalColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Enregistrer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 13 : 14,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _toggleSubscription(AutoSubscription subscription) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            '⏸️ Suspendre l\'abonnement',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Voulez-vous vraiment suspendre l\'abonnement "${subscription.customName}" ?',
            style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                SnackBarService.success('Abonnement suspendu');
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Suspendre',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 13 : 14,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _deleteSubscription(AutoSubscription subscription) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            '🗑️ Supprimer l\'abonnement',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Voulez-vous vraiment supprimer définitivement l\'abonnement "${subscription.customName}" ?',
            style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                SnackBarService.success('Abonnement supprimé');
                setState(() {
                  _subscriptions.remove(subscription);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Supprimer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 13 : 14,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showDeleteHistoryDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '⚠️ Supprimer l\'historique',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Cette action est irréversible. Tout l\'historique des paiements sera supprimé.',
          style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _allHistory.clear();
              });
              SnackBarService.success('Historique supprimé');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Supprimer tout',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 13 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
void _showComingSoon(BuildContext context) {
     Get.dialog(
  AppDialog(
    title: "Bientôt disponible",
    body: "Cette fonctionnalité sera disponible prochainement",
    actions: [
      AppDialogAction(
        label: "OK",
        isDestructive: true,
        onPressed: () => Get.back(),
      ),
    ],
  ),
);
  }

