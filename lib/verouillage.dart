import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/info_user/userservice.dart';
import 'package:onyfast/Controller/Abonnement/Abonnementencourscontroller.dart';
import 'package:onyfast/Controller/NewTokenSecours/NewTokenSecours.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/otp_renitisalistion_key/otpcontroller.dart';
import 'package:onyfast/Controller/verou/verroucontroller.dart';
import 'package:onyfast/main.dart';
import 'package:pinput/pinput.dart';
import 'package:onyfast/Controller/UserLocalController.dart';
import 'package:onyfast/Controller/password.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final VoirPasswController _passwordController =
      Get.put(VoirPasswController());
  late LockController _lockController;
  OtpRenitPasswordController otp = Get.put(OtpRenitPasswordController());

  @override
  void initState() {
    super.initState();
    _lockController = Get.find<LockController>();
    ValidationTokenController.to.validateToken();
    AppSettingsController.to.setInactivity(true);

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
    ValidationTokenController.to.validateToken();
    super.dispose();
  }

  void _validatePin(String pin) async {
    final GetStorage storage = GetStorage();

    print("🔥🔥🔥🔥🔥🔥 Validation du PIN: $pin ");

    if (pin.length == 4) {
      try {
        final userController = Get.find<UserLocalController>();

        if (SecureTokenController.to.isLoggedIn) {
          // await storage.write('token', SecureTokenController.to.token.value);
          final resp = await UserService.fetchMe();
          UserProfile data = resp.data!;

          print(' 📦  📦   📦  Chargement du numero (Secure ) ');
          print(
              'voila la reponse du fetch me dans le lockscreen ${data.telephone}');
          //  return ;

          userController.telephone = data.telephone;
          await SecureTokenController.to.saveTelephone(data.telephone ?? '');

          final Map<String, dynamic> user = {
            'id': data.id,
            'name': data.name,
            'email': data.email,
            'token': 'token_xxxxx',
            'email_verified_at': null,
            'two_factor_confirmed_at': null,
            'current_team_id': null,
            'profile_photo_path': null,
            'created_at': '2025-01-23T10:00:00Z',
            'updated_at': '2025-01-23T10:00:00Z',
            'organisation_id': 1,
            'prenom': data.prenom,
            'telephone': data.telephone,
            'adresse': data.adresse,
            'old_id': null,
            'profile_photo_url': 'https://example.com/profile.jpg',
            'avatar': null,
            'is_online': false,
            'last_seen': null,
            'code_temporaire': false,
            'abonnement_actuel_id': null,
            'type_user': null, // ou un Map si nécessaire
          };

          await Future.wait([
            storage.write('id', data.id),
            storage.write('userInfo', user),
            storage.write('telephone', data.telephone),
            storage.write('prenom', data.prenom),
          ]);
        }
        // Vérifier le PIN
        await _passwordController.verifyPassword(
          telephone: userController.telephone,
          password: pin,
        );
        AppSettingsController.to.setInactivity(true);
        // Si la vérification réussit, déverrouiller
        if (!_passwordController.error.value.isNotEmpty) {
          _lockController.unlockApp();
        } else {
          // Effacer le PIN en cas d'erreur
          _pinController.clear();
          _focusNode.requestFocus();
        }
      } catch (e) {
        // Gérer les erreurs
        _pinController.clear();
        _focusNode.requestFocus();
      } finally {
        // Nettoyer le controller après utilisation
        AbonnementEncoursController.to.fetchAbonnement();
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
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              color: CupertinoColors.systemRed,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _passwordController.error.value,
                style: const TextStyle(
                  color: CupertinoColors.systemRed,
                  fontSize: 14,
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
    // Thème pour Pinput
    final defaultPinTheme = PinTheme(
      width: (MediaQuery.of(context).size.width * 0.15).clamp(48.0, 72.0),
      height: (MediaQuery.of(context).size.width * 0.15).clamp(48.0, 72.0),
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
              child: Center(
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();

                      if (!_passwordController.isLoading.value) {
                        _focusNode.requestFocus();
                      }
                    },
                    child: Center(
                      child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                      child:SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: (6.w).clamp(20.0, 40.0)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: (MediaQuery.of(context).size.height * 0.1)
                                  .clamp(40.0, 90.0)),

                          // Logo
                          Container(
                            width: (MediaQuery.of(context).size.width * 0.35).clamp(100.0, 160.0),
height: (MediaQuery.of(context).size.width * 0.35).clamp(100.0, 160.0),
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
                                height:
                                    MediaQuery.of(context).size.width * 0.25,
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Titre
                          Text(
                            "Entrez votre code PIN",
                            style: TextStyle(
                              fontSize: (14.sp).clamp(18.0, 26.0),
                              color: Color(0xFF1D348C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: (1.h).clamp(6.0, 12.0)),

                          Text(
                            "Saisissez votre code PIN pour déverrouiller l'application",
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
                            final isLoading =
                                _passwordController.isLoading.value;
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
                              onCompleted: (String pin) async {
                                print("🔥🔥🔥🔥🔥🔥 remplit");
                                await ValidationTokenController.to
                                    .validateToken();
                                //  _validatePin(pin);
                              },
                              keyboardType: TextInputType.number,
                              inputFormatters: [],
                              animationCurve: Curves.easeInOut,
                              animationDuration:
                                  const Duration(milliseconds: 200),
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
                                  Text(
                                    "Vérification en cours...",
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: (10.sp).clamp(13.0, 17.0),
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
                                onPressed: _pinController.text.length == 4
                                    ? () => _validatePin(_pinController.text)
                                    : null,
                                child:  Text(
                                  "Déverrouiller",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: (11.sp).clamp(14.0, 18.0),
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

                              otp.sendOtp();

                              _passwordController.isLoading.value = false;

                              // Action pour mot de passe oublié
                              // Peut rediriger vers une page de récupération
                            },
                            child: Text(
                              "Code PIN oublié ?",
                              style: TextStyle(
                                color: Color(0xFF1D348C),
                                fontSize: (10.sp).clamp(13.0, 17.0),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          SizedBox(
                              height: (MediaQuery.of(context).size.height * 0.1)
                                  .clamp(40.0, 90.0)),
                        ],
                      ),
                    ),
                  ),
                    )
                  ),
                ),
              ))),
    );
  }
}
