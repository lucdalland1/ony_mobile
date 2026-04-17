import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/otp_renitisalistion_key/otpcontroller.dart';
import 'package:onyfast/Controller/verou/verroucontroller.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Widget/chargementpopup.dart';
import 'package:onyfast/main.dart';
import 'package:pinput/pinput.dart';
import 'package:onyfast/Controller/UserLocalController.dart';
import 'package:onyfast/Controller/password.dart';

class CodeVerification {
  void show(BuildContext context, Function fonction) async {
    AppSettingsController.to.setInactivity(false);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CodeVerificationBottomSheet(function: fonction),
    );
    AppSettingsController.to.setInactivity(true);
  }
}

class _CodeVerificationBottomSheet extends StatefulWidget {
  final Function? function;
  // ignore: use_super_parameters
  const _CodeVerificationBottomSheet({Key? key, this.function})
      : super(key: key);

  @override
  State<_CodeVerificationBottomSheet> createState() =>
      _CodeVerificationBottomSheetState();
}

class _CodeVerificationBottomSheetState
    extends State<_CodeVerificationBottomSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final VoirPasswController _passwordController =
      Get.put(VoirPasswController());
  late LockController _lockController;
  late AnimationController _animationController;
  late Animation<double> _floatingAnimation;
  OtpRenitPasswordController otp = Get.put(OtpRenitPasswordController());

  @override
  void initState() {
    super.initState();
    _lockController = Get.find<LockController>();

    // Animation infinie pour le logo
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _floatingAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);

    // Focus automatique après un court délai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && !_passwordController.isLoading.value) {
          _focusNode.requestFocus();
        }
      });
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _validatePin(String pin) async {
    if (pin.length == 4) {
      try {
        final userController = Get.find<UserLocalController>();

        // Vérifier le PINValidationTokenController.to.validateToken();
        ValidationTokenController.to.validateToken();
        // if(ValidationTokenController.to.isCheckingToken()==false){
        //   return;
        // }
        final result = await _passwordController.verifyPin(
          telephone: userController.telephone,
          password: pin,
        );

        // Si la vérification réussit, déverrouiller et fermer le modal
        if (!_passwordController.error.value.isNotEmpty) {
          // _lockController.unlockApp();
          Get.back();
          widget.function!();
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

  void _onPinChanged(String pin) {
    setState(() {});

    // Effacer l'erreur quand l'utilisateur recommence à taper
    if (_passwordController.error.value.isNotEmpty) {
      _passwordController.error.value = '';
    }

    if (pin.length == 4) {
      // Petite vibration tactile
      // HapticFeedback.lightImpact();
      _validatePin(pin);
    }
  }

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
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              color: CupertinoColors.systemRed,
              size: 20,
            ),
            SizedBox(width: 12),
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

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    // Thème pour Pinput
    final defaultPinTheme = PinTheme(
      width: (14.w).clamp(48.0, 70.0),
      height: (14.w).clamp(48.0, 70.0),
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: keyboardHeight > 0 ? screenHeight * 0.85 : screenHeight * 0.65,
      margin: EdgeInsets.only(bottom: keyboardHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Indicateur de drag
          Container(
            width: (10.w).clamp(36.0, 48.0),
            height: 4,
            margin: EdgeInsets.only(
              top: (1.2.h).clamp(8.0, 14.0),
              bottom: (0.8.h).clamp(6.0, 10.0),
            ),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_passwordController.isLoading.value) {
                  _focusNode.requestFocus();
                }
              },
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.symmetric(horizontal: (6.w).clamp(20.0, 40.0)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Logo avec animation flottante
                    AnimatedBuilder(
                      animation: _floatingAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                            offset: Offset(0, _floatingAnimation.value),
                            child: Container(
                              width: (20.w).clamp(64.0, 100.0),
                              height: (20.w).clamp(64.0, 100.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF1D348C)
                                        .withOpacity(0.2), // Ombre plus sombre
                                    spreadRadius: 10, // Étend l’ombre
                                    blurRadius: 15, // Plus flou
                                    offset:
                                        const Offset(0, 6), // Ombre plus basse
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    (20.w).clamp(64.0, 100.0) / 2),
                                child: Image.asset(
                                  "asset/onylogo.png",
                                  fit: BoxFit.contain,
                                  width: (15.w).clamp(48.0, 76.0),
                                  height: (15.w).clamp(48.0, 76.0),
                                ),
                              ),
                            ));
                      },
                    ),

                    const SizedBox(height: 24),

                    // Titre
                    Text(
                      "Vérification du code",
                      style: TextStyle(
                        fontSize: (13.sp).clamp(17.0, 24.0),
                        color: Color(0xFF1D348C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Saisissez votre code PIN pour continuer",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: (9.sp).clamp(13.0, 16.0),
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // PinPut
                    Obx(() {
                      final isLoading = _passwordController.isLoading.value;
                      final hasError =
                          _passwordController.error.value.isNotEmpty;

                      return Pinput(
                        controller: _pinController,
                        focusNode: _focusNode,
                        length: 4,
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
                            borderRadius: BorderRadius.all(Radius.circular(1)),
                          ),
                        ),
                        showCursor: true,
                        closeKeyboardWhenCompleted: false,
                      );
                    }),

                    // Message d'erreur
                    _buildErrorMessage(),

                    const SizedBox(height: 32),

                    // Indicateur de chargement ou bouton
                    Obx(() {
                      if (_passwordController.isLoading.value) {
                        return SizedBox(
                          // Ajouter un SizedBox avec largeur infinie
                          width: double.infinity,
                          child: Column(
                            mainAxisSize: MainAxisSize
                                .min, // Pour que la colonne prenne le moins de hauteur possible
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Container(
                        width: double.infinity,
                        height: (6.h).clamp(46.0, 60.0),
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
                          onPressed: _pinController.text.length == 4
                              ? () => _validatePin(_pinController.text)
                              : null,
                          child: Text(
                            "Vérifier",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: sizeTextBouton,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // Option "Code oublié"
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                        chargementDialog();
                        _passwordController.isLoading.value = true;
                        otp.sendOtp();
                        _passwordController.isLoading.value = false;

                        // Action pour code oublié
                        // Peut rediriger vers une page de récupération
                      },
                      child: Text(
                        "Code oublié ?",
                        style: TextStyle(
                          color: Color(0xFF1D348C),
                          fontSize: (9.sp).clamp(13.0, 16.0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(
                        height: keyboardHeight > 0
                            ? (2.h).clamp(14.0, 24.0)
                            : (4.h).clamp(28.0, 48.0)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
