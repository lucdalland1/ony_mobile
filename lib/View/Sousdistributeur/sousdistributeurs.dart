import 'dart:async';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:onyfast/Controller/sousdistributeur/sousdistributeurcontroller.dart';
import 'package:onyfast/View/BottomView/widgets/colors.dart';
import 'package:onyfast/View/Sousdistributeur/widget/skeletonSd.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/View/Sousdistributeur/geolocalisationSd.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/model/sous_distributeur/sousdistributeurmodel.dart' as Model;
import 'package:url_launcher/url_launcher.dart';

class SousDistributeursPage extends StatefulWidget {
  const SousDistributeursPage({super.key});

  @override
  State<SousDistributeursPage> createState() => _SousDistributeursPageState();
}

class _SousDistributeursPageState extends State<SousDistributeursPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  final HierarchySdController sd = Get.put(HierarchySdController());
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _isLoadingMore = false;
  Timer? _statusUpdateTimer;

  String? _selectedVille;
  String? _selectedDistrict;
  String? _selectedQuartier;
  bool _showFilters = false;
  int _activeFiltersCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
    _scrollController.addListener(_onScroll);
    _statusUpdateTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _statusUpdateTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    if (!_isLoadingMore && !sd.isLoading.value) {
      final filtered = _getFilteredDistributeurs(_searchController.text);
      final totalPages = (filtered.length / _itemsPerPage).ceil();
      if (_currentPage < totalPages) {
        setState(() { _isLoadingMore = true; _currentPage++; });
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() { _isLoadingMore = false; });
        });
      }
    }
  }

  void _resetPagination() => setState(() { _currentPage = 1; });

  List<Model.SousDistributeur> _getAllSousDistributeurs() {
    List<Model.SousDistributeur> allSD = [];
    if (sd.hierarchy.value?.data?.villes != null) {
      for (var ville in sd.hierarchy.value!.data!.villes!) {
        for (var district in ville.districts ?? []) {
          for (var quartier in district.quartiers ?? []) {
            allSD.addAll(quartier.sousDistr ?? []);
          }
        }
      }
    }
    return allSD;
  }

  String? _getVilleForDistributeur(Model.SousDistributeur d) {
    if (sd.hierarchy.value?.data?.villes != null) {
      for (var ville in sd.hierarchy.value!.data!.villes!) {
        for (var district in ville.districts ?? []) {
          for (var quartier in district.quartiers ?? []) {
            if (quartier.sousDistr?.any((s) => s.id == d.id) == true)
              return ville.designation;
          }
        }
      }
    }
    return null;
  }

  String? _getDistrictForDistributeur(Model.SousDistributeur d) {
    if (sd.hierarchy.value?.data?.villes != null) {
      for (var ville in sd.hierarchy.value!.data!.villes!) {
        for (var district in ville.districts ?? []) {
          for (var quartier in district.quartiers ?? []) {
            if (quartier.sousDistr?.any((s) => s.id == d.id) == true)
              return district.designation;
          }
        }
      }
    }
    return null;
  }

  String? _getQuartierForDistributeur(Model.SousDistributeur d) {
    if (sd.hierarchy.value?.data?.villes != null) {
      for (var ville in sd.hierarchy.value!.data!.villes!) {
        for (var district in ville.districts ?? []) {
          for (var quartier in district.quartiers ?? []) {
            if (quartier.sousDistr?.any((s) => s.id == d.id) == true)
              return quartier.designation;
          }
        }
      }
    }
    return null;
  }

  List<String> _getAvailableVilles() {
    Set<String> villes = {};
    for (var ville in sd.hierarchy.value?.data?.villes ?? []) {
      if (ville.designation != null) villes.add(ville.designation!);
    }
    return villes.toList()..sort();
  }

  List<String> _getAvailableDistricts() {
    Set<String> districts = {};
    for (var ville in sd.hierarchy.value?.data?.villes ?? []) {
      if (_selectedVille == null || ville.designation == _selectedVille) {
        for (var district in ville.districts ?? []) {
          if (district.designation != null) districts.add(district.designation!);
        }
      }
    }
    return districts.toList()..sort();
  }

  List<String> _getAvailableQuartiers() {
    Set<String> quartiers = {};
    for (var ville in sd.hierarchy.value?.data?.villes ?? []) {
      if (_selectedVille == null || ville.designation == _selectedVille) {
        for (var district in ville.districts ?? []) {
          if (_selectedDistrict == null || district.designation == _selectedDistrict) {
            for (var quartier in district.quartiers ?? []) {
              if (quartier.designation != null) quartiers.add(quartier.designation!);
            }
          }
        }
      }
    }
    return quartiers.toList()..sort();
  }

  void _updateActiveFiltersCount() {
    int count = 0;
    if (_selectedVille != null) count++;
    if (_selectedDistrict != null) count++;
    if (_selectedQuartier != null) count++;
    setState(() { _activeFiltersCount = count; });
  }

  void _resetFilters() {
    setState(() {
      _selectedVille = null;
      _selectedDistrict = null;
      _selectedQuartier = null;
      _activeFiltersCount = 0;
      _showFilters = false;
    });
    _resetPagination();
  }

  List<Model.SousDistributeur> _getFilteredDistributeurs(String query) {
    var filtered = _getAllSousDistributeurs();
    if (_selectedVille != null)
      filtered = filtered.where((d) => _getVilleForDistributeur(d) == _selectedVille).toList();
    if (_selectedDistrict != null)
      filtered = filtered.where((d) => _getDistrictForDistributeur(d) == _selectedDistrict).toList();
    if (_selectedQuartier != null)
      filtered = filtered.where((d) => _getQuartierForDistributeur(d) == _selectedQuartier).toList();
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = filtered.where((d) =>
        (d.nomComplet ?? '').toLowerCase().contains(q) ||
        (d.nom ?? '').toLowerCase().contains(q) ||
        (d.prenom ?? '').toLowerCase().contains(q) ||
        (d.telephone ?? '').toLowerCase().contains(q) ||
        (d.adresse ?? '').toLowerCase().contains(q) ||
        (d.entreprise?.nom ?? '').toLowerCase().contains(q) ||
        (d.entreprise?.localisation ?? '').toLowerCase().contains(q) ||
        (d.localisationGps?.city ?? '').toLowerCase().contains(q)
      ).toList();
    }
    return filtered;
  }

  bool _isOpen(Model.SousDistributeur d) => sd.isDistributeurActuellementOuvert(d);
  Color _getCardColor(Model.SousDistributeur d) => _isOpen(d) ? C.primary : Colors.grey;
  Color _getStatusColor(Model.SousDistributeur d) => _isOpen(d) ? C.green : Colors.red;
  String _getStatusText(Model.SousDistributeur d) => _isOpen(d) ? 'Ouvert' : 'Fermé';

  String _getHoraires(Model.SousDistributeur d) {
    final h = d.horairesOuverture?.aujourdhui;
    if (h == null) return 'Horaires non disponibles';
    if (h.heureOuverture != null && h.heureFermeture != null)
      return '${h.heureOuverture} - ${h.heureFermeture}';
    if (h.estOuvert == true) return 'Ouvert toute la journée';
    if (h.estOuvert == false) return 'Fermé aujourd\'hui';
    return 'Horaires non définis';
  }

  int _countByVille(String v) => _getAllSousDistributeurs()
      .where((d) => _getVilleForDistributeur(d) == v).length;
  int _countByDistrict(String v) => _getAllSousDistributeurs()
      .where((d) => _getDistrictForDistributeur(d) == v &&
          (_selectedVille == null || _getVilleForDistributeur(d) == _selectedVille)).length;
  int _countByQuartier(String v) => _getAllSousDistributeurs()
      .where((d) => _getQuartierForDistributeur(d) == v &&
          (_selectedVille == null || _getVilleForDistributeur(d) == _selectedVille) &&
          (_selectedDistrict == null || _getDistrictForDistributeur(d) == _selectedDistrict)).length;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: C.bg,
      body: Stack(
        children: [
          Column(
            children: [
              _buildNavbar(context, sw),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _buildSearchBar(context, sw),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildBody(context, sw)),
            ],
          ),
          _buildFiltersPanel(sw),
        ],
      ),
    );
  }

  // ── NAVBAR ──────────────────────────────────────────────────
  Widget _buildNavbar(BuildContext context, double sw) {
    return Container(
      decoration: BoxDecoration(
        color: C.primary,
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // GestureDetector(
                  //   onTap: () => Navigator.of(context).pop(),
                  //   child: Container(
                  //     width: 36, height: 36,
                  //     decoration: BoxDecoration(
                  //       color: Colors.white.withOpacity(0.15),
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  //   ),
                  // ),
                  // const SizedBox(width: 12),
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(Icons.store, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Distributeurs',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: rf(context, 17),
                            fontWeight: FontWeight.w700)),
                  ),
                  GestureDetector(
                    onTap: () { HapticFeedback.lightImpact(); Get.to(() => MapLocationPage()); },
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(CupertinoIcons.location, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text('Trouvez votre\npoint de service 📍',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: rf(context, 22),
                      fontWeight: FontWeight.w800,
                      height: 1.2)),
              const SizedBox(height: 4),
              Obx(() {
                final total = sd.hierarchy.value?.statistiques?.totalSousDistributeurs ?? 0;
                return Text(
                  '$total point${total == 1 ? '' : 's'} de service',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: rf(context, 13)),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── SEARCH BAR ──────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context, double sw) {
    final filteredCount = _getFilteredDistributeurs(_searchController.text).length;
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 3))],
              border: Border.all(color: C.divider),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) { _resetPagination(); setState(() {}); },
              style: TextStyle(fontSize: rf(context, 14), color: C.textDark),
              decoration: InputDecoration(
                hintText: 'Rechercher un distributeur...',
                hintStyle: TextStyle(color: C.textGrey, fontSize: rf(context, 13)),
                prefixIcon: Icon(Icons.search, color: C.textGrey, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: C.textGrey, size: 18),
                        onPressed: () { _searchController.clear(); _resetPagination(); setState(() {}); })
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () { HapticFeedback.lightImpact(); setState(() { _showFilters = !_showFilters; }); },
          child: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: _showFilters ? C.primary : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 3))],
              border: Border.all(color: _showFilters ? C.primary : C.divider),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.filter_list,
                    color: _showFilters ? Colors.white : C.primary, size: 22),
                if (_activeFiltersCount > 0 || _searchController.text.isNotEmpty)
                  Positioned(
                    top: 6, right: 6,
                    child: Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(
                        color: _showFilters ? Colors.white : C.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('$filteredCount',
                            style: TextStyle(
                                color: _showFilters ? C.primary : Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── BODY ─────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context, double sw) {
    return RefreshIndicator(
      onRefresh: () async { await sd.fetchHierarchy(); _resetPagination(); },
      color: C.primary,
      child: Obx(() {
        if (sd.isLoading.value) {
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, __) => SkeletonSdCard(),
          );
        }

        if (sd.hierarchy.value == null) {
          return _buildEmptyState('Aucune donnée', 'Tirez pour rafraîchir', context);
        }

        final allFiltered = _getFilteredDistributeurs(_searchController.text);
        final displayed = allFiltered.take(_currentPage * _itemsPerPage).toList();

        if (allFiltered.isEmpty) {
          return _buildEmptyState('Aucun résultat', 'Modifiez votre recherche', context);
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              itemCount: displayed.length + (_isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                if (i == displayed.length) {
                  return Center(child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CupertinoActivityIndicator(color: C.primary),
                  ));
                }
                return _buildCard(displayed[i], context);
              },
            ),
          ),
        );
      }),
    );
  }

  // ── CARD ─────────────────────────────────────────────────────
  Widget _buildCard(Model.SousDistributeur d, BuildContext context) {
    final cardColor = _getCardColor(d);
    final statusColor = _getStatusColor(d);
    final statusText = _getStatusText(d);
    final horaires = _getHoraires(d);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () { HapticFeedback.lightImpact(); _showDetails(d, context); },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.store, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.nomComplet ?? 'Nom indisponible',
                              style: TextStyle(
                                  fontSize: rf(context, 14),
                                  fontWeight: FontWeight.w700,
                                  color: C.textDark),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          Row(children: [
                            Icon(Icons.location_on, size: 13, color: Colors.red[400]),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                d.entreprise?.localisation ?? 'Adresse non disponible',
                                style: TextStyle(fontSize: rf(context, 11.5), color: C.textGrey),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(statusText,
                          style: TextStyle(
                              fontSize: rf(context, 11),
                              fontWeight: FontWeight.w700,
                              color: statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F3F8)),
                const SizedBox(height: 12),
                Row(children: [
                  Icon(Icons.access_time, size: 14, color: C.textGrey),
                  const SizedBox(width: 6),
                  Expanded(child: Text(horaires,
                      style: TextStyle(fontSize: rf(context, 12), color: C.textGrey))),
                ]),
                if (d.entreprise?.nom != null) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.business, size: 14, color: C.textGrey),
                    const SizedBox(width: 6),
                    Expanded(child: Text(d.entreprise!.nom!,
                        style: TextStyle(fontSize: rf(context, 12), color: C.textGrey),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                ],
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: ElevatedButton.icon(
                        onPressed: () { HapticFeedback.lightImpact(); _launchMaps(d); },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cardColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.directions, size: 16),
                        label: Text('Itinéraire', style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: OutlinedButton.icon(
                        onPressed: () { HapticFeedback.lightImpact(); _callDistributeur(d); },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cardColor,
                          side: BorderSide(color: cardColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.phone, size: 16),
                        label: Text('Appeler', style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── DETAILS DIALOG ───────────────────────────────────────────
  void _showDetails(Model.SousDistributeur d, BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B3BAD), Color(0xFF3358D4)],
                    begin: Alignment.centerLeft, end: Alignment.centerRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.store, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.nomComplet ?? 'Nom indisponible',
                          style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.w700, color: Colors.white),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getStatusColor(d).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_getStatusText(d),
                            style: TextStyle(fontSize: rf(context, 10), fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ],
                  )),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ]),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('👤 Informations personnelles', context),
                      const SizedBox(height: 10),
                      if (d.nom != null || d.prenom != null)
                        _detailRow(Icons.person_outline, 'Nom', '${d.prenom ?? ''} ${d.nom ?? ''}'.trim(), context),
                      if (d.email != null) _detailRow(Icons.email_outlined, 'Email', d.email!, context),
                      if (d.telephone != null) _detailRow(Icons.phone_outlined, 'Téléphone', d.telephone!, context),
                      if (d.adresse != null) _detailRow(Icons.location_on_outlined, 'Adresse', d.adresse!, context),

                      if (d.entreprise != null) ...[
                        const SizedBox(height: 20),
                        _sectionTitle('🏢 Entreprise', context),
                        const SizedBox(height: 10),
                        if (d.entreprise!.nom != null) _detailRow(Icons.business_outlined, 'Nom', d.entreprise!.nom!, context),
                        if (d.entreprise!.activite != null) _detailRow(Icons.work_outline, 'Activité', d.entreprise!.activite!, context),
                        if (d.entreprise!.telephone != null) _detailRow(Icons.phone_outlined, 'Téléphone', d.entreprise!.telephone!, context),
                        if (d.entreprise!.localisation != null) _detailRow(Icons.place_outlined, 'Localisation', d.entreprise!.localisation!, context),
                      ],

                      if (d.horairesOuverture != null) ...[
                        const SizedBox(height: 20),
                        _sectionTitle('🕐 Horaires d\'ouverture', context),
                        const SizedBox(height: 10),
                        if (d.horairesOuverture!.jourActuel != null)
                          _detailRow(Icons.today_outlined, 'Aujourd\'hui', d.horairesOuverture!.jourActuel!, context),
                        _detailRow(Icons.access_time_outlined, 'Horaires', _getHoraires(d), context),
                        if (d.horairesOuverture!.semaine?.isNotEmpty == true) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FE),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: C.divider),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Semaine complète',
                                    style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w700, color: C.primary)),
                                const SizedBox(height: 8),
                                ...d.horairesOuverture!.semaine!.map((jour) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(jour.jour ?? '',
                                          style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.w600, color: C.textDark)),
                                      Text(
                                        jour.estOuvert == true
                                            ? (jour.heureOuverture == null && jour.heureFermeture == null
                                                ? 'Ouvert' : '${jour.heureOuverture} - ${jour.heureFermeture}')
                                            : 'Fermé',
                                        style: TextStyle(
                                            fontSize: 8.sp,
                                            color: jour.estOuvert == true ? C.textGrey : Colors.red),
                                      ),
                                    ],
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ],
                      ],

                      if (d.localisationGps != null) ...[
                        const SizedBox(height: 20),
                        _sectionTitle('📍 Localisation GPS', context),
                        const SizedBox(height: 10),
                        if (d.localisationGps!.address != null) _detailRow(Icons.location_on_outlined, 'Adresse', d.localisationGps!.address!, context),
                        if (d.localisationGps!.city != null) _detailRow(Icons.location_city_outlined, 'Ville', d.localisationGps!.city!, context),
                        if (d.localisationGps!.country != null) _detailRow(Icons.flag_outlined, 'Pays', d.localisationGps!.country!, context),
                      ],

                      const SizedBox(height: 20),
                      Row(children: [
                        Expanded(child: SizedBox(
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: () { Navigator.pop(ctx); _launchMaps(d); },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: C.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.directions, size: 18),
                            label: Text('Itinéraire', style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.w600)),
                          ),
                        )),
                        const SizedBox(width: 10),
                        Expanded(child: SizedBox(
                          height: 44,
                          child: OutlinedButton.icon(
                            onPressed: () { Navigator.pop(ctx); _callDistributeur(d); },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: C.primary,
                              side: const BorderSide(color: C.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.phone, size: 18),
                            label: Text('Appeler', style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.w600)),
                          ),
                        )),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, BuildContext context) => Text(title,
      style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: C.primary));

  Widget _detailRow(IconData icon, String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, size: 17, color: C.primary),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 9.sp, color: C.textGrey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 8.sp, color: C.textDark, fontWeight: FontWeight.w600)),
        ])),
      ]),
    );
  }

  // ── FILTERS PANEL ────────────────────────────────────────────
  Widget _buildFiltersPanel(double sw) {
    if (!_showFilters) return const SizedBox.shrink();
    final villesDisp = _getAvailableVilles();
    final districtsDisp = _getAvailableDistricts();
    final quartiersDisp = _getAvailableQuartiers();
    final filteredCount = _getFilteredDistributeurs(_searchController.text).length;
    final totalCount = _getAllSousDistributeurs().length;

    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() { _showFilters = false; }),
        child: Container(
          color: Colors.black.withOpacity(0.45),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75, maxWidth: 500),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1B3BAD), Color(0xFF3358D4)],
                          begin: Alignment.centerLeft, end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                      ),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.tune, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Filtrer les résultats',
                              style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.w700, color: Colors.white)),
                          Text(
                            _activeFiltersCount > 0
                                ? '$_activeFiltersCount filtre${_activeFiltersCount > 1 ? 's' : ''} • $filteredCount/$totalCount résultats'
                                : '$totalCount résultats disponibles',
                            style: TextStyle(fontSize: rf(context, 12), color: Colors.white70),
                          ),
                        ])),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                          child: Text('$filteredCount',
                              style: TextStyle(color: Colors.white, fontSize: rf(context, 14), fontWeight: FontWeight.w700)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => setState(() { _showFilters = false; }),
                        ),
                      ]),
                    ),

                    // Dropdowns
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(18),
                        child: Column(children: [
                          _buildDropdown('Ville', Icons.location_city, villesDisp.length, _selectedVille,
                            [{'value': null, 'label': 'Toutes les villes', 'count': _getAllSousDistributeurs().length},
                             ...villesDisp.map((v) => {'value': v, 'label': v, 'count': _countByVille(v)})],
                            (v) { setState(() { _selectedVille = v; _selectedDistrict = null; _selectedQuartier = null; _updateActiveFiltersCount(); }); _resetPagination(); }),
                          const SizedBox(height: 14),
                          _buildDropdown('District', Icons.map, districtsDisp.length, _selectedDistrict,
                            [{'value': null, 'label': 'Tous les districts', 'count': _getAllSousDistributeurs().where((d) => _selectedVille == null || _getVilleForDistributeur(d) == _selectedVille).length},
                             ...districtsDisp.map((d) => {'value': d, 'label': d, 'count': _countByDistrict(d)})],
                            (v) { setState(() { _selectedDistrict = v; _selectedQuartier = null; _updateActiveFiltersCount(); }); _resetPagination(); }),
                          const SizedBox(height: 14),
                          _buildDropdown('Quartier', Icons.holiday_village, quartiersDisp.length, _selectedQuartier,
                            [{'value': null, 'label': 'Tous les quartiers', 'count': _getAllSousDistributeurs().where((d) => (_selectedVille == null || _getVilleForDistributeur(d) == _selectedVille) && (_selectedDistrict == null || _getDistrictForDistributeur(d) == _selectedDistrict)).length},
                             ...quartiersDisp.map((q) => {'value': q, 'label': q, 'count': _countByQuartier(q)})],
                            (v) { setState(() { _selectedQuartier = v; _updateActiveFiltersCount(); }); _resetPagination(); }),
                        ]),
                      ),
                    ),

                    // Footer
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: C.divider, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                      child: Row(children: [
                        Expanded(child: SizedBox(height: 44,
                          child: OutlinedButton.icon(
                            onPressed: _resetFilters,
                            icon: const Icon(Icons.restart_alt, size: 18),
                            label: const Text('Réinitialiser'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red[400],
                              side: BorderSide(color: Colors.red[300]!),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        )),
                        const SizedBox(width: 10),
                        Expanded(child: SizedBox(height: 44,
                          child: ElevatedButton.icon(
                            onPressed: () => setState(() { _showFilters = false; }),
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Appliquer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: C.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        )),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String title, IconData icon, int count, String? selected,
      List<Map<String, dynamic>> items, Function(String?) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 18, color: C.primary),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.w600, color: C.textDark)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(20)),
          child: Text('$count', style: TextStyle(fontSize: rf(context, 11), fontWeight: FontWeight.w700, color: C.primary)),
        ),
      ]),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: selected != null ? C.primary : C.divider, width: selected != null ? 1.5 : 1),
          borderRadius: BorderRadius.circular(12),
          color: selected != null ? const Color(0xFFF0F4FF) : Colors.white,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: selected,
            borderRadius: BorderRadius.circular(12),
            icon: Icon(Icons.keyboard_arrow_down, color: C.primary, size: 22),
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text('Sélectionner $title',
                  style: TextStyle(color: C.textGrey, fontSize: rf(context, 13))),
            ),
            items: items.map((item) {
              final val = item['value'] as String?;
              final label = item['label'] as String;
              final cnt = item['count'] as int;
              return DropdownMenuItem<String>(
                value: val,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(children: [
                    Expanded(child: Text(label,
                        style: TextStyle(
                            fontSize: rf(context, 13),
                            fontWeight: val == selected ? FontWeight.w700 : FontWeight.normal,
                            color: val == selected ? C.primary : C.textDark))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: val == selected ? const Color(0xFFEEF2FF) : C.divider,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$cnt',
                          style: TextStyle(
                              fontSize: rf(context, 11),
                              fontWeight: FontWeight.w700,
                              color: val == selected ? C.primary : C.textGrey)),
                    ),
                  ]),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ]);
  }

  Widget _buildEmptyState(String title, String subtitle, BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), shape: BoxShape.circle),
            child: Icon(Icons.search_off, size: 35, color: C.primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.w700, color: C.textDark)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(fontSize: rf(context, 13), color: C.textGrey), textAlign: TextAlign.center),
        ])),
      ),
    );
  }

  void _launchMaps(Model.SousDistributeur d) {
    if (d.localisationGps?.latitude != null && d.localisationGps?.longitude != null) {
      Get.to(() => MapLocationPage(targetDistributeur: d, startNavigation: true));
    } else {
      SnackBarService.error(title: 'Oups', 'Ce sous-distributeur n\'a pas partagé sa localisation GPS');
    }
  }

  Future<void> _callDistributeur(Model.SousDistributeur d) async {
    if (d.telephone != null) {
      final uri = Uri(scheme: 'tel', path: '+${d.telephone}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        SnackBarService.warning('Impossible de lancer l\'appel.');
      }
    } else {
      SnackBarService.error('Numéro de téléphone non disponible');
    }
  }
}