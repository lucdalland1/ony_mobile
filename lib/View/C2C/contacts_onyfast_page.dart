import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:onyfast/Api/contacts_service.dart';
import 'package:onyfast/Controller/contactsCacheController.dart';
import 'package:onyfast/Controller/contactsController.dart';
import 'package:onyfast/Controller/verou/verroucontroller.dart';
import 'package:onyfast/View/C2C/send_money_page.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'dart:math' as Math;
import '../../Color/app_color_model.dart';

class ContactsOnyfastPage extends StatefulWidget {
  const ContactsOnyfastPage({super.key});

  @override
  _ContactsOnyfastPageState createState() => _ContactsOnyfastPageState();
}

class _ContactsOnyfastPageState extends State<ContactsOnyfastPage> {
  final TextEditingController searchController = TextEditingController();
  final ContactsController contactsController = Get.put(ContactsController());
  final ScrollController _scrollController = ScrollController();

  // Utiliser le contrôleur de cache
  late final ContactsCacheController cacheController;

  // Variables locales pour l'affichage et la pagination
  List<Map<String, dynamic>> filteredContacts = [];
  bool isSearching = false;
  bool isLoadingMore = false;

  // Variables pour pagination
  int currentPage = 1;
  int itemsPerPage = 20;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    print('🎯 === ContactsOnyfastPage initState ===');
    AppSettingsController.to.setInactivity(false);

    // Initialiser le contrôleur de cache
    cacheController = ContactsCacheController.instance;

    // Vérifier et charger les données
    _checkAndLoadData();

    // Listener pour infinite scroll
    _scrollController.addListener(_onScroll);

    print('🎯 === Fin initState ===');
  }

  // Vérification intelligente du cache
  void _checkAndLoadData() {
    print('🔍 === Vérification du cache ===');

    if (cacheController.isCacheValid()) {
      print('✅ Cache valide - utilisation des données existantes');
      _loadFromCache();
    } else {
      print('❌ Cache invalide - chargement nécessaire');
      _loadPhoneContactsWithOnyfast();
    }
  }

  // Charger les données depuis le cache
  void _loadFromCache() {
    print('📥 Chargement depuis le cache...');

    setState(() {
      final allContacts = cacheController.cachedOnyfastContacts;

      // Réinitialiser la pagination
      currentPage = 1;
      int endIndex = Math.min(itemsPerPage, allContacts.length);
      filteredContacts = allContacts.sublist(0, endIndex);
      hasMoreData = allContacts.length > itemsPerPage;
    });

    print('✅ ${filteredContacts.length} contacts chargés depuis le cache');
  }

  // Méthode pour gérer le scroll infini
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore &&
          hasMoreData &&
          !cacheController.isLoading &&
          searchController.text.isEmpty) {
        _loadMoreContacts();
      }
    }
  }

  // Pagination depuis le cache
  Future<void> _loadMoreContacts() async {
    if (isLoadingMore || !hasMoreData) return;

    setState(() {
      isLoadingMore = true;
    });

    print('📄 Chargement page ${currentPage + 1} depuis le cache...');

    await Future.delayed(Duration(milliseconds: 200));

    try {
      final allContacts = cacheController.cachedOnyfastContacts;
      int startIndex = currentPage * itemsPerPage;
      int endIndex = Math.min(startIndex + itemsPerPage, allContacts.length);

      if (startIndex < allContacts.length) {
        List<Map<String, dynamic>> newContacts =
            allContacts.sublist(startIndex, endIndex);

        setState(() {
          filteredContacts.addAll(newContacts);
          currentPage++;
          isLoadingMore = false;
          hasMoreData = endIndex < allContacts.length;
        });

        print('✅ ${newContacts.length} contacts supplémentaires chargés');
      } else {
        setState(() {
          hasMoreData = false;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      print('❌ Erreur pagination: $e');
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  /// Fonction de formatage du téléphone
  String _formatPhoneNumber(String phone) {
    if (phone.isEmpty) return '';

    const String defaultCode = '242';
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');

    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }

    if (cleaned.startsWith('0')) {
      if (cleaned.length >= 9) {
        return '$defaultCode$cleaned';
      }
    } else if (cleaned.startsWith(defaultCode)) {
      if (cleaned.length >= 11) {
        return cleaned;
      }
    } else if (cleaned.length >= 8 && cleaned.length <= 9) {
      return '${defaultCode}0$cleaned';
    } else if (cleaned.length >= 10) {
      return cleaned;
    }

    return '';
  }

  // Chargement principal des données - MODIFIÉ pour inclure TOUS les contacts
  Future<void> _loadPhoneContactsWithOnyfast() async {
    print('🚀 === DÉBUT chargement complet ===');

    cacheController.setLoading(true);

    try {
      print('🔄 Récupération des contacts du téléphone...');

      final deviceContacts =
          await ContactsService.getContacts(withThumbnails: false);
      print('📱 ${deviceContacts.length} contacts récupérés');

      if (deviceContacts.isEmpty) {
        cacheController.setError('Aucun contact trouvé dans votre téléphone');
        return;
      }

      // Extraction et formatage des numéros POUR TOUS LES CONTACTS
      List<String> phoneNumbers = [];
      List<Map<String, dynamic>> allPhoneContacts = [];

      for (var contact in deviceContacts) {
        if (contact.phones.isNotEmpty) {
          for (var phoneEntry in contact.phones) {
            final phone = _formatPhoneNumber(phoneEntry.number);
            if (phone.isNotEmpty && !phoneNumbers.contains(phone)) {
              phoneNumbers.add(phone);
              allPhoneContacts.add({
                'name': contact.displayName.isNotEmpty
                    ? contact.displayName
                    : 'Sans nom',
                'phone': phone,
                'original_phone': phoneEntry.number,
                'has_onyfast': false, // Par défaut, aucun compte OnyFast
              });
            }
          }
        } else {
          // NOUVEAU: Inclure même les contacts sans numéro
          allPhoneContacts.add({
            'name': contact.displayName.isNotEmpty
                ? contact.displayName
                : 'Sans nom',
            'phone': '',
            'original_phone': '',
            'has_onyfast': false,
          });
        }
      }

      print(
          '📱 ${allPhoneContacts.length} contacts traités (avec et sans numéros)');

      // Vérification des comptes OnyFast SEULEMENT pour ceux qui ont des numéros
      Set<String> onyfastPhones = {};
      Map<String, Map<String, dynamic>> onyfastUsersMap = {};

      if (phoneNumbers.isNotEmpty) {
        print('🔍 Vérification des comptes OnyFast...');

        final onyfastPhonesList =
            await ContactsService.checkOnyfastUsers(phoneNumbers);
        onyfastPhones = Set<String>.from(onyfastPhonesList);
        print('✅ ${onyfastPhones.length} numéros OnyFast trouvés');

        final onyfastUsers = await ContactsService.getOnyfastContacts();
        print('📋 ${onyfastUsers.length} utilisateurs OnyFast récupérés');

        // Créer une map pour accès rapide aux données OnyFast
        for (var user in onyfastUsers) {
          String userPhone1 = _formatPhoneNumber(user['telephone'] ?? '');
          String userPhone2 = _formatPhoneNumber(user['phone'] ?? '');
          String userPhone3 = _formatPhoneNumber(user['mobile'] ?? '');

          if (userPhone1.isNotEmpty) onyfastUsersMap[userPhone1] = user;
          if (userPhone2.isNotEmpty) onyfastUsersMap[userPhone2] = user;
          if (userPhone3.isNotEmpty) onyfastUsersMap[userPhone3] = user;
        }
      }

      // Mise à jour de TOUS les contacts avec les informations OnyFast
      List<Map<String, dynamic>> finalContacts = [];

      for (var phoneContact in allPhoneContacts) {
        String contactPhone = phoneContact['phone'];
        bool hasOnyfast =
            contactPhone.isNotEmpty && onyfastPhones.contains(contactPhone);

        Map<String, dynamic> finalContact = {
          'name': phoneContact['name'],
          'phone': phoneContact['phone'],
          'phone_display': _formatPhoneForDisplay(phoneContact['phone']),
          'original_phone': phoneContact['original_phone'],
          'has_onyfast': hasOnyfast,
          'phone_name': phoneContact['name'],
        };

        if (hasOnyfast && onyfastUsersMap.containsKey(contactPhone)) {
          final onyfastUser = onyfastUsersMap[contactPhone]!;
          finalContact.addAll({
            'id': onyfastUser['id'] ?? onyfastUser['user_id'],
            'email': onyfastUser['email'] ?? '',
            'avatar': onyfastUser['avatar'] ?? onyfastUser['profile_picture'],
            'is_online': onyfastUser['is_online'] ?? false,
            'last_seen': onyfastUser['last_seen'],
            'created_at': onyfastUser['created_at'],
            'onyfast_name': onyfastUser['name'],
          });
        } else {
          // Pour les contacts sans OnyFast, définir des valeurs par défaut
          finalContact.addAll({
            'id': null,
            'email': '',
            'avatar': null,
            'is_online': false,
            'last_seen': null,
            'created_at': null,
            'onyfast_name': null,
          });
        }

        finalContacts.add(finalContact);
      }

      // Trier les contacts : OnyFast en premier, puis par nom
      finalContacts.sort((a, b) {
        if (a['has_onyfast'] && !b['has_onyfast']) return -1;
        if (!a['has_onyfast'] && b['has_onyfast']) return 1;
        return (a['name'] ?? '').compareTo(b['name'] ?? '');
      });

      // MISE À JOUR DU CACHE
      cacheController.updateCache(finalContacts);

      // Mise à jour de l'affichage local
      setState(() {
        currentPage = 1;
        int endIndex = Math.min(itemsPerPage, finalContacts.length);
        filteredContacts = finalContacts.sublist(0, endIndex);
        hasMoreData = finalContacts.length > itemsPerPage;
      });

      cacheController.setLoading(false);
      print(
          '✅ ${finalContacts.length} contacts chargés (${onyfastPhones.length} avec OnyFast)');
    } catch (e) {
      print('❌ Erreur chargement: $e');
      cacheController.setError('Impossible d\'accéder aux contacts: $e');
    }

    print('🏁 === FIN chargement complet ===');
  }

  // Recherche dans les données en cache
  Future<void> _searchContacts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _loadFromCache();
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    await Future.delayed(Duration(milliseconds: 150));

    final allContacts = cacheController.cachedOnyfastContacts;
    final searchResults = allContacts.where((contact) {
      final name = contact['name']?.toString().toLowerCase() ?? '';
      final phoneName = contact['phone_name']?.toString().toLowerCase() ?? '';
      final onyfastName =
          contact['onyfast_name']?.toString().toLowerCase() ?? '';
      final phone = contact['phone']?.toString().toLowerCase() ?? '';
      final email = contact['email']?.toString().toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();

      return name.contains(searchQuery) ||
          phoneName.contains(searchQuery) ||
          onyfastName.contains(searchQuery) ||
          phone.contains(searchQuery) ||
          email.contains(searchQuery);
    }).toList();

    setState(() {
      filteredContacts = searchResults;
      isSearching = false;
      hasMoreData = false; // Pas de pagination en mode recherche
    });

    print('🔍 Recherche "$query": ${searchResults.length} résultats');
  }

  // Pull to refresh - force le rechargement
  Future<void> _refreshContacts() async {
    print('🔄 Pull to refresh - rechargement forcé');
    cacheController.forceReload();
    await _loadPhoneContactsWithOnyfast();
  }

  // Sélection d'un contact - MODIFIÉ pour gérer tous les contacts
  void _selectContact(Map<String, dynamic> contact) {
    print('✅ Contact sélectionné: ${contact['name']}');

    // Vérifier si le contact a un numéro de téléphone
    if (contact['phone'] == null || contact['phone'].toString().isEmpty) {
      SnackBarService.warning(
        'Ce contact n\'a pas de numéro de téléphone',
        
     
      );
      return;
    }

    final contactToPass = {
      'id': contact['id'],
      'name': contact['name'],
      'phone': contact['phone'],
      'display_phone': contact['phone_display'],
      'email': contact['email'] ?? '',
      'avatar': contact['avatar'],
      'is_online': contact['is_online'] ?? false,
      'last_seen': contact['last_seen'],
      'created_at': contact['created_at'],
      'phone_name': contact['phone_name'],
      'onyfast_name': contact['onyfast_name'],
      'has_phone': true,
      'has_onyfast': contact['has_onyfast'] ?? false,
    };

    String message = contact['has_onyfast'] == true
        ? '${contact['name']} (Compte OnyFast) sélectionné'
        : '${contact['name']} sélectionné';

    // Get.snackbar(
    //   'Contact sélectionné',
    //   message,
    //   snackPosition: SnackPosition.TOP,
    //   backgroundColor: contact['has_onyfast'] == true
    //       ? AppColorModel.Bluecolor242.withOpacity(0.9)
    //       : Colors.grey.withOpacity(0.9),
    //   colorText: Colors.white,
    //   duration: Duration(milliseconds: 600),
    //   margin: EdgeInsets.all(8),
    // );

    Future.delayed(Duration(milliseconds: 100), () {
      Get.off(() => SendMoneyPage(), arguments: contactToPass);
    });
  }

  String _formatPhoneForDisplay(String phone) {
    if (phone.isEmpty) return phone;
    if (!phone.startsWith('+')) return '+$phone';
    return phone;
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    AppSettingsController.to.setInactivity(true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorModel.WhiteColor,
      appBar: AppBar(
        backgroundColor: AppColorModel.Bluecolor242,
        title: Text(
          'TOUS LES CONTACTS',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColorModel.WhiteColor,
          ),
        ),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
        elevation: 0,
        actions: [
          // Indicateur de cache
          Obx(() => cacheController.isDataLoaded
              ? Padding(
                  padding: EdgeInsets.only(right: 12.dp),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.dp, vertical: 4.dp),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12.dp),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cached, color: Colors.white, size: 14.dp),
                        ],
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink()),
        ],
      ),
      body: Column(
        children: [
          // En-tête
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.dp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Tous vos contacts',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Obx(() => cacheController.isDataLoaded
                        ? Padding(
                            padding: EdgeInsets.only(left: 8.dp),
                            child: Icon(Icons.check_circle,
                                color: Colors.green, size: 18.dp),
                          )
                        : SizedBox.shrink()),
                  ],
                ),
                SizedBox(height: 6.dp),
                Text(
                  'Les contacts avec compte OnyFast sont en surbrillance',
                  style:
                      TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
                ),
                Obx(() => cacheController.lastLoadTime != null
                    ? Padding(
                        padding: EdgeInsets.only(top: 4.dp),
                        child: Text(
                          'Dernière mise à jour: ${cacheController.getTimeSinceLastUpdate()}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : SizedBox.shrink()),
              ],
            ),
          ),

          // Barre de recherche
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.dp),
            child: TextField(
              controller: searchController,
              onChanged: (query) {
                Future.delayed(Duration(milliseconds: 300), () {
                  if (searchController.text == query) {
                    _searchContacts(query);
                  }
                });
              },
              decoration: InputDecoration(
                hintText: 'Rechercher un contact',
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                suffixIcon: isSearching
                    ? Padding(
                        padding: EdgeInsets.all(12.dp),
                        child: SizedBox(
                          width: 16.dp,
                          height: 16.dp,
                          child: CupertinoActivityIndicator(
                            color: AppColorModel.Bluecolor242,
                          ),
                        ),
                      )
                    : (searchController.text.isNotEmpty
                        ? IconButton(
                            icon:
                                Icon(Icons.clear, color: Colors.grey.shade500),
                            onPressed: () {
                              searchController.clear();
                              _searchContacts('');
                            },
                          )
                        : null),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.dp),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.dp, vertical: 12.dp),
              ),
            ),
          ),

          SizedBox(height: 20.dp),

          // Liste des contacts
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshContacts,
              color: AppColorModel.Bluecolor242,
              child: _buildContactsList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList() {
    return Obx(() {
      // Afficher le loader seulement si pas de données en cache
      if (cacheController.isLoading && !cacheController.isDataLoaded) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoActivityIndicator(color: AppColorModel.Bluecolor242),
              SizedBox(height: 16.dp),
              Text(
                'Chargement des contacts...',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }

      if (cacheController.errorMessage.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 64.dp, color: Colors.red.shade300),
              SizedBox(height: 16.dp),
              Text(
                cacheController.errorMessage,
                style: TextStyle(fontSize: 16.sp, color: Colors.red.shade600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.dp),
              ElevatedButton(
                onPressed: _refreshContacts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorModel.Bluecolor242,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.dp)),
                ),
                child: Text('Réessayer', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }

      if (filteredContacts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                searchController.text.isNotEmpty
                    ? Icons.search_off
                    : Icons.contact_phone_outlined,
                size: 64.dp,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 16.dp),
              Text(
                searchController.text.isNotEmpty
                    ? 'Aucun résultat pour "${searchController.text}"'
                    : 'Aucun contact trouvé dans votre téléphone',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.dp),
              Text(
                searchController.text.isNotEmpty
                    ? 'Essayez avec un autre terme'
                    : 'Vérifiez les autorisations d\'accès aux contacts',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: filteredContacts.length + (isLoadingMore ? 1 : 0),
        padding: EdgeInsets.symmetric(horizontal: 20.dp),
        separatorBuilder: (context, index) {
          if (index >= filteredContacts.length) return SizedBox.shrink();
          return Divider(
              height: 1.dp, color: Colors.grey.shade200, indent: 72.dp);
        },
        itemBuilder: (context, index) {
          if (index >= filteredContacts.length) {
            return _buildLoadingMoreIndicator();
          }
          final contact = filteredContacts[index];
          return _buildContactItem(contact);
        },
      );
    });
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: EdgeInsets.all(16.dp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.dp,
            height: 20.dp,
            child: CupertinoActivityIndicator(
              color: AppColorModel.Bluecolor242,
            ),
          ),
          SizedBox(width: 12.dp),
          Text(
            'Chargement...',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(Map<String, dynamic> contact) {
    final name = contact['name'] ?? contact['phone_name'] ?? 'Nom inconnu';
    final phone = contact['phone_display'] ?? contact['phone'] ?? '';
    final hasOnyfast = contact['has_onyfast'] ?? false;
    final isOnline = contact['is_online'] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: hasOnyfast ? AppColorModel.Bluecolor242.withOpacity(0.05) : null,
        borderRadius: hasOnyfast ? BorderRadius.circular(8.dp) : null,
        border: hasOnyfast
            ? Border.all(
                color: AppColorModel.Bluecolor242.withOpacity(0.2), width: 1)
            : null,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          vertical: 8.dp,
          horizontal: hasOnyfast ? 12.dp : 0,
        ),
        leading: Stack(
          children: [
            _buildAvatar(contact),
            if (hasOnyfast)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16.dp,
                  height: 16.dp,
                  decoration: BoxDecoration(
                    color: AppColorModel.Bluecolor242,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 10.dp,
                  ),
                ),
              ),
            if (isOnline && hasOnyfast)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12.dp,
                  height: 12.dp,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: hasOnyfast ? FontWeight.w600 : FontWeight.w500,
            color: hasOnyfast ? AppColorModel.Bluecolor242 : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (phone.isNotEmpty)
              Text(
                _formatPhoneForDisplay(phone),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: hasOnyfast
                      ? AppColorModel.Bluecolor242.withOpacity(0.8)
                      : Colors.grey.shade600,
                ),
              ),
            Text(
              hasOnyfast
                  ? 'Compte OnyFast • Appuyez pour transférer'
                  : phone.isNotEmpty
                      ? 'Appuyez pour transférer'
                      : 'Aucun numéro de téléphone',
              style: TextStyle(
                fontSize: 12.sp,
                color: hasOnyfast
                    ? AppColorModel.Bluecolor242
                    : phone.isNotEmpty
                        ? Colors.grey.shade500
                        : Colors.red.shade400,
                fontStyle: FontStyle.italic,
                fontWeight: hasOnyfast ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasOnyfast)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.dp, vertical: 4.dp),
                decoration: BoxDecoration(
                  color: AppColorModel.Bluecolor242,
                  borderRadius: BorderRadius.circular(12.dp),
                ),
                child: Text(
                  'OnyFast',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            SizedBox(width: 8.dp),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.dp,
              color: hasOnyfast
                  ? AppColorModel.Bluecolor242
                  : Colors.grey.shade400,
            ),
          ],
        ),
        onTap: () => _selectContact(contact),
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> contact) {
    final imageUrl = contact['avatar'];
    final name = contact['name'] ?? 'U';
    final hasOnyfast = contact['has_onyfast'] ?? false;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 24.dp,
        backgroundImage: NetworkImage(imageUrl),
        onBackgroundImageError: (exception, stackTrace) {
          print('Erreur chargement avatar: $exception');
        },
        backgroundColor: hasOnyfast
            ? AppColorModel.Bluecolor242.withOpacity(0.1)
            : Colors.grey.shade200,
      );
    }

    final initials = name
        .split(' ')
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join('');

    return CircleAvatar(
      radius: 24.dp,
      backgroundColor: hasOnyfast
          ? AppColorModel.Bluecolor242.withOpacity(0.1)
          : Colors.grey.shade200,
      child: Text(
        initials.isNotEmpty ? initials : 'U',
        style: TextStyle(
          color: hasOnyfast ? AppColorModel.Bluecolor242 : Colors.grey.shade600,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
