import 'package:get/get.dart';

class ContactsCacheController extends GetxController {
  // Données en cache
  static ContactsCacheController? _instance;

  // Variables observables pour les données
  final RxList<Map<String, dynamic>> _cachedAllContacts =
      <Map<String, dynamic>>[].obs;
  final RxBool _isDataLoaded = false.obs;
  final Rx<DateTime?> _lastLoadTime = Rx<DateTime?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  // Variables pour suivre l'état de l'application
  static bool _isFirstAppLaunch = true;

  // Statistiques des contacts
  final RxInt _totalContacts = 0.obs;
  final RxInt _onyfastContacts = 0.obs;
  final RxInt _contactsWithPhones = 0.obs;

  // Getters pour les données
  List<Map<String, dynamic>> get cachedOnyfastContacts =>
      _cachedAllContacts.value;
  List<Map<String, dynamic>> get cachedAllContacts => _cachedAllContacts.value;
  bool get isDataLoaded => _isDataLoaded.value;
  DateTime? get lastLoadTime => _lastLoadTime.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  // Getters pour les statistiques
  int get totalContacts => _totalContacts.value;
  int get onyfastContacts => _onyfastContacts.value;
  int get contactsWithPhones => _contactsWithPhones.value;
  int get contactsWithoutPhones =>
      _totalContacts.value - _contactsWithPhones.value;

  // Singleton pattern pour garantir une seule instance
  static ContactsCacheController get instance {
    if (_instance == null) {
      _instance = ContactsCacheController._internal();
      Get.put(_instance!, permanent: true);
    }
    return _instance!;
  }

  ContactsCacheController._internal();

  // Factory constructor
  factory ContactsCacheController() {
    return instance;
  }

  @override
  void onInit() {
    super.onInit();
    print('🏗️ ContactsCacheController initialisé pour TOUS les contacts');
    print('🚀 Premier lancement de l\'app: $_isFirstAppLaunch');
  }

  // Vérifier si le cache est valide (PERMANENT - jamais d'expiration automatique)
  bool isCacheValid() {
    // Si c'est le premier lancement de l'app, forcer le chargement
    if (_isFirstAppLaunch) {
      print('🚀 Premier lancement de l\'application - chargement requis');
      _isFirstAppLaunch = false;
      return false;
    }

    // Si les données ne sont pas chargées, invalide
    if (!_isDataLoaded.value || _lastLoadTime.value == null) {
      print('❌ Cache invalide: données non chargées');
      return false;
    }

    // Cache valide indéfiniment une fois chargé
    print(
        '✅ Cache PERMANENT valide - ${_totalContacts.value} contacts disponibles depuis ${getTimeSinceLastUpdate()}');
    return true;
  }

  // Obtenir le temps écoulé depuis la dernière mise à jour
  String getTimeSinceLastUpdate() {
    if (_lastLoadTime.value == null) return '';

    final now = DateTime.now();
    final difference = now.difference(_lastLoadTime.value!);

    if (difference.inMinutes < 1) {
      return 'à l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'il y a ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'il y a ${difference.inHours}h${difference.inMinutes % 60}min';
    } else {
      return 'il y a ${difference.inDays}j ${difference.inHours % 24}h';
    }
  }

  // Mettre à jour les données en cache avec calcul des statistiques
  void updateCache(List<Map<String, dynamic>> contacts) {
    print('💾 Mise à jour du cache PERMANENT avec ${contacts.length} contacts');

    _cachedAllContacts.value = List.from(contacts);
    _isDataLoaded.value = true;
    _lastLoadTime.value = DateTime.now();
    _errorMessage.value = '';

    // Calculer les statistiques
    _calculateStatistics(contacts);

    print('✅ Cache permanent mis à jour:');
    print('   📱 Total: ${_totalContacts.value} contacts');
    print('   🔵 OnyFast: ${_onyfastContacts.value} contacts');
    print('   📞 Avec numéros: ${_contactsWithPhones.value} contacts');
    print('   ❌ Sans numéros: $contactsWithoutPhones contacts');
    print('📅 Timestamp: ${_lastLoadTime.value}');
  }

  // Calculer les statistiques des contacts
  void _calculateStatistics(List<Map<String, dynamic>> contacts) {
    _totalContacts.value = contacts.length;

    int onyfastCount = 0;
    int withPhonesCount = 0;

    for (var contact in contacts) {
      if (contact['has_onyfast'] == true) {
        onyfastCount++;
      }
      if (contact['phone'] != null && contact['phone'].toString().isNotEmpty) {
        withPhonesCount++;
      }
    }

    _onyfastContacts.value = onyfastCount;
    _contactsWithPhones.value = withPhonesCount;
  }

  // Obtenir seulement les contacts OnyFast
  List<Map<String, dynamic>> getOnyfastContactsOnly() {
    return _cachedAllContacts
        .where((contact) => contact['has_onyfast'] == true)
        .toList();
  }

  // Obtenir seulement les contacts avec numéros
  List<Map<String, dynamic>> getContactsWithPhones() {
    return _cachedAllContacts
        .where((contact) =>
            contact['phone'] != null && contact['phone'].toString().isNotEmpty)
        .toList();
  }

  // Obtenir seulement les contacts sans numéros
  List<Map<String, dynamic>> getContactsWithoutPhones() {
    return _cachedAllContacts
        .where((contact) =>
            contact['phone'] == null || contact['phone'].toString().isEmpty)
        .toList();
  }

  // Rechercher dans tous les contacts
  List<Map<String, dynamic>> searchInAllContacts(String query) {
    if (query.isEmpty) return _cachedAllContacts.value;

    final searchQuery = query.toLowerCase();
    return _cachedAllContacts.where((contact) {
      final name = contact['name']?.toString().toLowerCase() ?? '';
      final phoneName = contact['phone_name']?.toString().toLowerCase() ?? '';
      final onyfastName =
          contact['onyfast_name']?.toString().toLowerCase() ?? '';
      final phone = contact['phone']?.toString().toLowerCase() ?? '';
      final email = contact['email']?.toString().toLowerCase() ?? '';

      return name.contains(searchQuery) ||
          phoneName.contains(searchQuery) ||
          onyfastName.contains(searchQuery) ||
          phone.contains(searchQuery) ||
          email.contains(searchQuery);
    }).toList();
  }

  // Marquer le début du chargement
  void setLoading(bool loading) {
    _isLoading.value = loading;
    if (loading) {
      _errorMessage.value = '';
      print('⏳ Chargement de tous les contacts en cours...');
    } else {
      print('✅ Chargement de tous les contacts terminé');
    }
  }

  // Définir un message d'erreur
  void setError(String error) {
    _errorMessage.value = error;
    _isLoading.value = false;
    print('❌ Erreur: $error');
  }

  // Vider le cache (UNIQUEMENT pour forcer le rechargement manuel)
  void clearCache() {
    print('🗑️ Vidage MANUEL du cache permanent de tous les contacts');

    _cachedAllContacts.clear();
    _isDataLoaded.value = false;
    _lastLoadTime.value = null;
    _errorMessage.value = '';
    _isLoading.value = false;

    // Réinitialiser les statistiques
    _totalContacts.value = 0;
    _onyfastContacts.value = 0;
    _contactsWithPhones.value = 0;
  }

  // Forcer le rechargement (UNIQUEMENT via pull-to-refresh)
  void forceReload() {
    print('🔄 Rechargement MANUEL forcé de tous les contacts');
    clearCache();
  }

  // Réinitialiser le flag de premier lancement (pour les tests)
  void resetFirstLaunch() {
    _isFirstAppLaunch = true;
    print('🔄 Flag de premier lancement réinitialisé');
  }

  // Obtenir le statut du cache avec statistiques
  String getCacheStatus() {
    if (!_isDataLoaded.value) {
      return 'Aucune donnée';
    } else if (_lastLoadTime.value == null) {
      return 'Données sans timestamp';
    } else {
      return 'Cache permanent actif (${_totalContacts.value} contacts)';
    }
  }

  // Obtenir un résumé des statistiques
  String getStatisticsSummary() {
    if (!_isDataLoaded.value) return 'Aucune donnée disponible';

    return '${_totalContacts.value} contacts • ${_onyfastContacts.value} OnyFast • ${_contactsWithPhones.value} avec numéros';
  }

  // Obtenir les statistiques détaillées
  Map<String, dynamic> getDetailedStatistics() {
    return {
      'total_contacts': _totalContacts.value,
      'onyfast_contacts': _onyfastContacts.value,
      'contacts_with_phones': _contactsWithPhones.value,
      'contacts_without_phones': contactsWithoutPhones,
      'onyfast_percentage': _totalContacts.value > 0
          ? ((_onyfastContacts.value / _totalContacts.value) * 100)
              .toStringAsFixed(1)
          : '0',
      'phones_percentage': _totalContacts.value > 0
          ? ((_contactsWithPhones.value / _totalContacts.value) * 100)
              .toStringAsFixed(1)
          : '0',
    };
  }

  // Vérifier s'il y a des contacts OnyFast
  bool hasOnyfastContacts() {
    return _onyfastContacts.value > 0;
  }

  // Vérifier s'il y a des contacts avec numéros
  bool hasContactsWithPhones() {
    return _contactsWithPhones.value > 0;
  }

  // Debug: afficher l'état du cache avec statistiques
  void debugCache() {
    print('🐛 === DEBUG CACHE PERMANENT TOUS CONTACTS ===');
    print('   - Premier lancement: $_isFirstAppLaunch');
    print('   - Données chargées: $_isDataLoaded');
    print('   - Total contacts: ${_totalContacts.value}');
    print('   - Contacts OnyFast: ${_onyfastContacts.value}');
    print('   - Contacts avec numéros: ${_contactsWithPhones.value}');
    print('   - Contacts sans numéros: $contactsWithoutPhones');
    print('   - Dernière mise à jour: $_lastLoadTime');
    print('   - Temps écoulé: ${getTimeSinceLastUpdate()}');
    print('   - Cache valide: ${isCacheValid()}');
    print('   - Statut: ${getCacheStatus()}');
    print('   - Résumé: ${getStatisticsSummary()}');
    print('   - En chargement: $_isLoading');
    print('   - Erreur: $_errorMessage');
    print('🐛 === FIN DEBUG ===');
  }

  // Méthode pour obtenir des contacts par page (pagination)
  List<Map<String, dynamic>> getContactsPage(int page, int itemsPerPage) {
    final startIndex = (page - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;

    if (startIndex >= _cachedAllContacts.length) {
      return [];
    }

    final actualEndIndex = endIndex > _cachedAllContacts.length
        ? _cachedAllContacts.length
        : endIndex;

    return _cachedAllContacts.sublist(startIndex, actualEndIndex);
  }

  // Vérifier s'il y a plus de données pour la pagination
  bool hasMoreData(int currentPage, int itemsPerPage) {
    final totalItems = _cachedAllContacts.length;
    final loadedItems = currentPage * itemsPerPage;
    return loadedItems < totalItems;
  }

  // Obtenir le nombre total de pages
  int getTotalPages(int itemsPerPage) {
    if (_cachedAllContacts.isEmpty || itemsPerPage <= 0) return 0;
    return (_cachedAllContacts.length / itemsPerPage).ceil();
  }
}
