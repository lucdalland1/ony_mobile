import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:onyfast/Controller/Abonnement/Abonnementencourscontroller.dart';
import 'package:onyfast/View/const.dart';

void showSubscriptionDetails(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) => Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 20),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header avec icône
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        couleurAbonnement(AbonnementEncoursController
                                    .to.abonnement.value?.type ??
                                '')
                            .withOpacity(0.2),
                        couleurAbonnement(AbonnementEncoursController
                                    .to.abonnement.value?.type ??
                                '')
                            .withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.star_circle_fill,
                    size: 50,
                    color: couleurAbonnement(AbonnementEncoursController
                                .to.abonnement.value?.type ??
                            "")
                        .withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Abonnement ${AbonnementEncoursController.to.abonnement.value?.type ?? 'Non défini'}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: couleurAbonnement(
                        AbonnementEncoursController.to.abonnement.value?.type ??
                            ""),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AbonnementEncoursController
                                      .to.abonnement.value?.statut
                                      .toLowerCase()
                                      .replaceAll(' ', '') ==
                                  'actif'
                              ? Colors.green
                              : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        AbonnementEncoursController
                                .to.abonnement.value?.statut ??
                            '',
                        style: TextStyle(
                          color: AbonnementEncoursController
                                      .to.abonnement.value?.statut
                                      .toLowerCase()
                                      .replaceAll(' ', '') ==
                                  'actif'
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 9.sp
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // Détails de l'abonnement
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                _subscriptionInfoRow(
                  icon: CupertinoIcons.calendar,
                  label: 'Date de début',
                  value: dateEnLettres(AbonnementEncoursController
                          .to.abonnement.value?.dateDebut ??
                      ''),
                ),
                SizedBox(height: 16),
                _subscriptionInfoRow(
                  icon: CupertinoIcons.calendar_badge_plus,
                  label: 'Date d\'expiration',
                  value: dateEnLettres(AbonnementEncoursController
                          .to.abonnement.value?.dateFin ??
                      ''),
                ),
                SizedBox(height: 16),
                _subscriptionInfoRow(
                  icon: CupertinoIcons.creditcard,
                  label: 'Prix',
                  value:
                      '${AbonnementEncoursController.to.abonnement.value?.prixMensuel ?? 'Non défini'} / mois',
                ),
                SizedBox(height: 16),
                _subscriptionInfoRow(
                  icon: CupertinoIcons.checkmark_seal_fill,
                  label: 'Type d\'abonnement',
                  value:
                      AbonnementEncoursController.to.abonnement.value?.type ??
                          'Non défini',
                ),
                SizedBox(height: 24),

                // Avantages
                // Text(
                //   'Avantages inclus',
                //   style: TextStyle(
                //     fontSize: 18,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.black,
                //   ),
                // ),
                // SizedBox(height: 12),
                // _advantageItem('Transactions illimitées'),
                // _advantageItem('Support prioritaire 24/7'),
                // _advantageItem('Frais réduits'),
                // _advantageItem('Accès aux fonctionnalités avancées'),
              ],
            ),
          ),

          // Bouton fermer
          Padding(
            padding: EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: globalColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Fermer',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _subscriptionInfoRow({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: globalColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: globalColor,
            size: 22,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _advantageItem(String text) {
  return Padding(
    padding: EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(
          CupertinoIcons.checkmark_circle_fill,
          color: Colors.green,
          size: 20,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
      ],
    ),
  );
}

IconData iconAbonnement(String a) {
  a = a.toLowerCase().replaceAll(RegExp(r'\s+'), '');

  switch (a) {
    case 'basic':
      return Icons.star_border;

    case 'premium':
      return Icons.star;

    case 'elite':
      return Icons.workspace_premium;

    default:
      return Icons.help_outline;
  }
}

Color couleurAbonnement(String? a) {
  final value = (a ?? '').trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');

  switch (value) {
    case 'basic':
      return Colors.grey[900]!;

    case 'premium':
      return Color(0xFF1234A0);

    case 'elite':
      return Colors.orange;

    case 'vip':
      return Colors.deepPurple;

    default:
      return Colors.blueGrey;
  }
}

/// Transforme une date au format String (ex: "2026-01-27") en lettres (ex: "27 janvier 2026")
String dateEnLettres(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) {
    return 'Date non disponible';
  }

  try {
    final date = DateTime.parse(dateStr);

    // Mois en français
    const moisFrancais = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre'
    ];

    return '${date.day} ${moisFrancais[date.month - 1]} ${date.year}';
  } catch (e) {
    print("❌ Erreur parsing date '$dateStr' : $e");
    return 'Date invalide';
  }
}
