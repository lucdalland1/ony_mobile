import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:onyfast/Controller/%20manage_cards_controller_v2.dart';
import 'package:onyfast/View/BottomView/widgets/top_bar.dart';
import 'package:onyfast/View/Gerer_cartes/CardDetailPage.dart';
import 'package:onyfast/View/Gerer_cartes/gerer_mes_cartes.dart';
import 'package:onyfast/View/menuscreen.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import 'package:onyfast/verificationcode.dart';

class CardDetailPage extends StatefulWidget {
  const CardDetailPage({super.key});

  static const _bg = Color(0xFFF2F4F8);
  static const _labelColor = Color(0xFF9BA3B8);
  static const _dark = Color(0xFF1A2240);

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  @override
  Widget build(BuildContext context) {
    final ManageCardsController controller = Get.find();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: CardDetailPage._bg,
        body: Obx(() {
          final card = controller.currentCard;

          if (card == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFF2F4F8)),
            );
          }

          final bool isVirtual = card.type == CardType.virtual;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(context, card, controller),
              ),
              SliverToBoxAdapter(
                child: _buildActions(context, card, isVirtual, controller),
              ),
              SliverToBoxAdapter(
                child: _buildInfoSection(context, card),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        }),
      ),
    );
  }

  // ────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    CardData card,
    ManageCardsController controller,
  ) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
              child: Row(
                children: [
                  Container(
                    width: 9.w,
                    height: 9.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(GetPlatform.isAndroid ?  Icons.arrow_back : Icons.arrow_back_ios_new,
                          color: const Color(0xFF1A3CBF), ),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Gérer mes cartes Visa',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF1A3CBF),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    width: 9.w,
                    height: 9.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: NotificationWidget(isWhite: false),
                  ),
                  SizedBox(width: 2.dp,)
                  // GestureDetector(
                  //   onTap: (){
                  //         Scaffold.maybeOf(context)?.openEndDrawer();


                  //   },
                  //   child: const TopIcon(icon: Icons.more_vert),
                  // ),
                ],
              ),
            ),
            SizedBox(height: 1.5.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: _buildBankCard(context, card, controller),
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────
  Widget _buildBankCard(
    BuildContext context,
    CardData card,
    ManageCardsController controller,
  ) {
    return AspectRatio(
      aspectRatio: 1.75,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          image: DecorationImage(
            image: card.type == CardType.physical
                ? const AssetImage('asset/carte-onyfast-vierge.png')
                : const AssetImage('asset/carte-onyfast-virtual.png'),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B3BAD).withOpacity(0.5),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.15),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Solde total',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.80),
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 0.6.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Principal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Obx(() => Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              controller.toogle.value
                                  ? _formatBalance(card.balance)
                                  : '●●●●● F CFA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () async {
                                controller.toogle.value =
                                    !controller.toogle.value;
                                await controller.getCardBalance(card.cardID);
                              },
                              child: Container(
                                padding: EdgeInsets.all(1.8.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  controller.toogle.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.white,
                                  size: 5.w,
                                ),
                              ),
                            ),
                          ],
                        )),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────
  Widget _buildActions(
    BuildContext context,
    CardData card,
    bool isVirtual,
    ManageCardsController controller,
  ) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      child: Row(
        children: [
          if (isVirtual) ...[
            _roundBtn(
              context: context,
              icon: Icons.info_outline,
              label: 'Pan',
              onTap: () {
                CodeVerification().show(Get.context!, () async {
                  CardExternalLauncher.launchCardDetails(
                    card.cardID,
                    card.maskedCardNumber
                        .replaceAll("•", "")
                        .replaceAll(" ", ""),
                  );
                });
              },
            ),
            SizedBox(width: 6.w),
          ],
          _roundBtn(
            context: context,
            icon: Icons.settings_outlined,
            label: 'Gérer',
            onTap: () async {
              final selected = await showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  builder: (_) => Padding(
    padding: EdgeInsets.only(
      top: 2.5.h,
      left: 4.w,
      right: 4.w,
      bottom: MediaQuery.of(_).padding.bottom + 2.5.h,
    ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10.w,
                        height: 0.5.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      ListTile(
                        leading: Icon(
                          card.isActive
                              ? Icons.lock_outline
                              : Icons.lock_open_outlined,
                          color: card.isActive ? Colors.red : Colors.green,
                          size: 6.w,
                        ),
                        title: Text(
                          card.isActive
                              ? 'Bloquer ma carte'
                              : 'Débloquer ma carte',
                          style: TextStyle(
                            color: card.isActive ? Colors.red : Colors.green,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () => Navigator.pop(context, 'toggle'),
                      ),
                    ],
                  ),
                ),
              );

              if (selected == 'toggle') {
                CodeVerification().show(Get.context!, () async {
                  controller.toggleCardStatus();
                });
              }
            },
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: card.isActive
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              card.isActive ? 'ACTIVÉE' : 'BLOQUÉE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundBtn({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F8),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E6F0), width: 1),
            ),
            child: Icon(icon, color: const Color(0xFF4A5580), size: 5.5.w),
          ),
          SizedBox(height: 0.8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.sp,
              color: const Color(0xFF5A6180),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  Widget _buildInfoSection(BuildContext context, CardData card) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 2.5.h, 4.w, 0),
      child: Column(
        children: [
          _infoField(context, 'TYPE DE CARTE', _typeLabel(card)),
          SizedBox(height: 1.5.h),
          _infoField(context, 'NOM DU TITULAIRE', card.holderName),
          SizedBox(height: 1.5.h),
          _infoField(context, '4 DERNIÈRES CHIFFRES', card.cardNumber),
          SizedBox(height: 1.5.h),
            if (card.type != CardType.virtual) ...[
            
            _infoField(context, "DATE D'EXPIRATION", card.expiryDate),
          ],
        ],
      ),
    );
  }

  Widget _infoField(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 0.5.w, bottom: 0.8.h),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 8.sp,
              color: CardDetailPage._labelColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: CardDetailPage._dark,
            ),
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────
  String _typeLabel(CardData card) {
    switch (card.type) {
      case CardType.physical:
        return 'Carte physique';
      case CardType.virtual:
        return 'Carte virtuelle';
      default:
        return 'Principal';
    }
  }

  String _formatBalance(double? balance) {
    if (balance == null) return '??? F CFA';
    return '${NumberFormat('#,##0', 'fr_FR').format(balance)} F CFA';
  }
}





///////////
///
///
