import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/Controller/Abonnement/abonnementcontroller.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/Widget/dialog.dart';
import 'package:onyfast/model/abonnement/abonnementModel.dart';

class SubscriptionComparisonPage extends StatefulWidget {
  const SubscriptionComparisonPage({super.key});

  @override
  State<SubscriptionComparisonPage> createState() =>
      _SubscriptionComparisonPageState();
}

class _SubscriptionComparisonPageState
    extends State<SubscriptionComparisonPage> {
  final AbonnementController controller = Get.find<AbonnementController>();
  @override
  void initState() {
    super.initState();
    controller.compte.value = 0;
  }

  @override
  void dispose() {
    controller.compte.value = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Obx(() {
          return Text(
            ApiEnvironmentController.to.isProd.value
                ? "Abonnements"
                : "Vous êtes en mode TEST",
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColorModel.WhiteColor,
            ),
          );
        }),
        backgroundColor: Colors.indigo.shade900,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CupertinoActivityIndicator(
              color: Colors.indigo.shade900,
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 50, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchAbonnements(),
                  child: const Text("Réessayer"),
                ),
              ],
            ),
          );
        }

        if (controller.abonnements.isEmpty) {
          return const Center(child: Text("Aucun abonnement disponible"));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: _buildComparisonTable(controller.abonnements.toList()),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildComparisonTable(List<Abonnement> abonnements) {
    return Table(
      columnWidths: {
        0: const FlexColumnWidth(2),
        for (int i = 1; i <= abonnements.length; i++)
          i: const FlexColumnWidth(1.2),
      },
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        // En-tête du tableau
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFE8EAF6)),
          children: [
             Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Fonctionnalité',
                style: TextStyle(fontWeight: FontWeight.bold,
                fontSize: 12.sp),
              ),
            ),
            for (var abonnement in abonnements)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      abonnement.nom,
                      style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 12.sp),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      abonnement.prix.mensuel,
                      style:  TextStyle(fontSize: 9.sp),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),

        // Plafond mensuel
        _buildTableRow(
          'Plafond mensuel',
          abonnements
              .map((a) => a.caracteristiques?.plafonds?.mensuel ?? '-')
              .toList(),
        ),

        // Objectifs
        _buildTableRow(
          'Objectifs',
          abonnements.map((a) => _getObjectifsDisplay(a)).toList(),
        ),

        // Support client
        _buildTableRow(
          'Support client',
          abonnements
              .map((a) => a.avantages?.services?.support ?? '-')
              .toList(),
        ),

        // Conseiller dédié
        _buildTableRow(
          'Conseiller dédié',
          abonnements.map((a) => _getConseillerDedieDisplay(a)).toList(),
        ),

        // Popularité (si disponible)
        if (abonnements.any((a) => a.popularite != null))
          _buildTableRow(
            'Popularité',
            abonnements.map((a) => _getPopulariteDisplay(a)).toList(),
          ),

        // Idéal pour
        _buildTableRow(
          'Idéal pour',
          abonnements.map((a) => a.bestFor ?? '-').toList(),
          isLastRow: true,
        ),
      ],
    );
  }

  TableRow _buildTableRow(String title, List<String> values,
      {bool isLastRow = false}) {
    return TableRow(
      decoration: isLastRow ? BoxDecoration(color: Colors.grey.shade50) : null,
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: 'Idéal pour' != title
                ? Text(
                    title,
                    style: TextStyle(
                      fontWeight:
                          isLastRow ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 9.sp
                    ),
                  )
                : GestureDetector(
                    onTap: () async {
                      print('✅✅✅✅✅✅ clicked ${controller.compte.value}');
                      print(ApiEnvironmentController.to.isProd.value
                          ? "PROD"
                          : "TEST");
                      print(ApiEnvironmentController.to.baseUrl);

                      if (controller.compte.value == 30) {
                        await ApiEnvironmentController.to.setIsProd(
                            !ApiEnvironmentController.to.isProd.value);
                        showEnvironmentDialog();
                      }
                      // setState(() {
                      controller.compte.value = controller.compte.value == 30
                          ? 0
                          : controller.compte.value + 1;
                      // });
                    },
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12.sp
                        // decoration: TextDecoration.underline, // optionnel
                      ),
                    ),
                  )),
        for (var value in values)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                value,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: title == 'Idéal pour' ? 10.sp : 12.sp,
                  fontWeight: isLastRow ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _getConseillerDedieDisplay(Abonnement abonnement) {
    final conseiller = abonnement.avantages?.services?.conseillerDedie;
    if (conseiller == null) return '-';

    if (conseiller is bool) {
      return conseiller ? '✓' : '✗';
    } else if (conseiller is int) {
      return conseiller == 1 ? '✓' : '✗';
    }
    return '-';
  }

  String _getObjectifsDisplay(Abonnement abonnement) {
    final objectifs = abonnement.caracteristiques?.objectifs;
    if (objectifs == null) return '-';

    if (objectifs is int) {
      return objectifs.toString();
    } else if (objectifs is String) {
      return objectifs;
    }
    return '-';
  }

  String _getPopulariteDisplay(Abonnement abonnement) {
    if (abonnement.popularite != null) {
      return '${abonnement.popularite!.etoiles}⭐';
    }
    return '-';
  }
}

void showEnvironmentDialog() {
  final env = ApiEnvironmentController.to.isProd.value ? "PROD" : "TEST";

  // Dialog simple avec un bouton OK
  Get.dialog(
    AppDialog(
      title: "Bravo",
      body: "Nous sommes sur $env",
      actions: [
        AppDialogAction(
          label: "OK",
          isDestructive: true,
          onPressed: () => Get.back(),
        ),
      ],
    ),
  );

  // if (Platform.isIOS) {
  //   Get.dialog(
  //     CupertinoAlertDialog(
  //       title: const Text("Bravo"),
  //       content: Text("Nous sommes sur $env"),
  //       actions: [
  //         CupertinoDialogAction(
  //           onPressed: () => Get.back(),
  //           child: const Text("OK"),
  //         ),
  //       ],
  //     ),
  //   );
  // } else {
  //   Get.defaultDialog(
  //     title: "Bravo",
  //     middleText: "Nous sommes sur $env",
  //     textConfirm: "OK",
  //     onConfirm: () => Get.back(),
  //   );
  // }
}
