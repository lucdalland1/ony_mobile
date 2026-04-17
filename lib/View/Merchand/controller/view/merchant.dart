import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/View/Merchand/model/merchand.dart';
import 'package:onyfast/View/Notification/notification.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import '../../../../Color/app_color_model.dart';
import '../../../../Controller/languescontroller.dart';
import '../../../../Widget/container.dart';
import '../../../../Widget/icon.dart';
import '../merchandcontroller.dart';
import '../widget/merchand_card.dart';
import '../widget/serch.dart';
import 'select_view.dart';
import 'transaction.dart';

class Merchand extends StatefulWidget {
   Merchand ({Key? key}) : super(key: key);

  @override
  State<Merchand> createState() => _HomeViewState();
}
 void _showDialog(BuildContext context) {
    final AppController appState = Get.find<AppController>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              Gap(40),
              Text(
                appState.language == AppLanguage.french
                    ? "D'autres informations"
                    : appState.language == AppLanguage.english
                        ? 'Other information'
                        : 'Otra información',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/associercompte");
                    },
                    child: Text(
                      appState.language == AppLanguage.french
                          ? 'Associer à mon compte bancaire'
                          : appState.language == AppLanguage.english
                              ? 'Link to my bank account'
                              : 'Vincular a mi cuenta bancaria',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/parametre");
                    },
                    child: Text('Merchant',
                    ),
                  ),
                  TextButton(
                    child: Text(
                      appState.language == AppLanguage.french
                          ? 'Fermer'
                          : appState.language == AppLanguage.english
                              ? 'Close'
                              : 'Cerrar',
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

class _HomeViewState extends State<Merchand> {
  final _searchController = TextEditingController();
  final _merchantController = Get.put(MerchantController());

  @override
  void initState() {
    super.initState();
    _merchantController.filteredMerchants.assignAll(_merchantController.allMerchants);
  }

  @override
  Widget build(BuildContext context) {
      // Obtenez les dimensions de l'écran
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColorModel.Bluecolor242,
        leading: BackButton(color: Colors.white),
        title: Text("Marchand", 
          style: TextStyle(
            fontSize: 17.dp, 
            fontWeight: FontWeight.bold, 
            color: AppColorModel.WhiteColor
          ),
        ),
        centerTitle: true,
        actions: [
          NotificationWidget()
        ],
      ),
      body: Column(
        children: [
           

          MerchantSearchBar(
            controller: _searchController,
            hintText: 'Rechercher un merchand ou type...',
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
          const SizedBox(height: 16),
          const Text(
            'Aucun merchand trouvé',
            style: TextStyle(fontSize: 18),
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

