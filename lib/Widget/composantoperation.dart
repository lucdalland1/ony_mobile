import 'package:backdrop_modal_route/backdrop_modal_route.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:onyfast/View/Operation/achatCredit.dart';
import 'package:onyfast/Widget/containerOperation.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../Color/app_color_model.dart';
import '../Controller/languescontroller.dart';
import 'container.dart';

class ComposantOperation extends StatelessWidget {
  const ComposantOperation({
    super.key,
    required this.appState,
  });

  final AppController appState;

  SliverWoltModalSheetPage page1(
      BuildContext modalSheetContext, TextTheme textTheme) {
    return WoltModalSheetPage(
        hasSabGradient: false,
        stickyActionBar: Padding(
          padding: const EdgeInsets.all(10),
        ),
        topBarTitle: Text('Mes points', style: textTheme.titleSmall),
        isTopBarLayerAlwaysVisible: true,
        trailingNavBarWidget: IconButton(
          icon: const Icon(Icons.close),
          onPressed: Navigator.of(modalSheetContext).pop,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Distribution des Points par Opération",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Gap(5),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 10, top: 1, bottom: 0),
                child: Row(
                  children: [
                    ContainerWidget(
                      height: 20,
                      width: 55,
                      color: AppColorModel.Blue,
                    ),
                    Gap(5),
                    Text(
                      "c2c",
                      style: TextStyle(fontSize: 14),
                    ),
                    Gap(10),
                    ContainerWidget(
                      height: 20,
                      width: 55,
                      color: AppColorModel.YellowColor,
                    ),
                    Gap(5),
                    Text(
                      "retrait",
                      style: TextStyle(fontSize: 14),
                    ),
                    Gap(10),
                    ContainerWidget(
                      height: 20,
                      width: 55,
                      color: AppColorModel.BlueSimple,
                    ),
                    Gap(5),
                    Text(
                      "virement CEMAC",
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(10),
              Padding(
                padding: const EdgeInsets.only(
                    left: 30, right: 10, top: 10, bottom: 10),
                child: Row(
                  children: [
                    ContainerWidget(
                      borderRadius: BorderRadius.circular(10),
                      height: 90,
                      width: 160,
                      color: AppColorModel.WhiteColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                      child: Column(
                        children: [
                          Gap(12),
                          Text(
                            "📊",
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            "Nombre d'opérations",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "6",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    Gap(10),
                    ContainerWidget(
                      borderRadius: BorderRadius.circular(10),
                      height: 90,
                      width: 160,
                      color: AppColorModel.blackColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                      child: Column(
                        children: [
                          Gap(12),
                          Text(
                            "🎯",
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            "Nombre de points",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColorModel.WhiteColor),
                          ),
                          Text(
                            "33",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: AppColorModel.WhiteColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Gap(10),
              ContainerWidget(
                borderRadius: BorderRadius.circular(10),
                height: 40,
                width: 200,
                color: AppColorModel.WhiteColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
                child: Column(
                  children: [
                    Gap(12),
                    Text(
                      "🎯",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      "Nombre de points",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColorModel.WhiteColor),
                    ),
                    Text(
                      "33",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: AppColorModel.WhiteColor),
                    ),
                  ],
                ),
              ),
              Gap(90),
            ],
          ),
        ));
  }

   void handleCustomizedBackdropContent(BuildContext context) async {
    await Navigator.push(
      context,
      BackdropModalRoute<void>(
        overlayContentBuilder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height - 100.0,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Customized Backdrop Modal'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Barrier Dismiss Disabled'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ],
            ),
          );
        },
        topPadding: 100.0,
        barrierColorVal: Colors.deepPurple,
        backgroundColor: Colors.amberAccent,
        backdropShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(60),
            topRight: Radius.circular(60),
            bottomLeft: Radius.circular(200),
            bottomRight: Radius.circular(200),
          ),
        ),
        barrierLabelVal: 'Customized Backdrop',
        shouldMaintainState: false,
        canBarrierDismiss: false,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      top: screenHeight * 0.49,
      left: screenWidth * 0.06,
      child: ContainerWidget(
        height: screenHeight * 0.32,
        width: screenWidth * 0.9,
        borderRadius: BorderRadius.circular(20),
        color: AppColorModel.BlueWhiteColor,
        child: Column(
          children: [
            Gap(screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ContainerOPeration(
                    height: screenHeight * 0.05,
                    width: screenWidth * 0.400,
                    onTap: () {
                      Navigator.pushNamed(context, "/virement");
                      ;
                    },
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    appState: appState,
                    text: "Virement CEMAC"),
                Gap(screenWidth * 0.02),
                ContainerOPeration(
                    height: screenHeight * 0.05,
                    width: screenWidth * 0.380,
                    onTap: () {
                      Navigator.pushNamed(context, "/paiement");
                    },
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    appState: appState,
                    text: "Paiement de facture"),
              ],
            ),
            Gap(screenHeight * 0.01),
            ContainerOPeration(
                height: screenHeight * 0.05,
                width: screenWidth * 0.8,
                onTap: () {},
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                appState: appState,
                text: "Transfert d'argent vers un autre compte"),
            Gap(screenHeight * 0.01),
            ContainerOPeration(
                height: screenHeight * 0.05,
                width: screenWidth * 0.8,
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AchatCredit()));
                },
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                appState: appState,
                text: "Achat de crédit (MTN, Airtel)"),
            Gap(screenHeight * 0.01),
            ContainerOPeration(
                height: screenHeight * 0.05,
                width: screenWidth * 0.8,
                onTap: () {
                  WoltModalSheet.show<void>(
                      context: context,
                      pageListBuilder: (modalSheetContext) {
                        final textTheme = Theme.of(context).textTheme;
                        return [
                          page1(modalSheetContext, textTheme),
                        ];
                      });
                  ;
                },
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                appState: appState,
                text: "Mes points"),
            Gap(screenHeight * 0.01),
            ContainerOPeration(
                height: screenHeight * 0.05,
                width: screenWidth * 0.8,
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AchatCredit()));
                },
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                appState: appState,
                text: "Support Technique"),
          ],
        ),
      ),
    );
  }
}
