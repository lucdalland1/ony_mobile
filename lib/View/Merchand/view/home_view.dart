import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/View/Merchand/model/merchand.dart';
import 'package:onyfast/Widget/container.dart';
import '../controller/merchandcontroller.dart';
import '../controller/view/select_view.dart';
import '../controller/view/transaction.dart';
import '../controller/widget/merchand_card.dart';
import '../controller/widget/serch.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _searchController = TextEditingController();
  final _merchantController = Get.put(MerchantController());

  @override
/*************  ✨ Windsurf Command ⭐  *************/
/// Initializes the state of the `_HomeViewState` widget by assigning all merchants
/// to the `filteredMerchants` list in the `MerchantController`, ensuring all merchants
/// are displayed by default.

/*******  1e9b5f0e-54be-49b8-8519-669787f47d4f  *******/
  void initState() {
    super.initState();
    _merchantController.filteredMerchants.assignAll(_merchantController.allMerchants);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  title: Text(
    'Merchand',
    style: TextStyle(
      color: AppColorModel.WhiteColor,
      fontWeight: FontWeight.bold,
    ),
  ),
  backgroundColor: AppColorModel.BlueColor,
  centerTitle: true,
  leading: IconButton(
    icon: Icon(
      Icons.arrow_back,
      color: AppColorModel.WhiteColor,
    ),
    onPressed: () {
      Navigator.of(context).pop();
    },
  ),
  actions: [
    ContainerWidget(
      height: 03.50.h,
      width: 10.w,
      child: Image.asset(
        "asset/nodification.png",
        color: AppColorModel.WhiteColor,
      ),
    ),
    const SizedBox(width: 16), 
  ],
),
      body: Column(
        children: [
          MerchantSearchBar(
            controller: _searchController,
            hintText: 'Rechercher un merchand'.tr,
            onChanged: _merchantController.filterMerchants,
          ),
          Expanded(
            child: Obx(() {
              if (_merchantController.filteredMerchants.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                itemCount: _merchantController.filteredMerchants.length,
                itemBuilder: (context, index) {
                  final merchant = _merchantController.filteredMerchants[index];
                  return MerchantCard(
                    merchant: merchant,
                    onTap: () {
                      if (merchant.type.subTypes != null) {
                        Get.to(
                          () => SubTypeSelectionView(merchantType: merchant.type),
                          transition: Transition.rightToLeft,
                        );
                      } else {
                        Get.to(
                          () => TransactionView(
                            merchantType: merchant.type,
                            subType: merchant.type.displayName,
                          ),
                          transition: Transition.rightToLeft,
                        );
                      }
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_mall_directory_outlined,
            size: 50,
            color: Colors.grey[400],
          ),
         SizedBox(height: 12.h),
           Text(
            'Aucune boutique trouvée',
            style: TextStyle(fontSize: 17.dp),
          ),
          if (_searchController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                _searchController.clear();
                _merchantController.filterMerchants('');
              },
              child: const Text('Réinitialiser la recherche'),
            ),
        ],
      ),
    );
  }
}