import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:onyfast/Api/otp_renitialisation_key/changepasswordservice.dart';
import 'package:onyfast/View/Connecter/View/connect.dart';
import 'package:onyfast/View/ResetPassword/resetpassword.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/main.dart';
import 'package:onyfast/Controller/UserLocalController.dart';
import 'package:onyfast/Controller/password.dart';

class VerifOtpCode extends GetxController {
  final isLoading = false.obs;
  final error = ''.obs;
  final verify = false.obs;
}

class OtpMail extends StatefulWidget {
  const OtpMail({super.key});

  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<OtpMail> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final VerifOtpCode _passwordController = Get.find<VerifOtpCode>();
  late LockController _lockController;

  @override
  void initState() {
    super.initState();
    _lockController = Get.find<LockController>();

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
    super.dispose();
  }

  void _validatePin(String pin) async {
    if (pin.length == 6) {
      try {
        final userController = Get.find<UserLocalController>();
        _passwordController.isLoading.value = true;

        // Attendre la réponse de la vérification OTP
        final response = await VerifyOtpResource().verifyOtp(pin);

        _passwordController.isLoading.value = false;

        // Vérifier si la vérification a réussi
        if (response['success'] == true) {
          print('Redirection vers l\'écran précédent');
          // Ajouter un petit délai pour s'assurer que l'UI est mise à jour
          await Future.delayed(Duration(milliseconds: 300));
          // Retourner à l'écran précédent
          // Navigator.of(context).pop(true);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => Resetpassword(),
            ),
          );
          // Get.to(Resetpassword(),
          //   transition: Transition.cupertino, // 👈 transition iOS

          // );

          // Navigator.push(context,);
        } else {
          // Afficher l'erreur et réinitialiser le champ
          _pinController.clear();
          _focusNode.requestFocus();
        }
      } catch (e) {
        _passwordController.isLoading.value = false;
        _pinController.clear();
        _focusNode.requestFocus();
        SnackBarService.warning(
          'Une erreur est survenue. Veuillez réessayer.',
        );
      }
    }
  }

  void _onPinChanged(String pin) {
    setState(() {});

    // Effacer l'erreur quand l'utilisateur recommence à taper
    if (_passwordController.error.value.isNotEmpty) {
      _passwordController.error.value = '';
    }

    if (pin.length == 6) {
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
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                style:  TextStyle(
                  color: CupertinoColors.systemRed,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              )
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final userInfo = storage.read('userInfo');
    print(" voila les users $userInfo");
    // Thème pour Pinput
    final defaultPinTheme = PinTheme(
      width: (MediaQuery.of(context).size.width * 0.15).clamp(48.0, 72.0),
height: (MediaQuery.of(context).size.width * 0.15).clamp(48.0, 72.0),
      textStyle:  TextStyle(
        fontSize: 12.sp,
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

    return Material(
        color: Colors.white,
        child: CupertinoPageScaffold(
          backgroundColor: Colors.white,
          child: SafeArea(
            child: GestureDetector(
              onTap: () {
                if (!_passwordController.isLoading.value) {
                  _focusNode.requestFocus();
                }
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                    // Logo
                    Container(
                     width: (20.w).clamp(64.0, 100.0),
height: (20.w).clamp(64.0, 100.0),
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
                          MediaQuery.of(context).size.width * 0.175,
                        ),
                        child: Image.asset(
                          "asset/onylogo.png",
                          fit: BoxFit.contain,
                          width: MediaQuery.of(context).size.width * 0.25,
                          height: MediaQuery.of(context).size.width * 0.25,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Titre
                     Text(
                      "Vérification du code Pin",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Color(0xFF1D348C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      textAlign: TextAlign.center,
                      "Pour confirmer votre identité, veuillez entrer le code PIN reçu par SMS ou WhatsApp sur votre numéro de téléphone : ${maskPhone(userInfo['telephone'])}.",
                      style:  TextStyle(
                        fontSize: 12.sp,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 40),

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
                            borderRadius: BorderRadius.all(Radius.circular(1)),
                          ),
                        ),
                        showCursor: true,
                        closeKeyboardWhenCompleted: false,
                      );
                    }),

                    // Message d'erreur
                    _buildErrorMessage(),

                    const SizedBox(height: 40),

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
                             Text(
                              "Vérification en cours...",
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      }

                      return Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: _pinController.text.length == 6
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
                          child:  Text(
                            "Vérifier",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Option "Mot de passe oublié" (optionnel)
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onPressed: () {
                        _passwordController.isLoading.value = true;

                        _passwordController.isLoading.value = false;

                        // Action pour mot de passe oublié
                        // Peut rediriger vers une page de récupération
                      },
                      child:  Text(
                        "Si vous n'avez rien reçu , cliquer pour renvoyer",
                        style: TextStyle(
                          color: Color(0xFF1D348C),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

String maskPhone(String phone) {
  // On suppose un format comme "242064839269"
  if (phone.length < 5) return phone; // fallback si format inattendu

  final country = phone.substring(0, 3); // "242"
  final firstTwo = phone.substring(3, 5); // "06"
  const middleMasked = '***';
  const nextMasked = '**';
  const lastTwo = '00'; // tu forces à "00" pour plus de confidentialité

  return '$country $firstTwo $middleMasked $nextMasked $lastTwo';
}
