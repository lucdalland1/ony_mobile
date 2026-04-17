import 'dart:collection';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onyfast/Api/user_inscription.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/Controller/%20manage_cards_controller_v2.dart';
import 'package:onyfast/Controller/RecenteTransaction/recenttransactcontroller.dart';
import 'package:onyfast/Controller/merchant/merchantController.dart';
import 'package:onyfast/Controller/merchant/paiementmerchantcontroller.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Widget/dialog.dart';
import 'package:onyfast/model/merchant/merchant.dart';
import 'package:onyfast/verificationcode.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class MerchantPage extends StatelessWidget {
  final MerchantController controller = Get.put(MerchantController());
  final PaiementController paiementController = Get.put(PaiementController());

  MerchantPage({super.key});

  @override
  Widget build(BuildContext context) {
    controller.loadMerchants();

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                color: Colors.white),
          ),
          centerTitle: true,
          title: Text('Marchands',
              style: TextStyle(
                  color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
          backgroundColor: globalColor,
          elevation: 0,
        ),
        body: GestureDetector(
          onTap: () {},
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoActivityIndicator(color: globalColor),
                    const SizedBox(height: 16),
                     Text('Chargement des marchands...',style: TextStyle(
                      fontSize: 12.sp
                    ),),
                  ],
                ),
              );
            }

            final groupedMerchants =
                _groupMerchantsByLetter(controller.filteredMerchants);

            return RefreshIndicator(
              onRefresh: () async {
                await controller.loadMerchants();
              },
              color: globalColor,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔍 Barre de recherche améliorée
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: controller.updateSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Rechercher un marchand...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon:
                              Icon(Icons.search, color: Colors.grey[600]),
                          suffixIcon:
                              Obx(() => controller.searchQuery.value.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear,
                                          color: Colors.grey[600]),
                                      onPressed: () =>
                                          controller.updateSearchQuery(''),
                                    )
                                  : SizedBox(width: 0, height: 0)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🎯 Filtres par catégorie améliorés
                    SizedBox(
                      height: 45,
                      child: Obx(() => ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.availableCategories.length,
                            itemBuilder: (context, index) {
                              final category =
                                  controller.availableCategories[index];
                              final isSelected =
                                  category == controller.selectedCategory.value;

                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  label: Text(category,style: TextStyle(
                                    fontSize: 9.sp
                                  ),),
                                  selected: isSelected,
                                  onSelected: (_) => controller
                                      .updateSelectedCategory(category),
                                  selectedColor: globalColor.withOpacity(0.1),
                                  backgroundColor: Colors.grey[100],
                                  checkmarkColor: globalColor,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? globalColor
                                        : Colors.grey[700],
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                  side: BorderSide(
                                    color: isSelected
                                        ? globalColor
                                        : Colors.grey[300]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              );
                            },
                          )),
                    ),
                    const SizedBox(height: 20),

                    // 📊 Statistiques rapides
                    if (controller.filteredMerchants.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              globalColor.withOpacity(0.1),
                              globalColor.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.store, color: globalColor,size: 10.sp,),
                            SizedBox(width: 12),
                            Text(
                              '${_getTotalMerchants(groupedMerchants)} marchands disponibles',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: globalColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 🏪 Liste alphabétique améliorée
                    Expanded(
                      child: groupedMerchants.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              itemCount: groupedMerchants.entries.length,
                              itemBuilder: (context, index) {
                                final entry =
                                    groupedMerchants.entries.elementAt(index);
                                final letter = entry.key;
                                final merchantsGroup = entry.value;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // En-tête alphabétique
                                    Container(
                                      // margin: const EdgeInsets.symmetric(vertical: 8.0),
                                      // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      // decoration: BoxDecoration(
                                      //   color: globalColor.withOpacity(0.1),
                                      //   // borderRadius: BorderRadius.circular(8),
                                      // ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 25,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              color: globalColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                letter,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 8.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '${merchantsGroup.length} marchand${merchantsGroup.length > 1 ? 's' : ''}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 10.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Liste des marchands
                                    ...merchantsGroup.map((merchant) =>
                                        _buildMerchantCard(context, merchant)),
                                    const SizedBox(height: 8),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ));
  }

  Widget _buildMerchantCard(BuildContext context, Merchant merchant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: globalColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            FontAwesomeIcons.store,
            color: globalColor,
            size: 20,
          ),
        ),
        title: Text(
          merchant.nom,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 9.sp,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.category_outlined,
                    size: 14, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  merchant.categorie,
                  style: TextStyle(color: Colors.grey[600], fontSize: 8.sp),
                ),
              ],
            ),
            SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 14, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  merchant.telephone,
                  style: TextStyle(color: Colors.grey[600], fontSize: 9.sp),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: globalColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.payment,
            color: globalColor,
            size: 20,
          ),
        ),
        onTap: () => _showTransferOptions(context, merchant),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.storeSlash,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Aucun marchand trouvé',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Essayez de modifier vos critères de recherche',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  int _getTotalMerchants(Map<String, List<Merchant>> groupedMerchants) {
    return groupedMerchants.values
        .fold(0, (sum, merchants) => sum + merchants.length);
  }

  Map<String, List<Merchant>> _groupMerchantsByLetter(
      RxMap<String, List<Merchant>> data) {
    final SplayTreeMap<String, List<Merchant>> sorted = SplayTreeMap();
    data.forEach((key, value) {
      sorted[key] = value;
    });
    return sorted;
  }

  void _showTransferOptions(BuildContext context, Merchant merchant) {
    final montantController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 4.w,
            right: 4.w,
            top: 2.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 2.h,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle de la modal
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Gap(2.h),

                // En-tête avec info marchand
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: globalColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: globalColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          FontAwesomeIcons.store,
                          color: globalColor,
                          size: 10.sp,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              merchant.nom,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10.sp,
                                color: globalColor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              merchant.telephone,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 9.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(2.h),

                // Champ montant amélioré
                TextFormField(
                  style: TextStyle(fontSize: 10.sp),
                  controller: montantController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: InputDecoration(
                    labelStyle:TextStyle(
                      fontSize: 9.sp
                    ),
                    labelText: 'Montant à payer',
                    hintText: '0.00',
                    prefixIcon:
                        Icon(Icons.payments_outlined, color: globalColor),
                    suffixText: 'FCFA',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: globalColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez saisir un montant';
                    }
                    final number = double.tryParse(value);
                    if (number == null || number <= 0) {
                      return 'Montant invalide';
                    }
                    if (number < 100) {
                      return 'Montant minimum: 100 FCFA';
                    }
                    return null;
                  },
                ),
                Gap(3.h),

                // Bouton de paiement avec état de chargement
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: paiementController.isLoading.value
                            ? null
                            : () {
                                final ManageCardsController controller =
                                    Get.find();
                                final card = controller.currentCard;
                                if (card == null) {
                                  Get.back();
                                  Get.dialog(
                                    AppDialog(
                                      title: "Payement indisponible",
                                      body:
                                          'Pour payer ce marchand, ajoutez et activez une carte dans votre espace Cartes, puis réessayez.',
                                      actions: [
                                        AppDialogAction(
                                          label: "OK",
                                          isDestructive: true,
                                          onPressed: () => Get.back(),
                                        ),
                                      ],
                                    ),
                                  );
                                  return;
                                }

                                if (card.isActive != true) {
                                  Get.back();
                                  Get.dialog(
                                    AppDialog(
                                      title: "Payement indisponible",
                                      body:
                                          'Veuillez activer votre carte pour effectuer des opérations.',
                                      actions: [
                                        AppDialogAction(
                                          label: "OK",
                                          isDestructive: true,
                                          onPressed: () => Get.back(),
                                        ),
                                      ],
                                    ),
                                  );
                                  //  _showComingSoon('Payement indisponible', 'Veuillez activer votre carte pour effectuer des opérations.');
                                  return;
                                }
                                CodeVerification().show(
                                    context,
                                    () => _processPaiement(context, formKey,
                                        montantController, merchant.telephone));
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: globalColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.dp),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                        child: paiementController.isLoading.value
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CupertinoActivityIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Traitement en cours...'),
                                ],
                              )
                            :  Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send, size: 20),
                                  SizedBox(width: 8),
                                  Text('Effectuer le paiement',
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                      ),
                    )),
                Gap(1.h),

                // Bouton annuler
                TextButton(
                  onPressed: paiementController.isLoading.value
                      ? null
                      : () => Navigator.pop(context),
                  child: Text(
                    'Annuler',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11.sp,
                    ),
                  ),
                ),
                Gap(1.h),
              ],
            ),
          ),
        );
      },
    );
  }

  void _processPaiement(BuildContext context, GlobalKey<FormState> formKey,
      TextEditingController montantController, String numeroMerchant) {
    // Get.back();

    if (formKey.currentState!.validate()) {
      final montant = montantController.text.trim();

      // Confirmation avant paiement
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Confirmer le paiement'),
          content: Text(
              'Vous êtes sur le point de payer $montant FCFA à ce marchand. Voulez-vous continuer ?'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              isDestructiveAction: false,
              child: const Text('Confirmer',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la confirmation
                Navigator.of(context).pop(); // Ferme la modal de paiement

                paiementController.envoyerPaiement(
                  toTelephone: numeroMerchant,
                  montant: montant,
                  typeTransactionId: 10,
                );
              },
            ),
          ],
        ),
      );
    }

    AuthController connexion = Get.find();
    connexion.fetchSolde();
  }
}
