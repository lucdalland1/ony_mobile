import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:onyfast/View/Factures/CongoTelecom/speedcongo.dart';
import 'package:onyfast/View/const.dart';

class FactureWallet extends StatefulWidget {
  const FactureWallet({super.key});

  @override
  State<FactureWallet> createState() => _FactureWalletState();
}

class _FactureWalletState extends State<FactureWallet> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tous';

  final List<Map<String, dynamic>> _services = [
    // {
    //   'icon': '🏦',
    //   'name': 'Banques',
    //   'category': 'Services bancaires',
    //   'color1': const Color(0xFF8b5cf6),
    //   'color2': const Color(0xFF7c3aed),
    //   'available': true
    // },
    // {
    //   'icon': '📺',
    //   'name': 'Canal+',
    //   'category': 'Télévision',
    //   'color1': const Color(0xFFf43f5e),
    //   'color2': const Color(0xFFe11d48),
    //   'available': false
    // },
    {
      'icon': '🏦',
      'name': 'Abiki',
      'category': 'Assurance',
      'color1': const Color(0xFFFF6B35).withValues(alpha: 0.1),
      'color2': const Color(0xFFF7931E).withValues(alpha: 0.1),
      'available': true,
      "svg": "asset/congotelecom.svg"
    },
    {
      'icon': '📞',
      'name': 'Congo Telecom',
      'category': 'Internet',
      'color1': const Color(0xFFFF6B35).withValues(alpha: 0.1),
      'color2': const Color(0xFFF7931E).withValues(alpha: 0.1),
      'available': true,
      "svg": "asset/congotelecom.svg"
    },
    // {
    //   'icon': '🎓',
    //   'name': 'Écoles',
    //   'category': 'Éducation',
    //   'color1': const Color(0xFFec4899),
    //   'color2': const Color(0xFFdb2777),
    //   'available': false
    // },
    // {
    //   'icon': '💧',
    //   'name': 'La Congolaise',
    //   'category': 'Eau',
    //   'color1': const Color(0xFF38bdf8),
    //   'color2': const Color(0xFF0ea5e9),
    //   'available': false
    // },
    // {
    //   'icon': '🏠',
    //   'name': 'Loyer',
    //   'category': 'Immobilier',
    //   'color1': const Color(0xFFf59e0b),
    //   'color2': const Color(0xFFd97706),
    //   'available': false
    // },
    // {
    //   'icon': '💡',
    //   'name': 'SNE',
    //   'category': 'Électricité',
    //   'color1': const Color(0xFF667eea),
    //   'color2': const Color(0xFF764ba2),
    //   'available': false
    // },
    // {
    //   'icon': '🌐',
    //   'name': 'Vodacom',
    //   'category': 'Internet',
    //   'color1': const Color(0xFF10b981),
    //   'color2': const Color(0xFF059669),
    //   'available': false
    // },
  ];

  final List<String> _categories = [
    'Tous',
    // 'Services bancaires',
    // 'Télévision',
    // 'Télécommunications',
    // 'Éducation',
    // 'Eau',
    // 'Immobilier',
    // 'Électricité',
    'Assurance',
    'Internet'
  ];

  List<Map<String, dynamic>> get _filteredServices {
    var filtered =
        _services.where((service) => service['available'] == true).toList();

    if (_selectedCategory != 'Tous') {
      filtered = filtered
          .where((service) => service['category'] == _selectedCategory)
          .toList();
    }

    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where((service) =>
              service['name']
                  .toString()
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              service['category']
                  .toString()
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategories(),
            Expanded(child: _buildServicesList()),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: globalColor,
      leading: IconButton(onPressed: () => Get.back(), icon:  Icon(
        Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios_new,
         color: Colors.white)),
      title: Text(
        'Paiement de factures',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        // IconButton(
        //   onPressed: _showNotifications,
        //   icon: Icon(Icons.notifications_outlined, color: Colors.white),
        // ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            globalColor,
            const Color(0xFF0052A3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: globalColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bienvenue !',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Payez vos factures\nen toute simplicité',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Rechercher un service...',
                hintStyle:
                    const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                prefixIcon: Icon(Icons.search, color: globalColor),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : 'Tous';
                });
              },
              backgroundColor: Colors.white,
              selectedColor: globalColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected ? globalColor : const Color(0xFFE5E7EB),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServicesList() {
    if (_filteredServices.isEmpty) {
      return Center(
        child: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: globalColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Center(
                child: Icon(
                  Icons.search_off,
                  size: 48,
                  color: globalColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun service trouvé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Essayez de modifier votre recherche',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        )),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredServices.length,
      itemBuilder: (context, index) {
        final service = _filteredServices[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildServiceCard(service),
        );
      },
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleServiceTap(service),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Hero(
                  tag: 'congotelecom',
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF6B35).withOpacity(0.1),
                          const Color(0xFFF7931E).withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'asset/congotelecom.svg',
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service['category'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                // Container(
                //   padding: const EdgeInsets.all(8),
                //   decoration: BoxDecoration(
                //     color: service['available']
                //         ? const Color(0xFF10b981).withOpacity(0.1)
                //         : const Color(0xFF6B7280).withOpacity(0.1),
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   child: Icon(
                //     service['available'] ? Icons.check_circle : Icons.schedule,
                //     color: service['available']
                //         ? const Color(0xFF10b981)
                //         : const Color(0xFF6B7280),
                //     size: 20,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleServiceTap(Map<String, dynamic> service) {
    if (!service['available']) {
      _showComingSoonDialog(service['name']);
      return;
    }

    switch (service['name']) {
      case 'Congo Telecom':
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const CongoTelecomPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 900),
          ),
        );
        break;
      default:
        _showComingSoonDialog(service['name']);
    }
  }

  void _showComingSoonDialog(String serviceName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0066CC).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.schedule, color: Color(0xFF0066CC)),
            ),
            const SizedBox(width: 12),
            const Text('Bientôt disponible'),
          ],
        ),
        content: Text(
            'Le service "$serviceName" sera bientôt disponible. Nous travaillons pour vous offrir la meilleure expérience.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF0066CC),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(CupertinoIcons.bell, color: Color(0xFF0066CC)),
            SizedBox(width: 12),
            Text('Notifications'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Aucune nouvelle notification'),
            SizedBox(height: 16),
            Text(
                'Vous recevrez ici les rappels de paiements et les confirmations de transactions.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
