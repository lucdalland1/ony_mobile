import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/View/menuscreen.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import 'colors.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  final GetStorage storage = GetStorage();

  @override
  Widget build(BuildContext context) {
    final userInfo = storage.read('userInfo') ?? {};
    final nom = userInfo['name']?.toString() ?? '';
    final prenom = userInfo['prenom']?.toString() ?? '';

    
    // SizedBox(
//             width: 30.dp,
//             height: 30.dp,
//             child: Center(
//               child: ClipRRect(
//                 child: Image.asset(
//                   "asset/onylogo.png",
//                   height: 27.dp,
//                   width: 27.dp,
//                 ),
//               ),
//             ),
          // ),

    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
         SizedBox(
            width: 30.dp,
            height: 30.dp,
            child: Center(
              child: ClipRRect(
                child: Image.asset(
                  "asset/onylogo.png",
                  height: 27.dp,
                  width: 27.dp,
                ),
              ),
            ),
          ),
        const SizedBox(width: 10),
        Expanded(
          child: Center(
            child:Text('Accueil',style: TextStyle(color: C.primary, fontSize:14.sp,fontWeight: FontWeight.w800),)
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 38.dp,
          height: 38.dp,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: NotificationWidget(isWhite: false),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Get.find<GlobalDrawerController>().openDrawer(),
          child: const TopIcon(icon: Icons.more_vert),
        ),
      ],
    );
  }
}

// ─── Widget icône réutilisable ───────────────────────────────────────────────

class TopIcon extends StatelessWidget {
  final IconData icon;
  const TopIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38.dp,
      height:38.dp,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: C.textDark, size: 20),
    );
  }
}

// ─── Formatage du nom ────────────────────────────────────────────────────────

String formatNomPrenom(String prenom, String nom) {
  final firstPrenom = prenom.trim().split(' ').first;
  final formattedPrenom = firstPrenom.isNotEmpty
      ? firstPrenom[0].toUpperCase() + firstPrenom.substring(1).toLowerCase()
      : '';
  final formattedNom = nom.trim().toUpperCase();
  final fullName = '$formattedPrenom $formattedNom'.trim();

  // Troncature défensive — le Expanded + ellipsis gère déjà l'affichage,
  // mais on garde la limite pour les logs / accessibilité
  return fullName.length > 22 ? '${fullName.substring(0, 22)}…' : fullName;
}