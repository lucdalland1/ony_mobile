import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:onyfast/Api/changepasswordAPi.dart';

class ChangePasswordController extends GetxController {
  final newPassword = ''.obs;
  final confirmPassword = ''.obs;
  final isLoading = false.obs;

  bool get isFormValid =>
      newPassword.value.length == 4 &&
      confirmPassword.value.length == 4 &&
      newPassword.value == confirmPassword.value &&
      newPassword.value != '1234';

  void showLoadingDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CupertinoAlertDialog(
        title: Text('Chargement'),
        content: Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: CupertinoActivityIndicator(radius: 14),
        ),
      ),
    );
  }

  void hideLoadingDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}

class Resetpassword extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<Resetpassword>
    with TickerProviderStateMixin {
  final ChangePasswordController controller = Get.put(ChangePasswordController());
  late AnimationController _animationController;
  double _yPosition = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _startAnimation();
  }

  void _startAnimation() {
    _animationController.forward().then((_) {
      if (mounted) {
        setState(() {
          _yPosition = _yPosition == 0 ? 10 : 0;
        });
        _animationController.reset();
        _startAnimation();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final inputFormatters = [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(4),
    ];

    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 400 : double.infinity,
                  ),
                  child: Obx(() => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 60),
                          
                          // Logo inspiré du design login
                          Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    "asset/onylogo.png",
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Titre comme dans le design login
                          const Text(
                            'Définir le code PIN',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Champ nouveau code - style inspiré du login
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              inputFormatters: inputFormatters,
                              onChanged: (value) => controller.newPassword.value = value,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF374151),
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Nouveau code (4 chiffres)',
                                hintStyle: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 16,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Champ confirmer code - style inspiré du login
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              inputFormatters: inputFormatters,
                              onChanged: (value) => controller.confirmPassword.value = value,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF374151),
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Confirmer le code',
                                hintStyle: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 16,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Bouton style login
                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: controller.isFormValid
                                  ? const LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 36, 28, 180), // Violet-bleu
                                        Color(0xFF3B82F6), // Bleu
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: controller.isFormValid 
                                  ? null 
                                  : const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: controller.isFormValid
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF4F46E5).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: controller.isFormValid
                                    ? () async {
                                        controller.showLoadingDialog(context);
                                        await ResetPasswordService().resetPassword(
                                          context: context,
                                          password: controller.newPassword.value,
                                          confirmPassword: controller.confirmPassword.value,
                                        );
                                        controller.hideLoadingDialog();
                                      }
                                    : null,
                                borderRadius: BorderRadius.circular(12),
                                child: Center(
                                  child: Text(
                                    'Valider',
                                    style: TextStyle(
                                      color: controller.isFormValid 
                                          ? Colors.white 
                                          : const Color(0xFF9CA3AF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 60),
                        ],
                      )),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}