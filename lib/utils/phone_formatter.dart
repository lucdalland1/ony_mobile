// Utilitaire pour le formatage des numéros de téléphone
// À ajouter dans un fichier utils/phone_formatter.dart

class PhoneFormatter {
  // Code pays par défaut (Congo)
  static const String DEFAULT_COUNTRY_CODE = '242';

  /// Formate un numéro de téléphone selon les standards congolais
  /// Gère tous les formats possibles trouvés dans les contacts
  static String formatPhoneNumber(String phone, {String? countryCode}) {
    if (phone.isEmpty) return '';

    final defaultCode = countryCode ?? DEFAULT_COUNTRY_CODE;

    // Nettoyer le numéro : supprimer espaces, tirets, parenthèses
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Supprimer le + au début s'il existe pour traitement uniforme
    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }

    // Debug: afficher le numéro nettoyé
    print('📞 Formatage: "$phone" → "$cleaned"');

    // Cas 1: Numéro local commençant par 0 (ex: 06 12 34 56 78, 05123456)
    if (cleaned.startsWith('0')) {
      String localNumber = cleaned.substring(1);
      // Vérifier que le numéro local est valide (au moins 8 chiffres)
      if (localNumber.length >= 8) {
        return '+$defaultCode$localNumber';
      }
      return ''; // Numéro trop court
    }

    // Cas 2: Numéro avec code pays Congo déjà présent (ex: 24206123456, +24205123456)
    else if (cleaned.startsWith(defaultCode)) {
      // Vérifier que le numéro complet est valide
      if (cleaned.length >= 11) {
        // 242 + 8 chiffres minimum
        return '+$cleaned';
      }
      return ''; // Numéro trop court
    }

    // Cas 3: Numéro international avec autre code pays (ex: 33123456789, 1234567890)
    else if (cleaned.length >= 10 && !cleaned.startsWith(defaultCode)) {
      // Vérifier si c'est un code pays connu
      if (_isValidInternationalNumber(cleaned)) {
        return '+$cleaned';
      }
      // Si pas reconnu comme international, traiter comme numéro local
      if (cleaned.length >= 8 && cleaned.length <= 9) {
        return '+$defaultCode$cleaned';
      }
      return '+$cleaned'; // Garder tel quel par sécurité
    }

    // Cas 4: Numéro local sans 0 et sans code pays (ex: 6123456, 12345678)
    else if (cleaned.length >= 8 && cleaned.length <= 9) {
      return '+$defaultCode$cleaned';
    }

    // Cas 5: Numéro court (probablement invalide)
    else if (cleaned.length < 8) {
      print('⚠️ Numéro trop court ignoré: $phone');
      return ''; // Ignorer les numéros trop courts
    }

    // Cas par défaut : traiter comme numéro local
    return '+$defaultCode$cleaned';
  }

  /// Vérifie si un numéro semble être un numéro international valide
  static bool _isValidInternationalNumber(String number) {
    // Codes pays courants (liste non exhaustive)
    final commonCountryCodes = [
      '1', // USA/Canada
      '33', // France
      '32', // Belgique
      '41', // Suisse
      '49', // Allemagne
      '44', // Royaume-Uni
      '39', // Italie
      '34', // Espagne
      '351', // Portugal
      '212', // Maroc
      '213', // Algérie
      '216', // Tunisie
      '221', // Sénégal
      '225', // Côte d'Ivoire
      '226', // Burkina Faso
      '227', // Niger
      '228', // Togo
      '229', // Bénin
      '230', // Maurice
      '231', // Liberia
      '232', // Sierra Leone
      '233', // Ghana
      '234', // Nigeria
      '235', // Tchad
      '236', // République Centrafricaine
      '237', // Cameroun
      '238', // Cap-Vert
      '239', // São Tomé-et-Principe
      '240', // Guinée équatoriale
      '241', // Gabon
      '243', // RD Congo
      '244', // Angola
      '245', // Guinée-Bissau
      '246', // Diego Garcia
      '247', // Ascension
      '248', // Seychelles
      '249', // Soudan
      '250', // Rwanda
      '251', // Éthiopie
      '252', // Somalie
      '253', // Djibouti
      '254', // Kenya
      '255', // Tanzanie
      '256', // Ouganda
      '257', // Burundi
      '258', // Mozambique
    ];

    return commonCountryCodes.any((code) => number.startsWith(code));
  }

  /// Normalise un numéro pour la comparaison (retire le +)
  static String normalizeForComparison(String phone) {
    String formatted = formatPhoneNumber(phone);
    if (formatted.startsWith('+')) {
      return formatted.substring(1);
    }
    return formatted;
  }

  /// Valide qu'un numéro est au format international correct
  static bool isValidPhoneNumber(String phone) {
    String formatted = formatPhoneNumber(phone);
    return formatted.isNotEmpty &&
        formatted.startsWith('+') &&
        formatted.length >= 10;
  }

  /// Extrait tous les numéros valides d'un contact
  static List<String> extractValidNumbers(List<String> phoneNumbers) {
    List<String> validNumbers = [];

    for (String phone in phoneNumbers) {
      String formatted = formatPhoneNumber(phone);
      if (formatted.isNotEmpty && !validNumbers.contains(formatted)) {
        validNumbers.add(formatted);
      }
    }

    return validNumbers;
  }

  /// Formate pour l'affichage (avec espaces)
  static String formatForDisplay(String phone) {
    String formatted = formatPhoneNumber(phone);
    if (formatted.isEmpty) return phone;

    // Format d'affichage : +242 06 123 456 78
    if (formatted.startsWith('+242') && formatted.length >= 12) {
      String local = formatted.substring(4); // Enlever +242
      if (local.length >= 9) {
        return '+242 ${local.substring(0, 2)} ${local.substring(2, 5)} ${local.substring(5, 8)} ${local.substring(8)}';
      }
    }

    return formatted;
  }
}
