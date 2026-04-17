import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/verifier_identite/type_piece.dart';

/// Modèle de retour du popup
class JustificatifResult {
  final String typePieceId;
  final String numeroPiece;

  JustificatifResult({
    required this.typePieceId,
    required this.numeroPiece,
  });

  @override
  String toString() {
    return 'JustificatifResult(typePieceId: $typePieceId, numeroPiece: $numeroPiece)';
  }
}

/// Controller pour le popup
class PopupJustificatifController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final numeroController = TextEditingController();
  final typePieceController = Get.find<TypePieceController>();
  
  final selectedTypeId = RxnString();

  @override
  void onInit() {
    super.onInit();
    // Charger les types de pièces si pas déjà chargé
    if (typePieceController.listeTypePieces.isEmpty) {
      typePieceController.getAllTypePieces();
    }
  }

  @override
  void onClose() {
    numeroController.dispose();
    super.onClose();
  }

  /// Validation du numéro
  String? validateNumero(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir le numéro de la pièce';
    }
    if (value.length < 5) {
      return 'Le numéro doit contenir au moins 5 caractères';
    }
    return null;
  }

  /// Validation du type
  String? validateType(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez sélectionner un type de pièce';
    }
    return null;
  }

  /// Valider et retourner le résultat
  JustificatifResult? validate() {
    if (!formKey.currentState!.validate()) {
      return null;
    }

    if (selectedTypeId.value == null || selectedTypeId.value!.isEmpty) {
      Get.snackbar(
        'Champ requis',
        'Veuillez sélectionner un type de pièce',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return null;
    }

    return JustificatifResult(
      typePieceId: selectedTypeId.value!,
      numeroPiece: numeroController.text.trim().toUpperCase(),
    );
  }
}

/// Widget du popup
class PopupJustificatifIdentite extends StatelessWidget {
  const PopupJustificatifIdentite({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(PopupJustificatifController());

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo[600],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.badge, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Pièce d\'identité',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Body
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: ctrl.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info message
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Renseignez les informations de votre pièce d\'identité',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Type de pièce
                    Text(
                      'Type de pièce d\'identité *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      final typePieces = ctrl.typePieceController.listeTypePieces;

                      if (typePieces.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[50],
                          ),
                          child: const Center(
                            child: CupertinoActivityIndicator(),
                          ),
                        );
                      }

                      return DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: typePieces.any((e) => e.id.toString() == ctrl.selectedTypeId.value)
                            ? ctrl.selectedTypeId.value
                            : null,
                        decoration: InputDecoration(
                          hintText: 'Sélectionnez un type de pièce',
                          prefixIcon: Icon(Icons.badge, color: Colors.indigo[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        items: typePieces.map((piece) {
                          return DropdownMenuItem<String>(
                            value: piece.id.toString(),
                            child: Text(piece.designation),
                          );
                        }).toList(),
                        onChanged: (value) {
                          ctrl.selectedTypeId.value = value;
                        },
                        validator: ctrl.validateType,
                      );
                    }),

                    const SizedBox(height: 24),

                    // Numéro de pièce
                    Text(
                      'Numéro de la pièce *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: ctrl.numeroController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Ex: ABC123456',
                        prefixIcon: Icon(Icons.perm_identity, color: Colors.indigo[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: ctrl.validateNumero,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(30),
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.grey[400]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Annuler',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              final result = ctrl.validate();
                              if (result != null) {
                                Get.back(result: result);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo[600],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'VALIDER',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      
        )
      
      ),
    );
  }
}

/// Fonction pour afficher le popup et récupérer le résultat
Future<JustificatifResult?> showJustificatifPopup() async {
  return await Get.dialog<JustificatifResult>(
    const PopupJustificatifIdentite(),
    barrierDismissible: false,
  );
}

/// ============================================
/// EXEMPLE D'UTILISATION
/// ============================================
/// 
/// Dans votre code, appelez simplement :
/// 
/// ```dart
/// // Afficher le popup
/// final result = await showJustificatifPopup();
/// 
/// // Utiliser le résultat
/// if (result != null) {
///   print('Type de pièce ID: ${result.typePieceId}');
///   print('Numéro de pièce: ${result.numeroPiece}');
///   
///   // Exemple: Utiliser dans votre payload
///   final payload = {
///     'type_piece_id': result.typePieceId,
///     'numero_piece': result.numeroPiece,
///     // ... autres champs
///   };
/// } else {
///   print('Utilisateur a annulé');
/// }
/// ```
/// 
/// ============================================