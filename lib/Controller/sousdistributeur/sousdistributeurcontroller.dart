import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/model/sous_distributeur/sousdistributeurmodel.dart';

class HierarchySdController extends GetxController {
  final dio = Dio();
  final String endpoint =

      
      "${ApiEnvironmentController.to.baseUrl}/sous-distributeurs-visibles/hierarchie?indicatif=242";
  
  RxBool isLoading = false.obs;
  Rx<HierarchyModel?> hierarchy = Rx<HierarchyModel?>(null);
  
  final headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  @override
  void onInit() {
    fetchHierarchy();
    super.onInit();
  }

  Future<void> fetchHierarchy() async {
    try {
      isLoading(true);
      var response = await dio.get(
        endpoint,
        options: Options(headers: headers),
      );
      if (response.statusCode == 200) {
        print('\n\n\n\n');
        print(response.data);
        hierarchy.value = HierarchyModel.fromJson(response.data);
        print("📌📌📌📌📌📌📌 Hiérarchie chargée !");
      } else {
        print("❌❌❌❌❌❌ Erreur Serveur: ${response.statusMessage}");
      }
    } catch (e) {
      print("🔥🔥🔥🔥🔥 Exception FETCH HIERARCHY: $e");
    } finally {
      isLoading(false);
    }
  }

  /// Récupère l'offset UTC à partir du timezone string
  /// Ex: "Africa/Brazzaville" -> +1 heure
  int _getUtcOffsetFromTimezone(String? timezone) {
    if (timezone == null) return 1; // Congo par défaut: UTC+1
    
    // Map des fuseaux horaires principaux en Afrique
    final timezoneOffsets = {
      'Africa/Brazzaville': 1,
      'Africa/Kinshasa': 1,
      'Africa/Lagos': 1,
      'Africa/Luanda': 1,
      'Africa/Douala': 1,
      'Africa/Libreville': 1,
      'Africa/Bangui': 1,
      'Africa/Malabo': 1,
      'Africa/Niamey': 1,
      'Africa/Ndjamena': 1,
      'Africa/Tunis': 1,
      'Africa/Algiers': 1,
      'Africa/Cairo': 2,
      'Africa/Johannesburg': 2,
      'Africa/Maputo': 2,
      'Africa/Nairobi': 3,
      'Africa/Addis_Ababa': 3,
      'Africa/Dar_es_Salaam': 3,
    };
    
    return timezoneOffsets[timezone] ?? 1; // Défaut UTC+1
  }

  /// Récupère l'heure actuelle dans le fuseau horaire du distributeur
  DateTime getHeureLocaleDistributeur(SousDistributeur distributeur) {
    try {
      // Récupérer le timezone depuis la localisation GPS du distributeur
      final timezone = distributeur.localisationGps?.timezone;
      
      // Calculer l'offset UTC
      final offsetHours = _getUtcOffsetFromTimezone(timezone);
      
      // Obtenir l'heure UTC et ajouter l'offset
      final heureLocale = DateTime.now().toUtc().add(Duration(hours: offsetHours));
      
      print("🕐 Timezone: $timezone");
      print("🕐 Offset UTC: +$offsetHours heures");
      print("🕐 Heure locale calculée: $heureLocale");
      
      return heureLocale;
    } catch (e) {
      print("⚠️ Erreur lors de la récupération du timezone: $e");
      // Fallback: Congo (Brazzaville) UTC+1
      return DateTime.now().toUtc().add(const Duration(hours: 1));
    }
  }

  /// Vérifie si le sous-distributeur est réellement ouvert en fonction de l'heure locale
  /// Vérifie si le sous-distributeur est réellement ouvert en fonction de l'heure locale
/// Vérifie si le sous-distributeur est réellement ouvert en fonction de l'heure locale
bool isDistributeurActuellementOuvert(SousDistributeur distributeur) {
  final horaires = distributeur.horairesOuverture?.aujourdhui;
  
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🔴 CAS 1 : Pas d'horaires du tout → FERMÉ
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  if (horaires == null) {
    print("❌ Pas d'horaires → FERMÉ");
    return false;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🔴 CAS 2 : est_ouvert = false → FERMÉ (peu importe les heures)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  if (horaires.estOuvert == false) {
    print("❌ est_ouvert = false → FERMÉ");
    return false;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🟢 CAS 3 : est_ouvert = true + heures null → OUVERT 24H/24
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  if (horaires.estOuvert == true && 
      (horaires.heureOuverture == null || horaires.heureFermeture == null)) {
    print("✅ est_ouvert = true + heures null → OUVERT 24H/24");
    return true;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🔴 CAS 4 : est_ouvert = null + heures null → FERMÉ
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  if (horaires.estOuvert == null && 
      (horaires.heureOuverture == null || horaires.heureFermeture == null)) {
    print("❌ est_ouvert = null + heures null → FERMÉ");
    return false;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🕐 CAS 5 : Heures définies → CALCUL BASÉ SUR L'HEURE ACTUELLE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  if (horaires.heureOuverture != null && horaires.heureFermeture != null) {
    try {
      // Obtenir l'heure actuelle DANS LE FUSEAU HORAIRE DU DISTRIBUTEUR
      final now = getHeureLocaleDistributeur(distributeur);
      
      print("🕐 Heure locale du distributeur ${distributeur.nomComplet}: $now");
      
      // Parser les heures d'ouverture et de fermeture
      final heureOuvertureParts = horaires.heureOuverture!.split(':');
      final heureFermetureParts = horaires.heureFermeture!.split(':');
      
      // Créer les DateTime en UTC pour correspondre à 'now'
      final heureOuverture = DateTime.utc(
        now.year,
        now.month,
        now.day,
        int.parse(heureOuvertureParts[0]),
        int.parse(heureOuvertureParts[1]),
        heureOuvertureParts.length > 2 ? int.parse(heureOuvertureParts[2]) : 0,
      );
      
      final heureFermeture = DateTime.utc(
        now.year,
        now.month,
        now.day,
        int.parse(heureFermetureParts[0]),
        int.parse(heureFermetureParts[1]),
        heureFermetureParts.length > 2 ? int.parse(heureFermetureParts[2]) : 0,
      );

      print("🕐 Ouverture: ${horaires.heureOuverture} → $heureOuverture");
      print("🕐 Fermeture: ${horaires.heureFermeture} → $heureFermeture");
      print("🕐 Maintenant: $now");

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // Gérer le cas où la fermeture est après minuit (ex: 22:00 - 02:00)
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      if (heureFermeture.isBefore(heureOuverture)) {
        // Horaire sur 2 jours : ouvert si après l'ouverture OU avant la fermeture
        if (now.isAfter(heureOuverture) || now.isBefore(heureFermeture)) {
          print("✅ OUVERT (horaire après minuit)");
          return true;
        }
      } else {
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // Cas normal : même jour (ex: 08:00 - 18:00)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        if ((now.isAfter(heureOuverture) || now.isAtSameMomentAs(heureOuverture)) && 
            now.isBefore(heureFermeture)) {
          print("✅ OUVERT");
          return true;
        }
      }
      
      print("❌ FERMÉ (hors horaires)");
      return false;
      
    } catch (e) {
      print("⚠️ Erreur lors du parsing des horaires: $e");
      // En cas d'erreur de parsing, on se fie à est_ouvert si disponible
      return horaires.estOuvert ?? false;
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🔴 PAR DÉFAUT : FERMÉ
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  print("❌ Cas par défaut → FERMÉ");
  return false;
}
 
  /// Retourne un message détaillé sur le statut d'ouverture
  String getStatutDetaille(SousDistributeur distributeur) {
    final horaires = distributeur.horairesOuverture?.aujourdhui;
    
    if (horaires == null || horaires.estOuvert == false) {
      return 'Fermé aujourd\'hui';
    }

    if (horaires.heureOuverture == null || horaires.heureFermeture == null) {
      return 'Horaires non disponibles';
    }

    final isOpen = isDistributeurActuellementOuvert(distributeur);
    final now = getHeureLocaleDistributeur(distributeur);
    
    try {
      final heureOuvertureParts = horaires.heureOuverture!.split(':');
      final heureFermetureParts = horaires.heureFermeture!.split(':');
      
      final heureOuverture = DateTime(
        now.year, now.month, now.day,
        int.parse(heureOuvertureParts[0]),
        int.parse(heureOuvertureParts[1]),
      );
      
      final heureFermeture = DateTime(
        now.year, now.month, now.day,
        int.parse(heureFermetureParts[0]),
        int.parse(heureFermetureParts[1]),
      );

      if (isOpen) {
        final tempRestant = heureFermeture.difference(now);
        final heuresRestantes = tempRestant.inHours;
        final minutesRestantes = tempRestant.inMinutes % 60;
        
        if (heuresRestantes > 0) {
          return 'Ouvert • Ferme dans ${heuresRestantes}h${minutesRestantes}min';
        } else if (minutesRestantes > 0) {
          return 'Ouvert • Ferme dans ${minutesRestantes}min';
        } else {
          return 'Ouvert';
        }
      } else {
        if (now.isBefore(heureOuverture)) {
          final tempAvantOuverture = heureOuverture.difference(now);
          final heuresAvant = tempAvantOuverture.inHours;
          final minutesAvant = tempAvantOuverture.inMinutes % 60;
          
          if (heuresAvant > 0) {
            return 'Fermé • Ouvre dans ${heuresAvant}h${minutesAvant}min';
          } else if (minutesAvant > 0) {
            return 'Fermé • Ouvre dans ${minutesAvant}min';
          } else {
            return 'Fermé';
          }
        } else {
          return 'Fermé • Ouvre demain à ${horaires.heureOuverture}';
        }
      }
    } catch (e) {
      return isOpen ? 'Ouvert' : 'Fermé';
    }
  }
}