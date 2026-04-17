import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:onyfast/Controller/verou/verroucontroller.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/Widget/dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:onyfast/Controller/parametre/localisationcontroller.dart';

class Localisationview extends StatefulWidget {
  const Localisationview({super.key});

  @override
  State<Localisationview> createState() => _LocalisationviewState();
}

class _LocalisationviewState extends State<Localisationview>
    with WidgetsBindingObserver {
  final LocationController _locationController = Get.put(LocationController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppSettingsController.to.setInactivity(true);

    // Vérifier nativement les permissions au chargement de la vue
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _locationController.checkNativeLocationPermission();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    AppSettingsController.to.setInactivity(true);
  }

  // Rafraîchir le statut quand l'utilisateur revient de l'app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _locationController.refreshPermissionStatus();
    }
  }

  /// Gérer le clic sur le switch
  Future<void> _handleLocationToggle(bool wantsToEnable) async {
    AppSettingsController.to.setInactivity(true);
    if (wantsToEnable) {
      // L'utilisateur veut activer -> demander la permission
      bool success = await _locationController.enableLocation();

      if (success) {
        SnackBarService.success(
          'Localisation activée'
          'La localisation a été activée avec succès.',
        );
      }
    } else {
      // L'utilisateur veut désactiver -> rediriger vers les paramètres
      _showDisableDialog();
    }
    AppSettingsController.to.setInactivity(false);
  }

  /// Dialog pour expliquer comment désactiver
  void _showDisableDialog() {


   Get.dialog(
  AppDialog(
    title: "Désactiver la localisation",
    body: 'Pour des raisons de sécurité, vous devez désactiver '
          'la permission de localisation dans les paramètres du téléphone.\n\n'
          'Voulez-vous ouvrir les paramètres maintenant ?',
    actions: [
      AppDialogAction(
        label: "Annuler",
        onPressed: () => Get.back(),
      ),
      AppDialogAction(
        label: "Oui",
        isDefault: true,
        onPressed: () {
          Get.back();
          openAppSettings();
          // ta logique ici
        },
      ),
    ],
  ),
);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: globalColor,
        title: Text(
          'Paramètres de localisation',
          style: TextStyle(
            color: AppColorModel.WhiteColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Section Localisation
              Obx(() {
                return Card(
                  margin: EdgeInsets.zero,
                  elevation: 2,
                  child: SwitchListTile(
                    
                    title:  Text(
                      'Activer la localisation',
                      style: TextStyle(fontWeight: FontWeight.w600,
                      fontSize: 10.sp),
                    ),
                    subtitle: Text(
                      _locationController.isLocationEnabled.value
                          ? 'Position autorisée ✓'
                          : 'Autoriser l\'accès à la position',
                      style: TextStyle(
                        color: _locationController.isLocationEnabled.value
                            ? Colors.green
                            : Colors.grey,
                        fontSize: 9.sp,
                      ),
                    ),
                    value: _locationController.isLocationEnabled.value,
                    onChanged: _handleLocationToggle,
                    secondary: Icon(
                      size: 9.sp,
                      _locationController.isLocationEnabled.value
                          ? Icons.location_on
                          : Icons.location_off,
                      color: _locationController.isLocationEnabled.value
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Info card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pour désactiver la localisation, utilisez les paramètres de votre téléphone',
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: Colors.blue.shade900,
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
    );
  }
}
