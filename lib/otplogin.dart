import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/user_inscription.dart';
import 'package:onyfast/Controller/otp_renitisalistion_key/otpcontroller.dart';
import 'package:onyfast/Controller/otpcontroller.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/View/home.dart';
import 'package:onyfast/main.dart';
import 'package:pinput/pinput.dart';
import 'package:onyfast/Controller/UserLocalController.dart';
import 'package:onyfast/Controller/password.dart';
import 'package:sms_autofill/sms_autofill.dart';

String obfuscatePhone(String phone) {
  if (phone.length < 4) return phone;
  return '${phone.substring(0, 3)}****${phone.substring(phone.length - 2)}';
}

class Otplogin extends StatefulWidget {
  final bool iswhatssap;
  final bool isTelephone;
  const Otplogin(
      {super.key, required this.iswhatssap, required this.isTelephone});

  @override
  State<Otplogin> createState() => _OtploginState();
}

class _OtploginState extends State<Otplogin> with TickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final VoirPasswController _passwordController =
      Get.put(VoirPasswController());
  OtpRenitPasswordController otp = Get.put(OtpRenitPasswordController());
  int _secondsRemaining = 300; // 5 minutes en secondes
  late Timer _timer;
  Otpcontroller otpmessage = Get.put(Otpcontroller());
  @override
  void initState() {
    super.initState();
    _startTimer();

    // Focus automatique après un court délai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && !_passwordController.isLoading.value) {
          _focusNode.requestFocus();
        }
      });
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  void _resendPassword() {
    setState(() async {
      setState(() {
        isLoading.value = true;
      });

      bool success = await AuthController().requestOtp(telephone);
      setState(() {
        isLoading.value = false;
      });
    });
    _startTimer();
    // Ajoutez ici la logique pour renvoyer le mot de passe
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    _initSmsAutoFill();
    _timer.cancel();
    super.dispose();
  }

  Future<void> _initSmsAutoFill() async {
    // Demande de permission pour lire les SMS
    SmsAutoFill().listenForCode;
  }

  Future<void> _validatePin(String pin) async {
    print('voila le mot de passe $pin');
    if (pin.length == 6) {
      try {
        final AuthController authController = Get.find();
        authController.otp.value = pin;
        await authController.verifyAndLogin(
          Get.arguments['telephone'],
          Get.arguments['password'],
          (Get.arguments as Map?)?['verif'] as bool, // OK si bool garanti
        );

        // Si la vérification réussit, déverrouiller
        if (!_passwordController.error.value.isNotEmpty) {
          // _lockController.unlockApp();
        } else {
          // Effacer le PIN en cas d'erreur
          _pinController.clear();
          _focusNode.requestFocus();
        }
      } catch (e) {
        // Gérer les erreurs
        _pinController.clear();
        _focusNode.requestFocus();
      }
    }
  }

  void _onPinChanged(String pin) async {
    setState(() {});

    // Effacer l'erreur quand l'utilisateur recommence à taper
    if (_passwordController.error.value.isNotEmpty) {
      _passwordController.error.value = '';
    }

    if (pin.length == 6) {
      try {
        // Get.snackbar('voila le mot de passe $pin', 'voila le mot de passe $pin');
        _passwordController.isLoading.value = true;
        await _validatePin(pin);

        // Vider les champs après une validation réussie
        if (!_passwordController.error.value.isNotEmpty) {
          _pinController.clear();
          _focusNode.unfocus();
        }
      } catch (e) {
        // En cas d'erreur, vider le champ et remettre le focus
        _pinController.clear();
        _focusNode.requestFocus();
        print('Erreur lors de la validation: $e');
      } finally {
        _passwordController.isLoading.value = false;
      }
    }
  }

  var isLoading = false.obs;
  Widget _buildErrorMessage() {
    return Obx(() {
      if (_passwordController.error.value.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.only(top: (1.8.h).clamp(12.0, 20.0)),
        padding: EdgeInsets.symmetric(
          horizontal: (4.w).clamp(12.0, 20.0),
          vertical: (1.2.h).clamp(8.0, 14.0),
        ),
        decoration: BoxDecoration(
          color: CupertinoColors.systemRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CupertinoColors.systemRed.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              color: CupertinoColors.systemRed,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _passwordController.error.value,
                style: TextStyle(
                  color: CupertinoColors.systemRed,
                  fontSize: (8.5.sp).clamp(12.0, 15.0),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  String telephone = '';
  String password = '';
  @override
  Widget build(BuildContext context) {
    // Add null safety check for Get.arguments
    if (Get.arguments == null) {
      // Handle the case where no arguments are passed
      // You might want to navigate back or show an error message
      return Scaffold(
        body: Center(
          child: CupertinoActivityIndicator(
            color: globalColor,
          ),
        ),
      );
    }

    // Safely cast the arguments
    final args = Get.arguments as Map<String, dynamic>?;

    // Provide default values if arguments are missing
    telephone = args?['telephone']?.toString() ?? '';
    password = args?['password']?.toString() ?? '';

    // Thème pour Pinput
    final defaultPinTheme = PinTheme(
      width: (MediaQuery.of(context).size.width * 0.15).clamp(42.0, 64.0),
      height: (MediaQuery.of(context).size.width * 0.15).clamp(42.0, 64.0),
      textStyle: TextStyle(
        fontSize: (13.sp).clamp(18.0, 26.0),
        color: Color(0xFF1D348C),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: const Color(0xFF1D348C).withOpacity(0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: const Color(0xFF1D348C),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D348C).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: const Color(0xFF1D348C).withOpacity(0.1),
        border: Border.all(
          color: const Color(0xFF1D348C),
          width: 2,
        ),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: CupertinoColors.systemRed,
          width: 2,
        ),
      ),
    );

    return WillPopScope(
      onWillPop: () async => false, // Empêcher le retour
      child: Material(
          color: Colors.white,
          child: CupertinoPageScaffold(
            backgroundColor: Colors.white,
            child: SafeArea(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  if (!_passwordController.isLoading.value) {
                    _focusNode.requestFocus();
                  }
                },
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: (6.w).clamp(20.0, 40.0)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: (MediaQuery.of(context).size.height * 0.1)
                              .clamp(40.0, 90.0)),

                      // Logo
                      Container(
                        width: (MediaQuery.of(context).size.width * 0.35)
                            .clamp(100.0, 160.0),
                        height: (MediaQuery.of(context).size.width * 0.35)
                            .clamp(100.0, 160.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            (MediaQuery.of(context).size.width * 0.35)
                                    .clamp(100.0, 160.0) /
                                2,
                          ),
                          child: Image.asset(
                            "asset/onylogo.png",
                            fit: BoxFit.contain,
                            width: (MediaQuery.of(context).size.width * 0.25)
                                .clamp(80.0, 120.0),
                            height: (MediaQuery.of(context).size.width * 0.25)
                                .clamp(80.0, 120.0),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Titre
                      Text(
                        "Vérifier le numéro\n de téléphone",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: (13.sp).clamp(18.0, 26.0),
                          color: Color(0xFF1D348C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: (1.h).clamp(6.0, 12.0)),
                      Text(
                        (widget.iswhatssap && widget.isTelephone)
                            ? "Saisissez votre code OTP pour vérifier votre numéro de téléphone"
                            : ((widget.iswhatssap == true)
                                ? "Entrez le code OTP reçu sur WhatsApp pour confirmer votre numéro de téléphone"
                                : "Saisissez le code OTP envoyé sur votre téléphone pour vérifier votre numéro"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: (10.sp).clamp(13.0, 17.0),
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      SizedBox(height: (4.h).clamp(24.0, 48.0)),

                      // PinPut
                      Obx(() {
                        final isLoading = _passwordController.isLoading.value;
                        final hasError =
                            _passwordController.error.value.isNotEmpty;

                        return Pinput(
                          controller: _pinController,
                          focusNode: _focusNode,
                          length: 6,
                          obscureText: true,
                          obscuringCharacter: '●',
                          enabled: !isLoading,
                          readOnly: isLoading,
                          defaultPinTheme:
                              hasError ? errorPinTheme : defaultPinTheme,
                          focusedPinTheme:
                              hasError ? errorPinTheme : focusedPinTheme,
                          submittedPinTheme:
                              hasError ? errorPinTheme : submittedPinTheme,
                          errorPinTheme: errorPinTheme,
                          onChanged: _onPinChanged,
                          onCompleted: (String pin) {
                            //  _validatePin(pin);
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: [],
                          animationCurve: Curves.easeInOut,
                          animationDuration: const Duration(milliseconds: 200),
                          cursor: Container(
                            width: 2,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1D348C),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(1)),
                            ),
                          ),
                          showCursor: true,
                          closeKeyboardWhenCompleted: false,
                        );
                      }),

                      // Message d'erreur
                      _buildErrorMessage(),

                      SizedBox(height: (4.h).clamp(24.0, 48.0)),
                      // Indicateur de chargement ou bouton
                      Obx(() {
                        if (_passwordController.isLoading.value) {
                          return Column(
                            children: [
                              const CupertinoActivityIndicator(
                                color: Color(0xFF1D348C),
                                radius: 15,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Vérification en cours...",
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        }

                        return Container(
                          width: double.infinity,
                          height: (6.h).clamp(48.0, 64.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: _pinController.text.length == 4
                                  ? [
                                      const Color(0xFF1D348C),
                                      const Color(0xFF2563EB),
                                    ]
                                  : [
                                      CupertinoColors.systemGrey2,
                                      CupertinoColors.systemGrey3,
                                    ],
                            ),
                          ),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: _pinController.text.length == 6
                                ? () => _validatePin(_pinController.text)
                                : null,
                            child: Text(
                              "Vérifier le code",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: (11.sp).clamp(14.0, 18.0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }),

                      SizedBox(height: (2.5.h).clamp(16.0, 28.0)),
                      // Option "Mot de passe oublié" (optionnel)
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        onPressed: () {
                          _passwordController.isLoading.value = true;

                          Get.offAll(
                            Home(),
                          );

                          _passwordController.isLoading.value = false;

                          // Action pour mot de passe oublié
                          // Peut rediriger vers une page de récupération
                        },
                        child: Text(
                          "Créer un compte",
                          style: TextStyle(
                            color: Color(0xFF1D348C),
                            fontSize: (10.sp).clamp(13.0, 17.0),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),

                      Obx(() {
                        if (otpmessage.error.value.isNotEmpty) {
                          return SizedBox.shrink();
                        }

                        return _secondsRemaining > 0
                            ? Text(
                                'Renvoyer le code dans ${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: const Color(0xFF6B7280),
                                  fontSize: (10.sp).clamp(13.0, 17.0),
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : isLoading.value
                                ? CupertinoActivityIndicator(
                                    color: globalColor,
                                  )
                                : GestureDetector(
                                    onTap: _resendPassword,
                                    child: Text(
                                      "Renvoyer le mot de passe",
                                      style: TextStyle(
                                        color: const Color(0xFF1D348C),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  );
                      }),

                      Obx(() {
                        if (otpmessage.error.value.isEmpty) {
                          return Text(
                            "Messages restants : ${isLoading.value ? "En cours..." : "${4 - otpmessage.number.value}"}",
                            style: TextStyle(
                              color: const Color(0xFF1D348C),
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          );
                        }
                        return Text(
                          otpmessage.error.value,
                          style: TextStyle(
                            color: const Color(0xFF1D348C),
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        );
                      })
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
