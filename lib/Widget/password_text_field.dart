import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Color/app_color_model.dart';
import '../Controller/languescontroller.dart';

// Contrôleur pour gérer la visibilité du mot de passe
class PasswordVisibilityController extends GetxController {
  var isVisible = false.obs; // État réactif pour la visibilité du mot de passe

  void toggleVisibility() {
    isVisible.value = !isVisible.value;
  }
}

class PasswordTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String title;
  final IconData? prefixIcon;
  final Color fillColor;
  final String placeHolder;
  final Color hintColor;
  final Color? titleColor;
  final String? labelText;
  final double width;
  final double height;
  final bool expands;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool autofocus;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;

  const PasswordTextField({
    required this.labelText,
    super.key,
    required this.controller,
    String? title,
    this.prefixIcon,
    Color? fillColor,
    this.onChanged,
    String? placeHolder,
    Color? hintColor,
    this.titleColor,
    double? width,
    double? height,
    bool? expands,
    bool? enabled,
    bool? autofocus,
    this.focusNode,
    this.maxLines,
    this.minLines,
    this.maxLength,
  })  : fillColor = fillColor ?? Colors.white,
        hintColor = hintColor ?? Colors.black,
        placeHolder = placeHolder ?? '',
        width = width ?? double.infinity,
        height = height ?? 80,
        expands = expands ?? false,
        enabled = enabled ?? true,
        autofocus = autofocus ?? false,
        title = title ?? '';

  @override
  Widget build(BuildContext context) {
    final PasswordVisibilityController visibilityController = Get.put(PasswordVisibilityController());

    // Obtenir les dimensions de l'écran
    final double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: height,
      width: width == double.infinity ? screenWidth * 0.8 : width, // 80% de la largeur de l'écran par défaut
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              color: titleColor ?? AppColorModel.secondaryColor,
              fontSize: screenWidth * 0.04, // Taille de police réactive
            ),
          ),
          const SizedBox(height: 5),
          Obx(() {
            return TextField(
              focusNode: focusNode,
              expands: expands,
              minLines: expands ? null : minLines,
              maxLines: expands ? null : maxLines ?? 1,
              maxLength: maxLength ?? null,
              enableSuggestions: true,
              keyboardType: TextInputType.visiblePassword,
              obscureText: !visibilityController.isVisible.value,
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: EdgeInsets.only(
                  left: prefixIcon == null ? 15 : 0,
                  top: prefixIcon == null ? 5 : 10,
                  right: 1,
                  bottom: prefixIcon == null ? 5 : 0,
                ),
                prefixIcon: prefixIcon != null
                    ? Icon(
                        prefixIcon,
                        color: AppColorModel.black,
                      )
                    : null,
                suffixIcon: IconButton(
                  onPressed: () {
                    visibilityController.toggleVisibility(); // Basculer la visibilité
                  },
                  icon: Icon(
                    visibilityController.isVisible.value ? Icons.visibility : Icons.visibility_off,
                    size: 20,
                    color: AppColorModel.black,
                  ),
                ),
                suffixIconConstraints: BoxConstraints(maxHeight: 35, maxWidth: 35),
                labelText: labelText,
                hintText: placeHolder,
                hintStyle: TextStyle(color: hintColor),
                filled: true,
                fillColor: fillColor,
              ),
              controller: controller,
              onChanged: onChanged,
            );
          }),
        ],
      ),
    );
  }
}