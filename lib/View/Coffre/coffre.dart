import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/Controller/CoffreController.dart';
import 'package:onyfast/Route/route.dart';
import 'package:onyfast/View/Coffre/ajoutercoffre.dart';
import 'package:onyfast/View/Coffre/model/coffreModel.dart';
import 'package:onyfast/View/Coffre/widget/cofrewidegt.dart';
import 'package:onyfast/View/Coffre/widget/processBar.dart';
import 'package:onyfast/View/Notification/notification.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Widget/container.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import 'package:onyfast/verificationcode.dart';

class CoffreAccueilScreen extends StatefulWidget {
  const CoffreAccueilScreen({super.key});

  @override
  State<CoffreAccueilScreen> createState() => _CoffreAccueilScreenState();
}

class _CoffreAccueilScreenState extends State<CoffreAccueilScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isScrolled = false;
  String _searchQuery = '';
  late CoffreController controller;

  @override
  void initState() {
    controller = Get.put(CoffreController());
    controller.fetchCoffre();
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    const threshold = 100.0;

    if (offset > threshold && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (offset <= threshold && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase().trim();
    });
  }

  List<dynamic> _filteredObjectifs(List<dynamic> objectifs) {
    if (_searchQuery.isEmpty) {
      return objectifs;
    }

    return objectifs.where((obj) {
      final nom = obj.nom?.toString().toLowerCase() ?? '';

      // Filtrage principal sur le nom de l'objectif
      return nom.contains(_searchQuery);
    }).toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // controller.fetchCoffre();
    return Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(onTap: () {
          FocusScope.of(context).unfocus();
        }, child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
                child: CupertinoActivityIndicator(
              radius: 30,
              color: globalColor,
            ));
          }
          if (controller.coffre.value == null) {
            controller.fetchCoffre();
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  expandedHeight: 9.h,
                  leading: BackButton(color: Colors.white),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF002366), Color(0xFF0F52BA)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: FlexibleSpaceBar(
                      centerTitle: true,
                      title: !_isScrolled
                          ?  Text('Coffre Onyfast',
                              style: TextStyle(
                                fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white))
                          : null,
                      titlePadding: EdgeInsets.only(bottom: 2.h),
                    ),
                  ),
                  title: _isScrolled
                      ?  Text('Coffre Onyfast',
                          style: TextStyle(
                            fontSize: 16.sp,
                              fontWeight: FontWeight.bold, color: Colors.white))
                      : null,
                ),

                // Utiliser SliverFillRemaining pour occuper l'espace restant
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    color: Colors.white,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icône simple
                            Icon(
                              Icons.wifi_off,
                              size: 80,
                              color: Colors.red.shade600,
                            ),

                            const SizedBox(height: 30),

                            // Titre
                            Text(
                              'Connexion Impossible',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 15),

                            // Message
                            Text(
                              'Vérifiez votre connexion internet\net réessayez',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 40),

                            // Bouton principal
                            ElevatedButton.icon(
                              onPressed: () {
                                controller.fetchCoffre();
                              },
                              icon: const Icon(Icons.refresh,
                                  color: Colors.white),
                              label:  Text(
                                'Réessayer',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F52BA),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return _body();
        })));
  }

  CustomScrollView _body() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          pinned: true,
          floating: true,
          expandedHeight: 9.h,
          leading: BackButton(color: Colors.white),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF002366), Color(0xFF0F52BA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: FlexibleSpaceBar(
              centerTitle: true,
              title: !_isScrolled
                  ? const Text('Coffre Onyfast',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white))
                  : null,
              titlePadding: EdgeInsets.only(bottom: 2.h),
            ),
          ),
          title: _isScrolled
              ? const Text('Coffre Onyfast',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white))
              : null,
          actions: _isScrolled
              ? [
                  NotificationWidget(),
                  IconButton(
                    icon: const Icon(CupertinoIcons.add, color: Colors.white),
                    onPressed: () {
                      Get.to(
                        AjouterCoffreScreen(),
                        transition: Transition.cupertino,
                        duration: Duration(milliseconds: 500),
                      );
                      // Get.snackbar("Créer", "Créer un nouveau coffre");
                    },
                  )
                ]
              : [
                  IconButton(
                    icon: const Icon(CupertinoIcons.add, color: Colors.white),
                    onPressed: () {
                      Get.to(
                        AjouterCoffreScreen(),
                        transition: Transition.cupertino,
                        duration: Duration(milliseconds: 500),
                      );
                      // Get.snackbar("Créer", "Créer un nouveau coffre");
                    },
                  )
                ],
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.only(top: 30.dp, bottom: 30.dp),
            color: Colors.white,
            child: Column(
              spacing: 15.dp,
              children: [
                 Text(
                  'Mettez de l\'argent de côté de manière sécurisée et automatique',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 95, 91, 91),
                  ),
                ),
                SizedBox(
                  height: 25.w,
                  width: 25.w,
                  child: Image.asset('asset/coffre.png'),
                ),
                Obx(() {
                  return Text(
                    controller.coffre.value == null
                        ? "Solde disponible"
                        : "Solde disponible \n${formatMontant(controller.coffre.value!.totalAmount)}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color.fromARGB(255, 6, 58, 150),
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
                Obx(() {
                  var totalActif = controller.coffre.value!.objectifs
                      .where((element) => element.isActive == true)
                      .length;

                  return Text(
                    'Objectifs : ${totalActif ?? 0} actifs',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 95, 91, 91),
                    ),
                  );
                }),
                Obx(() {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(121, 105, 210, 1.0)),
                    onPressed: controller.coffre.value!.totalAmount == 0
                        ? null
                        : () {
                            CodeVerification().show(context, () {
                              showCupertinoInputPopup(
                                  title: 'Retrait',
                                  hint: 'Montant',
                                  onConfirm: (int montant) {
                                    Get.find<CoffreController>()
                                        .retraitC2W(montant: montant);
                                    controller.fetchCoffre();
                                  });
                            });
                          },
                    child: Text("Retrait",
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  );
                })
              ],
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverHeaderDelegate(
            minHeight: 12.h,
            maxHeight: 12.h,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    // Permet de passer le champ avec Enter/Rechercher
                    FocusScope.of(context).unfocus();
                  },
                  decoration: InputDecoration(
                    hintText: "Rechercher un objectif",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              FocusScope.of(context).unfocus();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: true,
          child: Stack(
            children: [
              Container(color: Colors.white),
              Obx(() {
                if (controller.isLoading.value) {
                  return chargement();
                } else if (controller.coffre.value != null) {
                  final objectifsFiltres =
                      _filteredObjectifs(controller.coffre.value!.objectifs);

                  if (controller.coffre.value!.objectifs.isEmpty) {
                    return empty();
                  }

                  if (objectifsFiltres.isEmpty && _searchQuery.isNotEmpty) {
                    return _noSearchResults();
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(
                        bottom: 80, top: 16, left: 16, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(objectifsFiltres.length, (index) {
                        final obj = objectifsFiltres[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: _objectifTile(
                            obj,
                            obj.nom,
                            obj.montantActuel.toInt(),
                            obj.montantCible.toInt(),
                            "15 jours restants",
                          ),
                        );
                      }),
                    ),
                  );
                } else {
                  return  Center(child: Text('Coffre non Trouvé',style: TextStyle(
                    fontSize: 12.sp,
                  ),

                  ));
                }
              }),
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: _isScrolled
                    ? TextButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.ajoutercoffre);
                        },
                        child:  Text("+ Ajouter un objectif",
                            style: TextStyle(fontSize: 12.sp)),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _noSearchResults() => Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "Aucun objectif trouvé",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Essayez avec d'autres mots-clés",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ));

  String formatMontant(double montant) {
    final formatter = NumberFormat("#,##0", "fr_FR");
    return "${formatter.format(montant ?? 0.0)} FCFA";
  }

  Widget _objectifTile(
    var key,
    String title,
    int current,
    int target, [
    String? subtitle,
  ]) {
    print("key.isActive: ${key.isActive}");
    return Container(
      decoration: BoxDecoration(
        color: key.isActive == false
            ? Colors.transparent
            : const Color.fromARGB(255, 224, 224, 224),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorModel.BlueColor),
      ),
      child: ListTile(
        onTap: () {
          showMyCupertinoPopup(ObjectifModel(
            id: key.id,
            coffreId: key.coffreId,
            nom: key.nom,
            montantCible: key.montantCible,
            montantActuel: key.montantActuel,
            isActive: key.isActive,
            delai: key.delai,
          ));
        },
        title: Text(title, style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 12.sp,)),
        subtitle: key.isActive
            ? Text(
                "${formatMontant(current.toDouble())} / ${formatMontant(target.toDouble())}",style:  TextStyle(fontSize: 10.sp,))
            : Text(
              style:  TextStyle(fontSize: 9.sp,),
                "${formatMontant(current.toDouble())} / ${formatMontant(target.toDouble())}"
                "${subtitle != null ? "\n${"Délai Restant : ${key.delai}"} " : ""}",
              ),
        trailing: ProgressionCirculaireAvecMax(
          
          valeurActuelle: key.montantActuel.toDouble(),
          valeurMax: key.montantCible.toDouble(),
        ),
      ),
    );
  }

  Widget chargement() => const Center(
        child: CupertinoActivityIndicator(radius: 15),
      );

  Widget empty() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Text(
            "Aucun objectif",
            style: TextStyle(fontSize: 20, color: AppColorModel.blackColor),
          )),
        ],
      );

  String convertirJours(int? jours) {
    if (jours == null || jours <= 0) return "0 jour";

    final int annees = jours ~/ 365;
    final int mois = (jours % 365) ~/ 30;
    final int joursRestants = (jours % 365) % 30;

    List<String> parties = [];

    if (annees > 0) {
      parties.add("$annees ${annees == 1 ? 'an' : 'ans'}");
    }
    if (mois > 0) {
      parties.add("$mois mois");
    }
    if (joursRestants > 0) {
      parties.add("$joursRestants ${joursRestants == 1 ? 'jour' : 'jours'}");
    }

    return parties.join(" et ");
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant _SliverHeaderDelegate oldDelegate) {
    return oldDelegate.minHeight != minHeight ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.child != child;
  }
}
