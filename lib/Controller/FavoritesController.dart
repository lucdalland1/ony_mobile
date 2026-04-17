import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Widget/alerte.dart';

class FavoritesController extends GetxController {
  static FavoritesController? _instance;
  final GetStorage _storage = GetStorage();

  final RxList<Map<String, dynamic>> _favorites = <Map<String, dynamic>>[].obs;
  static const String _favoritesKey = 'transaction_favorites';

  List<Map<String, dynamic>> get favorites => _favorites.value;

  static FavoritesController get instance {
    if (_instance == null) {
      _instance = FavoritesController._internal();
      Get.put(_instance!, permanent: true);
    }
    return _instance!;
  }

  FavoritesController._internal();
  factory FavoritesController() => instance;

  @override
  void onInit() {
    super.onInit();
    _loadFavorites();
  }

  void _loadFavorites() {
    try {
      final List<dynamic>? storedFavorites = _storage.read(_favoritesKey);
      if (storedFavorites != null) {
        _favorites.value = storedFavorites.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      _favorites.clear();
    }
  }

  void _saveFavorites() {
    try {
      _storage.write(_favoritesKey, _favorites.value);
    } catch (e) {
      print('❌ Erreur sauvegarde favoris: $e');
    }
  }

  void addOrUpdateFavorite({
    required String phone,
    required String name,
    String? avatar,
    String? email,
    required int userId,
  }) {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\+\-\(\)\.]'), '');

    final existingIndex = _favorites.indexWhere((favorite) {
      final favoritePhone = favorite['phone']
              ?.toString()
              .replaceAll(RegExp(r'[\s\+\-\(\)\.]'), '') ??
          '';
      return favoritePhone == cleanPhone || favorite['user_id'] == userId;
    });

    final favoriteData = {
      'user_id': userId,
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'email': email,
      'last_transaction': DateTime.now().toIso8601String(),
      'transaction_count': 1,
    };

    if (existingIndex != -1) {
      final existing = _favorites[existingIndex];
      favoriteData['transaction_count'] =
          (existing['transaction_count'] ?? 0) + 1;
      _favorites[existingIndex] = favoriteData;
    } else {
      _favorites.add(favoriteData);
    }

    _favorites.sort((a, b) {
      final countA = a['transaction_count'] ?? 0;
      final countB = b['transaction_count'] ?? 0;
      return countB.compareTo(countA);
    });

    _saveFavorites();
  }

  // NOUVELLE MÉTHODE: Supprimer un favori par index
  void removeFavorite(int index) {
    if (index >= 0 && index < _favorites.length) {
      final removed = _favorites.removeAt(index);
      _saveFavorites();
      print('🗑️ Favori supprimé: ${removed['name']}');

      SnackBarService.warning(
       title:  'Favori supprimé',
        '${removed['name']} retiré des favoris',
       
      );
    }
  }

  // NOUVELLE MÉTHODE: Supprimer un favori par userId
  void removeFavoriteByUserId(int userId) {
    final index =
        _favorites.indexWhere((favorite) => favorite['user_id'] == userId);
    if (index != -1) {
      removeFavorite(index);
    }
  }

  // NOUVELLE MÉTHODE: Vider tous les favoris avec confirmation
  void clearAllFavorites() {
    _favorites.clear();
    _saveFavorites();
    print('🗑️ Tous les favoris supprimés');

    SnackBarService.success(
      title:'Favoris supprimés',
      'Tous les favoris ont été supprimés',    
    );
  }

  List<Map<String, dynamic>> getRecentFavorites({int limit = 5}) {
    return _favorites.take(limit).toList();
  }

  String getLastTransactionTime(Map<String, dynamic> favorite) {
    final lastTransaction =
        DateTime.tryParse(favorite['last_transaction'] ?? '');
    if (lastTransaction == null) return '';

    final difference = DateTime.now().difference(lastTransaction);

    if (difference.inMinutes < 1) return 'À l\'instant';
    if (difference.inMinutes < 60) return 'Il y a ${difference.inMinutes}min';
    if (difference.inHours < 24) return 'Il y a ${difference.inHours}h';
    return 'Il y a ${difference.inDays}j';
  }
}
