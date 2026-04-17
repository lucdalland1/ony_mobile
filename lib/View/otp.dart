import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Api/user_inscription.dart';
import 'package:onyfast/View/home.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:pinput/pinput.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../Color/app_color_model.dart';
import 'package:onyfast/Controller/otpcontroller.dart';

class Otp extends StatefulWidget {
  const Otp({super.key});

  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  final pinController = TextEditingController();

  final AuthController authController = Get.find();
  final Otpcontroller otpmessage = Get.put(Otpcontroller());

  // ⏱️ Compte à rebours (5 minutes)
  int _secondsLeft = 300; // 5m
  Timer? _timer;
  bool _resending =
      false; // bool simple pour éviter les notifications Rx dans le build

  @override
  void initState() {
    super.initState();
    _initSmsAutoFill();

    // Timer de 5 minutes
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        t.cancel();
      }
    });
  }

  Future<void> _initSmsAutoFill() async {
    // Démarre l’écoute auto des SMS (selon plateforme)
    SmsAutoFill().listenForCode;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 🛡️ Récupération sûre des arguments
  Map<String, dynamic> _safeArgs(Object? a) {
    if (a is Map) {
      return a.map((k, v) => MapEntry(k.toString(), v));
    }
    return <String, dynamic>{};
  }

  String _mmss(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  Future<void> _resendCode(String tel) async {
    if (_resending) return;
    setState(() => _resending = true);
    try {
      await authController.requestOtp(tel); // ton endpoint existant

      // (si tu comptes les envois côté controller, incrémente là-bas)
      // otpmessage.number.value++;

      // reset timer à 5 minutes
      setState(() => _secondsLeft = 300);
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        if (_secondsLeft > 0) {
          setState(() => _secondsLeft--);
        } else {
          t.cancel();
        }
      });

      SnackBarService.success(
          title: 'Code renvoyé', 'Un nouveau code a été envoyé.');
    } catch (e) {
      SnackBarService.warning('Impossible de renvoyer le code.');
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = _safeArgs(Get.arguments);

    final String telephone = (args['telephone'] ?? '').toString();
    final String password = (args['password'] ?? '').toString();
    final String code = (args['code'] ?? '').toString();
    final String indicatif = (args['indicatif'] ?? '').toString();
    final String codeParrain = (args['codeParrain'] ?? '').toString();

    // Si un arg essentiel manque → page neutre (évite crash au mount)
    if (telephone.isEmpty ||
        password.isEmpty ||
        code.isEmpty ||
        indicatif.isEmpty) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final defaultPinTheme = PinTheme(
      width: MediaQuery.of(context).size.width * 0.15,
      height: MediaQuery.of(context).size.width * 0.15,
      textStyle: const TextStyle(
        fontSize: 24,
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
          color: Colors.red,
          width: 2,
        ),
      ),
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    String masquerNumero(String numero) {
      if (numero.length <= 5) return numero;
      final debut = numero.substring(0, 4);
      final fin = numero.substring(numero.length - 2);
      final etoiles = '*' * (numero.length - debut.length - fin.length);
      return '$debut$etoiles$fin';
    }

    return Scaffold(
        backgroundColor: AppColorModel.WhiteColor,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Container(
              margin: const EdgeInsets.only(top: 5),
              color: AppColorModel.WhiteColor,
              width: double.infinity,
              child: Column(
                spacing: 10.dp,
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  Padding(
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.01,
                      left: screenWidth * 0.20,
                      right: screenWidth * 0.1,
                      bottom: 10,
                    ),
                    child: SizedBox(
                      width: screenWidth * 0.4,
                      height: screenWidth * 0.4,
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            "asset/onylogo.png",
                            height: screenWidth * 0.7,
                            width: screenWidth * 0.25,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "Vérifier le numéro",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF1D348C),
                      fontSize: screenWidth * 0.065,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "de téléphone",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF1D348C),
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(10),
                  Text(
                    "Un code à 6 chiffres envoyé au ${masquerNumero(telephone)}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11.sp,
                    ),
                  ),
                  const Gap(10),

                  // Pinput (design aligné)

                  Pinput(
                    controller: pinController,
                    length: 6,
                    obscureText: true,
                    obscuringCharacter: '●',
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    errorPinTheme: errorPinTheme,
                    onChanged: (pin) {
                      authController.otp.value = pin;
                    },
                    onCompleted: (pin) async {
                      authController.otp.value = pin;
                      await authController.verifyAndRegister(
                        telephone,
                        password,
                        indicatif,
                        code,
                        codeParrain,
                      );
                      pinController.clear();
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: const [],
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
                  ),

                  const Gap(20),

                  // Bouton (dégradé + désactivé + loader) — dépend de Rx du controller => Obx OK
                  Obx(() {
                    final bool enabled = authController.otp.value.length == 6 &&
                        !authController.isLoading.value;

                    return InkWell(
                      onTap: enabled
                          ? () async {
                              if (!authController.isLoading.value) {
                                await authController.verifyAndRegister(
                                  telephone,
                                  password,
                                  indicatif,
                                  code,
                                  codeParrain,
                                );
                                pinController.clear();
                              }
                            }
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 50,
                        width: screenWidth * 0.78,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: enabled
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF1D348C),
                                    Color(0xFF2563EB)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: enabled ? null : Colors.grey.shade300,
                          boxShadow: enabled
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF4F46E5)
                                        .withOpacity(0.30),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: authController.isLoading.value
                              ? const CupertinoActivityIndicator(
                                  color: Colors.white,
                                  radius: 15,
                                )
                              : Text(
                                  "Vérifier le code",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    );
                  }),

                  const Gap(20),
                  TextButton(
                    onPressed: () {
                      Get.offAll(Home(), transition: Transition.fadeIn);
                    },
                    child: Text(
                      "Connexion",
                      style:  TextStyle(
                        color: Color(0xFF1D348C),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Gap(12),

                  Text(
                    "Vous n’avez pas reçu de code ?",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12.sp,
                    ),
                  ),

                  // ⏲️ Bloc dynamique : compte à rebours 5m / renvoi (sans Obx → pas d'update Rx pendant build)
                  _secondsLeft > 0
                      ? Text(
                          'Renvoyer le code dans ${_mmss(_secondsLeft)}',
                          style: TextStyle(
                            color: AppColorModel.BlueColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 9.sp,
                            decoration: TextDecoration.underline,
                          ),
                        )
                      : InkWell(
                          onTap: _resending
                              ? null
                              : () {
                                  _resendCode(telephone);
                                  pinController.clear();
                                },
                          child: _resending
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CupertinoActivityIndicator(
                                    radius: 15,
                                  ),
                                )
                              : Text(
                                  'Renvoyer le code',
                                  style: TextStyle(
                                    color: AppColorModel.BlueColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9.sp,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                        ),

                  const Gap(1),

                  // 🧮 Bloc "messages restants" — dépend de Rx du Otpcontroller => Obx OK
                  Obx(() {
                    if (otpmessage.error.value.isEmpty) {
                      // Exemple: limite 4 envois; adapte selon ta logique
                      final remaining = 4 - otpmessage.number.value;
                      final label = _resending
                          ? "En cours..."
                          : (remaining < 0 ? "0" : "$remaining");
                      return Text(
                        "Messages restants : $label",
                        style:  TextStyle(
                          color: Color(0xFF1D348C),
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }
                    return Text(
                      otpmessage.error.value,
                      style:  TextStyle(
                        color: Color(0xFF1D348C),
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ));
  }
}
