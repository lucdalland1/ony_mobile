import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:onyfast/Api/changerpassword.dart';
import 'package:onyfast/View/Coffre/widget/cofrewidegt.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/Color/app_color_model.dart';

class SecuritePage extends StatelessWidget {
  const SecuritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: globalColor,
        title: Text(
          "Sécurité",
          style: TextStyle(
            fontSize: 16.sp.clamp(15.0, 20.0),
            color: AppColorModel.WhiteColor,
          ),
        ),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: (4.w).clamp(16.0, 32.0),
                  vertical: (2.h).clamp(12.0, 24.0),
                ),
                child: Column(
                  children: [
                    SizedBox(height: (1.h).clamp(8.0, 16.0)),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildSettingItem(
                            Icons.fingerprint,
                            "Configurer Face ID / Empreinte",
                            () => showComingSoon(context),
                            0,
                            3,
                          ),
                          _buildSettingItem(
                            Icons.lock,
                            "Modifier le mot de passe",
                            () => Get.to(() => const ModifierMotDePassePage()),
                            1,
                            3,
                          ),
                          _buildSettingItem(
                            Icons.verified_user,
                            "Activer la double authentification",
                            () => showComingSoon(context),
                            2,
                            3,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: (2.h).clamp(12.0, 24.0)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    VoidCallback onTap,
    int index,
    int totalItems,
  ) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: (1.5.h).clamp(12.0, 20.0),
                horizontal: (4.w).clamp(16.0, 28.0),
              ),
              child: Row(
                children: [
                  // Icon container — fully clamped
                  Container(
                    width: (11.w).clamp(44.0, 52.0),
                    height: (11.w).clamp(44.0, 52.0),
                    decoration: BoxDecoration(
                      color: globalColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: globalColor,
                      size: (5.5.w).clamp(20.0, 26.0),
                    ),
                  ),

                  SizedBox(width: (3.w).clamp(10.0, 20.0)),

                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: (11.sp),
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        // letterSpacing: -0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      // maxLines: 2,
                    ),
                  ),

                  SizedBox(width: (2.w).clamp(8.0, 16.0)),

                  Icon(
                    CupertinoIcons.forward,
                    color: globalColor.withOpacity(0.6),
                    size: (4.w).clamp(16.0, 20.0),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (index < totalItems - 1)
          Padding(
            padding: EdgeInsets.only(left: (18.w).clamp(60.0, 90.0)),
            child: Divider(
              height: 1,
              thickness: 0.5,
              color: Colors.grey.shade300,
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Modifier mot de passe
// ─────────────────────────────────────────────
class ModifierMotDePassePage extends StatefulWidget {
  const ModifierMotDePassePage({super.key});

  @override
  State<ModifierMotDePassePage> createState() => _ModifierMotDePassePageState();
}

class _ModifierMotDePassePageState extends State<ModifierMotDePassePage> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Modifier le mot de passe",
          style: TextStyle(
            fontSize: (14.sp).clamp(14.0, 18.0),
            fontWeight: FontWeight.w600,
            color: AppColorModel.WhiteColor,
          ),
        ),
        backgroundColor: globalColor,
        centerTitle: true,
        leading: BackButton(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: (4.w).clamp(16.0, 32.0),
                  vertical: (2.h).clamp(12.0, 24.0),
                ),
                child: Column(
                  children: [
                    SizedBox(height: (2.h).clamp(12.0, 24.0)),

                    // Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all((5.w).clamp(16.0, 28.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Informations de sécurité",
                            style: TextStyle(
                              fontSize: (13.sp).clamp(14.0, 18.0),
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: (1.h).clamp(6.0, 12.0)),
                          Text(
                            "Votre code PIN doit contenir exactement 4 chiffres",
                            style: TextStyle(
                              fontSize: (10.sp).clamp(12.0, 15.0),
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: (3.h).clamp(16.0, 28.0)),
                          _buildPasswordField(
                            controller: oldPasswordController,
                            label: "Ancien code PIN (4 chiffres)",
                            icon: Icons.lock_outline,
                            obscureText: _obscureOld,
                            onToggle: () =>
                                setState(() => _obscureOld = !_obscureOld),
                            enabled: !_isLoading,
                          ),
                          SizedBox(height: (2.h).clamp(12.0, 20.0)),
                          _buildPasswordField(
                            controller: newPasswordController,
                            label: "Nouveau code PIN (4 chiffres)",
                            icon: Icons.lock,
                            obscureText: _obscureNew,
                            onToggle: () =>
                                setState(() => _obscureNew = !_obscureNew),
                            enabled: !_isLoading,
                          ),
                          SizedBox(height: (2.h).clamp(12.0, 20.0)),
                          _buildPasswordField(
                            controller: confirmPasswordController,
                            label: "Confirmer le code PIN",
                            icon: Icons.lock_clock,
                            obscureText: _obscureConfirm,
                            onToggle: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                            enabled: !_isLoading,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: (3.h).clamp(16.0, 28.0)),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: globalColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: (1.8.h).clamp(14.0, 20.0),
                          ),
                          elevation: 2,
                          shadowColor: globalColor.withOpacity(0.3),
                        ),
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: (3.w).clamp(10.0, 20.0)),
                                  Text(
                                    "Traitement...",
                                    style: TextStyle(
                                      fontSize: (12.sp).clamp(13.0, 16.0),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                "Enregistrer les modifications",
                                style: TextStyle(
                                  fontSize: (12.sp).clamp(13.0, 16.0),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: (2.h).clamp(12.0, 24.0)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (oldPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      SnackBarService.warning("Veuillez remplir tous les champs.");
      return;
    }

    if (newPasswordController.text.length != 4) {
      SnackBarService.warning(
          "Le code PIN doit contenir exactement 4 chiffres.");
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      SnackBarService.error("Les codes PIN ne correspondent pas.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final passwordService = PasswordService();
      final result = await passwordService.changePassword(
        oldPassword: oldPasswordController.text,
        newPassword: newPasswordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (result['success'] == true) {
          SnackBarService.success(
              result['message'] ?? "Code PIN modifié avec succès.");

          oldPasswordController.clear();
          newPasswordController.clear();
          confirmPasswordController.clear();

          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) Get.back();
          });
        } else {
          SnackBarService.warning(
              result['message'] ?? "Une erreur est survenue.");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackBarService.info(
            "Une erreur inattendue est survenue. Veuillez réessayer.");
      }
    }
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscureText,
    required VoidCallback onToggle,
    required bool enabled,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: TextInputType.number,
      maxLength: 4,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      style: TextStyle(
        fontSize: (11.sp).clamp(14.0, 18.0),
        // Responsive letterSpacing: tighter on small screens to avoid overflow
        letterSpacing: (8.w).clamp(4.0, 10.0),
        color: enabled ? Colors.black87 : Colors.grey[400],
      ),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: (11.sp).clamp(12.0, 15.0),
          color: Colors.grey[600],
        ),
        prefixIcon: Icon(
          icon,
          color: enabled ? globalColor : Colors.grey[400],
          size: (5.w).clamp(20.0, 24.0),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: enabled ? Colors.grey[600] : Colors.grey[400],
            size: (5.w).clamp(20.0, 24.0),
          ),
          onPressed: enabled ? onToggle : null,
        ),
        counterText: "",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: globalColor, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        filled: true,
        fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
        contentPadding: EdgeInsets.symmetric(
          horizontal: (4.w).clamp(14.0, 24.0),
          vertical: (1.5.h).clamp(12.0, 18.0),
        ),
      ),
    );
  }
}
