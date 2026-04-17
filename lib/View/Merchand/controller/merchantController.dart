import 'package:get/get.dart';

class MerchantController extends GetxController {
  var selectedCategory = 'Tous'.obs;
  var searchQuery = ''.obs;

  final List<String> categories = [
    'Tous', 'Restaurants', 'Mode', 'Électronique', 'Santé', 'Services'
  ];

  final List<Map<String, String>> merchants = [
    {'name': 'La Mandarine', 'category': 'Restaurants'},
    {'name': 'Le Bouche-à-Oreille', 'category': 'Restaurants'},
    {'name': 'Brazzaville Chic', 'category': 'Mode'},
    {'name': 'Maison Elegance PNR', 'category': 'Mode'},
    {'name': 'TechZone Mfoa', 'category': 'Électronique'},
    {'name': 'Innova Électronique', 'category': 'Électronique'},
    {'name': 'Pharmacie du Marché Total', 'category': 'Santé'},
    {'name': 'Centre Médical Nganga Lingolo', 'category': 'Santé'},
    {'name': 'Cyber King Makélékélé', 'category': 'Services'},
    {'name': 'Express Nettoyage Poto-Poto', 'category': 'Services'},
  ];

  // 🧠 Filtrage par catégorie + recherche
  List<Map<String, String>> get filteredMerchants {
    return merchants.where((merchant) {
      final matchesCategory = selectedCategory.value == 'Tous' || merchant['category'] == selectedCategory.value;
      final matchesSearch = merchant['name']!
          .toLowerCase()
          .contains(searchQuery.value.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList()
      ..sort((a, b) => a['name']!.compareTo(b['name']!));
  }

  // 🔠 Groupement alphabétique
  Map<String, List<Map<String, String>>> get groupedMerchants {
    final Map<String, List<Map<String, String>>> grouped = {};
    for (var merchant in filteredMerchants) {
      final letter = merchant['name']![0].toUpperCase();
      if (!grouped.containsKey(letter)) {
        grouped[letter] = [];
      }
      grouped[letter]!.add(merchant);
    }
    final sortedKeys = grouped.keys.toList()..sort();
    return {for (var k in sortedKeys) k: grouped[k]!};
  }
}
