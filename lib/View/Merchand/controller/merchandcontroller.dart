import 'package:get/get.dart';
import '../model/merchand.dart';

class MerchantController extends GetxController {
  // Liste complète des merchandisings
  final allMerchants = <Merchant>[
    Merchant(id: '1', name: 'Super Marché', type: MerchantType.store),
    Merchant(id: '2', name: 'Pâtisserie Fine', type: MerchantType.pastry),
    Merchant(id: '3', name: 'Grand Hôtel', type: MerchantType.hotel),
    Merchant(id: '4', name: 'Bar Lounge', type: MerchantType.bar),
  ].obs;

  // Merchandisings filtrés
  final filteredMerchants = <Merchant>[].obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    filteredMerchants.assignAll(allMerchants);
  }

  // Filtre les merchandisings par nom ou type
  void filterMerchants(String query) {
    searchQuery.value = query.toLowerCase();
    
    if (query.isEmpty) {
      filteredMerchants.assignAll(allMerchants);
      return;
    }

    filteredMerchants.assignAll(
      allMerchants.where((merchant) =>
        merchant.name.toLowerCase().contains(searchQuery.value) ||
        merchant.type.displayName.toLowerCase().contains(searchQuery.value)
      ),
    );
  }

  // Filtre les sous-types
  List<String> filterSubTypes(MerchantType type, String query) {
    final subTypes = type.subTypes ?? [];
    if (query.isEmpty) return subTypes;
    
    return subTypes.where((subType) => 
      subType.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}