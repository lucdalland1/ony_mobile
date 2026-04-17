import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:onyfast/Api/recharge_api/recharge_api.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/Controller/features/features_controller.dart';
import 'package:onyfast/Controller/numero_status_mobile_money.dart';
import 'package:onyfast/View/Epargne/epargne%20group%C3%A9/eparne_suite.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/Widget/dialog.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import 'package:onyfast/utils/testInternet.dart';

import '../../Color/app_color_model.dart';
import '../Notification/notification.dart';

class RechargePage extends StatefulWidget {
  const RechargePage({super.key});

  @override
  _RechargePageState createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  final bool _fraisCharges = false;
  bool _fraisEnChargement = true;
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController montantController = TextEditingController();
  RechargeStatusController rechargeStatusController =
      Get.put(RechargeStatusController());
  final _formKey = GlobalKey<FormState>();
  final GetStorage storage = GetStorage();

  bool _isLoading = false;

  final List<int> _quickAmounts = [1000, 2000, 5000, 10000, 20000, 50000];
  double _pourcentageAirtel = 0.0;
  double _pourcentageMtn = 0.0;
  bool _airtelDisponible = false;
  bool _mtnDisponible = false;
  Future<void> _fetchPourcentages() async {
    try {
      final airtelRes = await http.get(Uri.parse(
          '${ApiEnvironmentController.to.baseUrl}/pourcentage/airtel'));
      final mtnRes = await http.get(
          Uri.parse('${ApiEnvironmentController.to.baseUrl}/pourcentage/mtn'));

      final airtelData = jsonDecode(airtelRes.body);
      final mtnData = jsonDecode(mtnRes.body);

      if (mounted) {
        setState(() {
          if (airtelData['success'] == true) {
            _pourcentageAirtel = airtelData['pourcentage'].toDouble();
            _airtelDisponible = true;
          }
          if (mtnData['success'] == true) {
            _pourcentageMtn = mtnData['pourcentage'].toDouble();
            _mtnDisponible = true;
          }
          _fraisEnChargement = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _fraisEnChargement = false);
      print('Erreur récupération frais: $e');
    }
  }

  bool _fraisDisponiblesPourNumero() {
    final numero = numeroController.text;
    if (numero.startsWith('05') && _airtelDisponible) return true;
    if (numero.startsWith('06') && _mtnDisponible) return true;
    return false;
  }

  String _messageFraisIndisponibles() {
    final numero = numeroController.text;
    if (_fraisEnChargement) return 'Chargement des frais...';
    if (numero.startsWith('05') && !_airtelDisponible)
      return '⚠️ Les frais Airtel Money ne sont pas encore configurés. Réessayez plus tard.';
    if (numero.startsWith('06') && !_mtnDisponible)
      return '⚠️ Les frais MTN MoMo ne sont pas encore configurés. Réessayez plus tard.';
    if (!numero.startsWith('05') && !numero.startsWith('06'))
      return '⚠️ Entrez un numéro valide (05 ou 06) pour voir les frais.';
    return '';
  }

  double _getPourcentage() {
    final numero = numeroController.text;
    if (numero.startsWith('05')) return _pourcentageAirtel / 100;
    if (numero.startsWith('06')) return _pourcentageMtn / 100;
    return 0.0;
  }

  @override
  void initState() {
    super.initState();
    initNumero();
    rechargeStatusController.fetchRechargeStatus();
    _fetchPourcentages(); // ← AJOUTE CETTE LIGNE
  }

  @override
  void dispose() {
    numeroController.dispose();
    montantController.dispose();

    super.dispose();
  }

  void initNumero() async {
    var user = storage.read('userInfo') ?? {};
    if (user.isNotEmpty) {
      String phoneNumber = await user['telephone'] ?? '';
      phoneNumber = phoneNumber.replaceFirst(RegExp(r'^242'), '');

      print("📱📱📱 Numéro de téléphone récupéré : $phoneNumber");

      numeroController.text = phoneNumber;
    }
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir un numéro de téléphone';
    }
    if (value.length < 9) {
      return 'Le numéro doit contenir au moins 9 chiffres';
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
    if (amount < 1000) {
      return 'Le montant minimum est de 1 000 FCFA';
    }
    if (amount > 1000000) {
      return 'Le montant maximum est de 1 000 000 FCFA';
    }
    return null;
  }

  Future<void> _processRecharge() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await ValidationTokenController.to.validateToken();
    print(
        '📊📊📊📊 voila le status ${ValidationTokenController.to.isCheckingToken()}');
    if (ValidationTokenController.to.isCheckingToken() == false) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Simulation d'un appel API

      final numero = numeroController.text;

      if (!(numero.startsWith("06") ||
          numero.startsWith("04") ||
          numero.startsWith("05") ||
          numero.startsWith("22"))) {
        setState(() {
          _isLoading = false;
        });
        SnackBarService.info(
          "Numéro de téléphone invalide",
        );
        return;
      }
      if (numero.startsWith('06') && !_mtnDisponible) {
        setState(() {
          _isLoading = false;
        });
        SnackBarService.error('Les frais MTN ne sont pas encore configurés.');
        return;
      }
      if (numero.startsWith('05') && !_airtelDisponible) {
        setState(() {
          _isLoading = false;
        });
        SnackBarService.error(
            'Les frais Airtel ne sont pas encore configurés.');
        return;
      }

      bool isConnected = await hasInternetConnection();

      if (isConnected) {
        print('Connexion Internet disponible');
      } else {
        SnackBarService.error('Pas de connexion Internet');
        return;
      }

      final service = FeaturesService();

      if (numero.startsWith('06')) {
        print('📊📊 $numero');
        final isActive = await service.isFeatureActive(AppFeature.rechargeMomo);

        if (isActive) {
          print('✅ La recharge MoMo est disponible');
        } else {
          Get.back();
          SnackBarService.error(
              '❌ Pour des raisons de maintenance, La recharge La recharge MoMo est momentainément suspendu. Nos équipes travaillent d\'arrache-pied pour son rétablissement.\nVeuillez réessayer plus tard.');

          return;
        }
      } else {
        final isActive =
            await service.isFeatureActive(AppFeature.rechargeAirtelMoney);
        print('kkkk $isActive');

        if (isActive) {
          print('✅ La recharge Airtel Momey est disponible');
        } else {
          Get.back();
          // SnackBarService.error('❌ La recharge Airtel Money est désactivée');
          SnackBarService.error(
              '❌ Pour des raisons de maintenance, La recharge Airtel Money est momentainément suspendu. Nos équipes travaillent d\'arrache-pied pour son rétablissement.\nVeuillez réessayer plus tard.');

          return;
        }
      }

      //print()
      final montant = montantController.text;
      final result = await MobileMoneyService.sendMobileMoney(
        montant: montant,
        typeTransactionId: '32',
        telephone: numero,
      );

      // print('Voila la reponse $result');
      // // TODO: Remplacer par l'appel API réel
      // print('Recharge Mobile Money: $montant FCFA sur $numero');
      //

      // _showSuccessDialog();
    } catch (e) {
      _showErrorDialog('Erreur lors de la recharge. Veuillez réessayer.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.hourglass_empty, color: Colors.green, size: 8.w),
          ),
          title: Text(
            'Recharge en cours',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Votre recharge de ${montantController.text} FCFA  est en attente , merci de valider',
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
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Retour à la page précédente
                },
                child: Text('OK',
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
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
                child: Text('OK',
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _setQuickAmount(int amount) {
    setState(() {
      montantController.text == amount.toString();
    });
    montantController.text = amount.toString();
  }

  double recupFrais() {
    double montant = double.tryParse(montantController.text.trim()) ?? 0.0;
    return montant * _getPourcentage();
  }

  double reste() {
    double montant = double.tryParse(montantController.text.trim()) ?? 0.0;
    return montant - recupFrais();
  }

  @override
  Widget build(BuildContext context) {
    // Obtenir les dimensions de l'écran
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    var user = storage.read('userInfo') ?? {};

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF17338D),
          elevation: 0,
          leading: BackButton(color: Colors.white),
          title: Text(
            "Mobile Money",
            style: TextStyle(
              fontSize: isSmallScreen ? 16.sp : 16.sp,
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
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 10.w : 6.w,
                  vertical: isSmallScreen ? 3.h : 4.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 600 : double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec gradient
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF17338D).withOpacity(0.1),
                            globalColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: globalColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.account_balance_wallet,
                                  color: globalColor,
                                  size: isSmallScreen ? 6.w : 5.w,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Recharge Mobile Money',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 12.sp : 12.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      'Rechargez votre compte en toute sécurité',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Champ numéro de téléphone
                    Text(
                      'Numéro de téléphone',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Obx(() {
                        print(
                            '✅✅✅✅✅✅✅rechargeStatusController.isRechargeFiger.value: ${rechargeStatusController.isRechargeFiger.value}');

                        //     if(rechargeStatusController.rechargeBloquee==1){
                        //       return TextFormField(
                        //       readOnly: true,
                        //   inputFormatters: [
                        //     FilteringTextInputFormatter.digitsOnly,
                        //     LengthLimitingTextInputFormatter(9),
                        //   ],
                        //   enabled: false,
                        //   controller: numeroController,
                        //   keyboardType: TextInputType.phone,
                        //   validator: _validatePhoneNumber,
                        //   style:
                        //       TextStyle(fontSize: isSmallScreen ? 15.sp : 13.sp),
                        //   decoration: InputDecoration(
                        //     prefixText: '+242 ',
                        //     prefixStyle: TextStyle(
                        //       color: Colors.black87,
                        //       fontWeight: FontWeight.bold,
                        //       fontSize: isSmallScreen ? 15.sp : 13.sp,
                        //     ),
                        //     labelText: 'Numéro Mobile Money',
                        //     hintText: 'Ex: 06 123 45 61',
                        //     filled: true,
                        //     fillColor: Colors.white,
                        //     border: OutlineInputBorder(
                        //       borderRadius: BorderRadius.circular(15),
                        //       borderSide: BorderSide.none,
                        //     ),
                        //     enabledBorder: OutlineInputBorder(
                        //       borderRadius: BorderRadius.circular(15),
                        //       borderSide: BorderSide(color: Colors.grey[200]!),
                        //     ),
                        //     focusedBorder: OutlineInputBorder(
                        //       borderRadius: BorderRadius.circular(15),
                        //       borderSide:
                        //           BorderSide(color: globalColor, width: 2),
                        //     ),
                        //     prefixIcon: Container(
                        //       margin: EdgeInsets.all(2.w),
                        //       decoration: BoxDecoration(
                        //         color: globalColor.withOpacity(0.1),
                        //         borderRadius: BorderRadius.circular(10),
                        //       ),
                        //       child: Icon(Icons.phone,
                        //           color: globalColor,
                        //           size: isSmallScreen ? 5.w : 4.w),
                        //     ),
                        //     contentPadding: EdgeInsets.symmetric(
                        //         horizontal: 4.w, vertical: 2.h),
                        //   ),
                        // );
                        //     }

                        return TextFormField(
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(9),
                          ],
                          onChanged: (value) {
                            setState(() {});
                          },
                          enabled:
                              rechargeStatusController.isRechargeFiger.value ==
                                      1
                                  ? false
                                  : true, //: !_isLoading,
                          controller: numeroController,
                          keyboardType: TextInputType.phone,
                          validator: _validatePhoneNumber,
                          style: TextStyle(
                              fontSize: isSmallScreen ? 15.sp : 13.sp),
                          decoration: InputDecoration(
                            prefixText: '+242 ',
                            prefixStyle: TextStyle(
                              color: rechargeStatusController
                                          .isRechargeFiger.value ==
                                      1
                                  ? Colors.black87.withOpacity(0.3)
                                  : Colors.black87,
                              // fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 15.sp : 13.sp,
                            ),
                            labelText: 'Numéro Mobile Money',
                            hintText: 'Ex: 00123456',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide:
                                  BorderSide(color: globalColor, width: 2),
                            ),
                            prefixIcon: Container(
                              margin: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: globalColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.phone,
                                  color: globalColor,
                                  size: isSmallScreen ? 5.w : 4.w),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 2.h),
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: 4.h),

                    // Montants rapides
                    Text(
                      'Montants rapides',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Grid responsive pour les montants
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isTablet ? 4 : (isSmallScreen ? 2 : 3),
                        crossAxisSpacing: 2.w,
                        mainAxisSpacing: 1.h,
                        childAspectRatio:
                            isTablet ? 3 : (isSmallScreen ? 2.5 : 3),
                      ),
                      itemCount: _quickAmounts.length,
                      itemBuilder: (context, index) {
                        final amount = _quickAmounts[index];
                        final isSelected =
                            montantController.text == amount.toString();

                        return GestureDetector(
                          onTap: () =>
                              !_isLoading ? _setQuickAmount(amount) : null,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [
                                        globalColor,
                                        globalColor.withOpacity(0.8)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: isSelected ? null : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? globalColor
                                    : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: globalColor.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                            ),
                            child: Center(
                              child: Text(
                                '${NumberFormat("#,##0", "fr_FR").format(double.tryParse(amount.toString()) ?? 0.0)} FCFA',
                                // '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} F',
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : globalColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 9.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 4.h),

                    // Champ montant
                    Text(
                      'Montant personnalisé',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(7),
                        ],
                        enabled: !_isLoading,
                        controller: montantController,
                        onChanged: (a) {
                          if (int.parse(a) > 1000000) {
                            setState(() {
                              montantController.text = "1000000";
                            });
                          } else
                            setState(() {
                              montantController.text = a;
                            });
                        },
                        keyboardType: TextInputType.number,
                        validator: _validateAmount,
                        style: TextStyle(fontSize: 9.sp),
                        decoration: InputDecoration(
                          labelText: 'Montant à recharger',
                          hintText: 'Minimum 1 000 FCFA',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                BorderSide(color: globalColor, width: 2),
                          ),
                          suffixText: 'FCFA',
                          suffixStyle: TextStyle(
                            color: globalColor,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 13.sp : 11.sp,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 2.h),
                        ),
                      ),
                    ),

                    SizedBox(height: 5.h),
                    Visibility(
                      visible: montantController.text.isNotEmpty,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF17338D).withOpacity(0.1),
                              globalColor.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: _fraisEnChargement
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CupertinoActivityIndicator(),
                                  SizedBox(width: 2.w),
                                  Text('Chargement des frais...',
                                      style: TextStyle(fontSize: 12.sp)),
                                ],
                              )
                            : !_fraisDisponiblesPourNumero()
                                ? Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded,
                                          color: Colors.orange),
                                      SizedBox(width: 2.w),
                                      Expanded(
                                        child: Text(
                                          _messageFraisIndisponibles(),
                                          style: TextStyle(
                                              color: Colors.orange,
                                              fontSize: 9.sp),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(2.w),
                                            decoration: BoxDecoration(
                                              color:
                                                  globalColor.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                                Icons.account_balance_wallet,
                                                color: globalColor,
                                                size:
                                                    isSmallScreen ? 3.w : 2.w),
                                          ),
                                          SizedBox(width: 1.w),
                                          Text('Frais',
                                              style: TextStyle(fontSize: 9.sp)),
                                        ],
                                      ),
                                      SizedBox(height: 1.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Montant à recharger',
                                              style:
                                                  TextStyle(fontSize: 12.sp)),
                                          Text(
                                            "${NumberFormat("#,##0", "fr_FR").format(double.tryParse(montantController.text) ?? 0)} FCFA",
                                            style: TextStyle(fontSize: 9.sp),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 1.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Frais de recharge (${(_getPourcentage() * 100).toStringAsFixed(1)}%)',
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 9.sp),
                                          ),
                                          Text(
                                            "${NumberFormat("#,##0", "fr_FR").format(recupFrais())} FCFA",
                                            style: TextStyle(
                                                fontSize: 9.sp,
                                                color: Colors.red),
                                          ),
                                        ],
                                      ),
                                      Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Total',
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 3.w)),
                                          Text(
                                            "${NumberFormat("#,##0", "fr_FR").format(reste())} FCFA",
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: montantController
                                                          .text.length <
                                                      5
                                                  ? 4.w
                                                  : 2.w,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    // Bouton de validation avec design amélioré
                    Container(
                      width: double.infinity,
                      height: isSmallScreen ? 7.h : 6.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: _isLoading
                            ? null
                            : LinearGradient(
                                colors: [
                                  globalColor,
                                  globalColor.withOpacity(0.8)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        boxShadow: _isLoading
                            ? null
                            : [
                                BoxShadow(
                                  color: globalColor.withOpacity(0.4),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (_isLoading ||
                                  !_fraisDisponiblesPourNumero())
                              ? Colors.grey
                              : Colors
                                  .transparent, // ← ICI, remplace l'ancienne ligne
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed:
                            (_isLoading || !_fraisDisponiblesPourNumero())
                                ? () {
                                    Get.dialog(
                                      AppDialog(
                                        title: "Recharge impossible",
                                        body:
                                            "Une erreur est survenue lors de la recharge. Vérifie tes moyens de paiement et réessaie dans quelques instants.",
                                        actions: [
                                          AppDialogAction(
                                            label: "OK",
                                            isDestructive: true,
                                            onPressed: () => Get.back(),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                : _processRecharge,
                        child: _isLoading
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
                                    "Traitement en cours...",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                      color: Colors.white,
                                      Icons.send,
                                      size: 10.sp),
                                  SizedBox(width: 2.w),
                                  Text(
                                    "Valider la recharge de ${NumberFormat("#,##0", "fr_FR").format(reste() ?? 0)} FCFA",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
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
                          Icon(Icons.security,
                              color: Colors.green[700],
                              size: isSmallScreen ? 4.w : 3.w),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              'Vos transactions sont sécurisées et cryptées',
                              style: TextStyle(
                                color: Colors.green[800],
                                fontSize: 9.sp,
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
        ));
  }
}
