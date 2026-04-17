import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:onyfast/Controller/features/features_controller.dart';
import 'package:onyfast/Services/recharge_dercharge.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import 'package:onyfast/utils/testInternet.dart';
import 'package:onyfast/verificationcode.dart';
import 'package:onyfast/Widget/alerte.dart';

import '../../Color/app_color_model.dart';
import '../Notification/notification.dart';

class RechargeCartePage extends StatefulWidget {
  const RechargeCartePage({super.key});

  @override
  _RechargeCartePageState createState() => _RechargeCartePageState();
}

class _RechargeCartePageState extends State<RechargeCartePage> {
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController montantController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isVerifying = false;

  final List<int> _quickAmounts = [1000, 2000, 5000, 10000, 20000, 50000];

  // Variables pour les arguments avec valeurs par défaut
  String cardID = '';
  String cardNumber = '';

  @override
  void initState() {
    super.initState();
    // Récupération sécurisée des arguments
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      cardID = arguments['cardID']?.toString() ?? '';
      cardNumber = arguments['cardNumber']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    numeroController.dispose();
    montantController.dispose();
    super.dispose();
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir un numéro de téléphone';
    }
    if (value.length < 8) {
      return 'Le numéro doit contenir au moins 8 chiffres';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Le numéro ne doit contenir que des chiffres';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir un montant';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Montant invalide';
    }
    if (amount < 100) {
      // Corrigé: minimum 100 FCFA au lieu de 1
      return 'Le montant minimum est de 100 FCFA';
    }
    if (amount > 2000000) {
      // Corrigé: cohérence avec le message d'erreur
      return 'Le montant maximum est de 2 000 000 FCFA';
    }
    return null;
  }

  Future<void> _processRecharge() async {
    if (!_formKey.currentState!.validate()) return;

    // Vérification que les données de carte sont disponibles
    if (cardID.isEmpty || cardNumber.isEmpty) {
      _showErrorDialog('Données de carte manquantes');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final montant = montantController.text;
      final token = GetStorage().read('token');

      if (token == null) {
        _showErrorDialog('Session expirée, veuillez vous reconnecter');
        return;
      }

      final result = await RechargeDechargeService.rechargeCarte(
        cardNumber: cardID,
        last4Digits: cardNumber,
        amount: montant,
        token: token,
      );

      if (result != null && result['message'] != null) {
        Get.back();
        SnackBarService.success(result['message']);
      } else {
        // SnackBarService.error(result??);
      }
    } catch (e) {
      debugPrint('Erreur recharge: $e');
      _showErrorDialog('Erreur lors de la recharge. Veuillez réessayer.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle, color: Colors.green, size: 8.w),
          ),
          title: Text(
            'Recharge Réussie',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Votre recharge de ${montantController.text} FCFA a été effectuée avec succès sur la carte ID: $cardID',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: globalColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Ferme le dialog
                  Navigator.of(context).pop(); // Retour à l'écran précédent
                  Navigator.of(context).pop(); // Retour à l'écran d'avant
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error, color: Colors.red, size: 8.w),
          ),
          title: Text(
            'Erreur',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _setQuickAmount(int amount) {
    montantController.text = amount.toString();
  }

  Widget _buildQuickAmountGrid(bool isSmallScreen, bool isTablet) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : (isSmallScreen ? 2 : 3),
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 1.h,
        childAspectRatio: isTablet ? 2.5 : (isSmallScreen ? 2.2 : 2.0),
      ),
      itemCount: _quickAmounts.length,
      itemBuilder: (context, index) {
        final amount = _quickAmounts[index];
        return InkWell(
          onTap: () => _setQuickAmount(amount),
          child: Container(
            decoration: BoxDecoration(
              color: globalColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: globalColor.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                '${NumberFormat('#,##0', 'fr_FR').format(double.tryParse(amount.toString()) ?? 0.0).replaceAll(',', ' ')} FCFA',
                // '${amount.toString()} FCFA',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12.sp : 10.sp,
                  fontWeight: FontWeight.w600,
                  color: globalColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF17338D),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(
          "Recharge Carte",
          style: TextStyle(
            fontSize: isSmallScreen ? 16.sp : 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColorModel.WhiteColor,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: NotificationWidget(),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 10.w : 6.w,
            vertical: isSmallScreen ? 3.h : 4.h,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 600 : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info de la carte
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: globalColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: globalColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.credit_card, color: globalColor, size: 6.w),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Carte sélectionnée',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'ID: $cardID',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 4.h),

                // Champ montant
                Text(
                  'Montant à recharger',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14.sp : 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 1.h),
                TextFormField(
                   inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(9),
                                    ],
                  controller: montantController,
                  keyboardType: TextInputType.number,
                  validator: _validateAmount,
                  decoration: InputDecoration(
                    hintText: 'Entrez le montant',
                    suffixText: 'FCFA',
                    prefixIcon:
                        Icon(Icons.mobile_friendly_rounded, color: globalColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: globalColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),

                SizedBox(height: 3.h),

                // Montants rapides
                Text(
                  'Montants rapides',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14.sp : 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 2.h),
                _buildQuickAmountGrid(isSmallScreen, isTablet),

                SizedBox(height: 5.h),

                // Bouton de validation
                Container(
                  width: double.infinity,
                  height: isSmallScreen ? 7.h : 6.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: (_isLoading || _isVerifying)
                        ? null
                        : LinearGradient(
                            colors: [globalColor, globalColor.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    boxShadow: (_isLoading || _isVerifying)
                        ? null
                        : [
                            BoxShadow(
                              color: globalColor.withOpacity(0.4),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_isLoading || _isVerifying)
                          ? Colors.grey
                          : Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: (_isLoading || _isVerifying)
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;

                            setState(() => _isVerifying = true);

                            bool isConnected = await hasInternetConnection();

                    if (isConnected) {
                      print('Connexion Internet disponible');
                    } else {
                      setState(() => _isVerifying = false);
                      SnackBarService.error('Pas de connexion Internet');
                      return;
                    }

       final service = FeaturesService();

      // if (numero.startsWith('06')) {
      //   print('📊📊 $numero');
      final isActive = await service.isFeatureActive(AppFeature.depotWalletCarte);

        if (isActive) {
          print('✅ La recharge Carte  est disponible');
        } else {
          Get.back();
                   setState(() => _isVerifying = false);

          SnackBarService.error('❌ Pour des raisons de maintenance, ce service est momentainément suspendu. Nos équipes travaillent d\'arrache-pied pour son rétablissement.\nVeuillez réessayer plus tard.');

          return;
        }
      // } else {
      //   final isActive =
      //       await service.isFeatureActive(AppFeature.rechargeAirtelMoney);
      //   print('kkkk $isActive');

      //   if (isActive) {
      //     print('✅ La recharge Airtel Momey est disponible');
      //   } else {
      //     Get.back();
      //     SnackBarService.error('❌ La recharge Airtel Money est désactivée');

      //     return;
      //   }


                            try {
                              CodeVerification().show(context, () async {
                                setState(() => _isVerifying = false);
                                await _processRecharge();
                              });

                              setState(() => _isVerifying = false);
                            } catch (e) {
                              debugPrint('Erreur vérification: $e');
                              setState(() => _isVerifying = false);
                              _showErrorDialog(
                                  'Erreur lors de la vérification');
                            }
                          },
                    child: (_isLoading || _isVerifying)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: isSmallScreen ? 5.w : 4.w,
                                height: isSmallScreen ? 5.w : 4.w,
                                child: CupertinoActivityIndicator(
                                  color: Colors.white,
                                  radius: 15,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                _isVerifying
                                    ? "Vérification en cours..."
                                    : "Traitement en cours...",
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14.sp : 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send, size: isSmallScreen ? 5.w : 4.w),
                              SizedBox(width: 2.w),
                              Text(
                                "Valider la recharge",
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 15.sp : 13.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                SizedBox(height: 3.h),

                // Note de sécurité
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: Colors.green[700],
                        size: isSmallScreen ? 4.w : 3.w,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Vos transactions sont sécurisées et cryptées',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontSize: isSmallScreen ? 11.sp : 9.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
