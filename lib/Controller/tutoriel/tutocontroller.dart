import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialController extends GetxController {
  // Clés globales pour les widgets que tu veux surligner
  final GlobalKey keyMenu = GlobalKey();
  final GlobalKey keyNameField = GlobalKey();
  final GlobalKey keyValidateButton = GlobalKey();

  // Le tutoriel coach mark
  late TutorialCoachMark tutorial;

  // Indique si le tutoriel a déjà été affiché
  final RxBool hasShown = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initTargets();
  }

  void _initTargets() {
    List<TargetFocus> targets = [
      TargetFocus(
        identify: "menu",
        keyTarget: keyMenu,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Text(
              "Voici le menu principal",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "nameField",
        keyTarget: keyNameField,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Text(
              "Ici, tu peux entrer ton nom.",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "validateButton",
        keyTarget: keyValidateButton,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Text(
              "Appuie ici pour valider",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    ];

    tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black.withOpacity(0.7),
      textSkip: "PASSER",
      onFinish: () => hasShown.value = true,
      onSkip: () => hasShown.value = true,
    );
  }

  // Affiche le tutoriel après que le widget soit rendu
  void showTutorial({required BuildContext context}) {
    if (hasShown.isFalse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        tutorial.show(context: context);
      });
    }
  }
}
