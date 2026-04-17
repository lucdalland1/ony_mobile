import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onyfast/Api/fcm_token_service.dart';
import 'package:onyfast/Api/piecesjustificatif_Api/pieces_justificatif_api.dart';
import 'package:onyfast/Controller/%20manage_cards_controller_v2.dart';
import 'package:onyfast/Controller/niveau/niveau_controller.dart';
import 'package:onyfast/Services/token_service.dart';
import 'package:onyfast/View/BottomView/widgets/bank_card.dart';
import 'package:onyfast/View/BottomView/widgets/colors.dart';
import 'package:onyfast/View/BottomView/widgets/quick_actions.dart';
import 'package:onyfast/View/BottomView/widgets/recent_transactions.dart';
import 'package:onyfast/View/BottomView/widgets/section_header.dart';
import 'package:onyfast/View/BottomView/widgets/svg_background.dart';
import 'package:onyfast/View/BottomView/widgets/top_bar.dart';

import '../../Controller/history/history_activiticontroller.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {


    @override
    void initState() { 
      super.initState();
      _initializeFcm();
    }
    void _initializeFcm() async {
    final fcmService = FcmTokenService();
    await fcmService.sendTokenToServer();
    fcmService.listenTokenRefresh();
  }
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final hPad = sw > 540 ? (sw - 500) / 2 : 20.0;

    return Scaffold(
      backgroundColor: C.bg,
      body: Stack(
        children: [
          // ── Fond SVG ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SvgBackground(screenWidth: sw, screenHeight: sh),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── TopBar fixe ──
                Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 0),
                  child: const TopBar(),
                ),

                // ── Contenu scrollable ──
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      final TokenService tokenService =
                          Get.find<TokenService>();
                      final ManageCardsController cardsController =
                          Get.find<ManageCardsController>();
                      final TransactionsController transactionsController =
                          Get.find<TransactionsController>();
                      final NiveauController niveauController =
                          Get.find<NiveauController>();
                      final PiecesController piecesController =
                          Get.find<PiecesController>();

                      // Refresh session d'abord
                      await tokenService.refreshToken();

                      // Puis rafraîchir toutes les données en parallèle
                      // await Future.wait([
                      await cardsController.refreshData();
                      await cardsController.recupereTransactions();
                      await transactionsController.refreshTransactions();
                      await niveauController.fetchNiveau();
                      await piecesController.fetchPieces();
                      // ]);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Éléments avec padding
                          Padding(
                            padding: EdgeInsets.fromLTRB(hPad, 22, hPad, 0),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SectionHeader(),
                                
                                BankCard(),
                                SizedBox(height: 26),
                              ],
                            ),
                          ),

                          // Actions rapides pleine largeur
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: hPad),
                            child: const QuickActionsSection(),
                          ),

                          const SizedBox(height: 22),

                          // Transactions pleine largeur
                          RecentTransactionsSection(),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
