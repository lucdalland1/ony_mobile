// ignore: file_names
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:onyfast/Controller/verou/verroucontroller.dart';
import 'package:onyfast/View/const.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/sousdistributeur/sousdistributeurcontroller.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/model/sous_distributeur/sousdistributeurmodel.dart'
    as Model;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';


class MapLocationPage extends StatefulWidget {
  final Model.SousDistributeur? targetDistributeur;
  final bool startNavigation;

  const MapLocationPage({
    super.key,
    this.targetDistributeur,
    this.startNavigation = false,
  });

  @override
  State<MapLocationPage> createState() => _MapLocationPageState();
}

class _MapLocationPageState extends State<MapLocationPage>
    with TickerProviderStateMixin {
  // Controllers et états
  final PolylinePoints _polylinePoints =
      PolylinePoints(apiKey: 'AIzaSyBMWP4o7qFxDJ34BTHCPw6-oKh3_xPeTsU');
  static const String _googleApiKey = 'AIzaSyBMWP4o7qFxDJ34BTHCPw6-oKh3_xPeTsU';

  LatLng? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  MapType _selectedMapType = MapType.normal;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final HierarchySdController sd = Get.find<HierarchySdController>();

  // Position initiale (Brazzaville)
  final LatLng _initialPosition = const LatLng(-4.2634, 15.2429);

  // Données sélectionnées
  Model.SousDistributeur? _selectedDistributeur;
  bool _showBottomSheet = false;
  String _selectedFilter = 'Tous';
  bool _isLoadingLocation = true;
  String? _locationError;

  // Navigation en temps réel
  bool _isNavigating = false;
  LatLng? _destinationPosition;
  double? _distanceToDestination;
  double? _estimatedTime;

  // Liste des distributeurs proches
  List<Model.SousDistributeur> _nearbyDistributeurs = [];
  final bool _showNearbyOnly = false;

  // Couleurs
  final Color globalBlue = globalColor;
  final Color globalOrange = const Color.fromARGB(255, 196, 105, 1);
  final Color globalGreen = Colors.green;
  final Color globalGrey = Colors.grey;
  Timer? _statusUpdateTimer;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    AppSettingsController.to.setInactivity(false);

    // Utiliser addPostFrameCallback pour éviter setState pendant build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();

      // Si un distributeur cible est fourni, démarrer la navigation
      if (widget.targetDistributeur != null && widget.startNavigation) {
        _startNavigationTo(widget.targetDistributeur!);
      }
    });

    _statusUpdateTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (mounted) {
        _createMarkersFromAPI();

        // ✅ Rafraîchir aussi la bottom sheet si ouverte
        if (_showBottomSheet && _selectedDistributeur != null) {
          setState(() {});
        }
      }
    });
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  Future<void> _initializeMap() async {
    // Vérifier si la hiérarchie est déjà chargée
    if (sd.hierarchy.value == null) {
      await sd.fetchHierarchy();
    }

    await _startPositionStream();
    _createMarkersFromAPI();
  }

  Future<void> _startPositionStream() async {
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _locationError = 'Service de localisation désactivé';
          _isLoadingLocation = false;
        });
        _showLocationDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          setState(() {
            _locationError = 'Permission de localisation refusée';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _locationError = 'Permission de localisation refusée définitivement';
          _isLoadingLocation = false;
        });
        _showLocationDialog();
        return;
      }

      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;
      _updateCurrentPosition(currentPosition);

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          if (!mounted) return;
          _updateCurrentPosition(position);

          // Mettre à jour la distance et le temps si en navigation
          if (_isNavigating && _destinationPosition != null) {
            _updateNavigationInfo(position);
          }
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _locationError = 'Erreur de localisation: $error';
            _isLoadingLocation = false;
          });
        },
      );

      if (!mounted) return;
      setState(() {
        _isLoadingLocation = false;
      });

      // Calculer les distributeurs à proximité
      _calculateNearbyDistributeurs();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationError = 'Erreur: $e';
        _isLoadingLocation = false;
      });
    }
  }

  Future<List<LatLng>> _getPolylinePoints(
      LatLng origin, LatLng destination) async {
    List<LatLng> polylineCoordinates = [];

    try {
      PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
        //googleApiKey: _googleApiKey,
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving, // ou TravelMode.walking selon vos besoins
        ),
      );

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
        print("✅ Itinéraire récupéré : ${polylineCoordinates.length} points");
      } else {
        print("⚠️ Aucun itinéraire trouvé, erreur: ${result.errorMessage}");
        // Fallback : ligne droite
        polylineCoordinates = [origin, destination];
      }
    } catch (e) {
      print("❌ Erreur lors de la récupération de l'itinéraire: $e");
      // Fallback : ligne droite
      polylineCoordinates = [origin, destination];
    }

    return polylineCoordinates;
  }

  void _updateCurrentPosition(Position position) {
    if (!mounted) return;

    LatLng newPos = LatLng(position.latitude, position.longitude);

    setState(() {
      _currentPosition = newPos;

      _markers.removeWhere((m) => m.markerId.value == 'currentLocation');
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: newPos,
          infoWindow: const InfoWindow(title: 'Vous êtes ici'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    });

    if (_isLoadingLocation) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(newPos, 14),
      );
    }

    // Recalculer les distributeurs à proximité
    _calculateNearbyDistributeurs();
  }

  void _calculateNearbyDistributeurs() {
    if (_currentPosition == null) return;

    final allDistributeurs = _getAllSousDistributeurs();
    List<Map<String, dynamic>> distributeursWithDistance = [];

    for (var distributeur in allDistributeurs) {
      if (distributeur.localisationGps?.latitude != null &&
          distributeur.localisationGps?.longitude != null) {
        double distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          distributeur.localisationGps!.latitude!,
          distributeur.localisationGps!.longitude!,
        );

        distributeursWithDistance.add({
          'distributeur': distributeur,
          'distance': distance,
        });
      }
    }

    // Trier par distance
    distributeursWithDistance.sort(
        (a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    // Garder seulement les 10 plus proches (dans un rayon de 10 km)
    setState(() {
      _nearbyDistributeurs = distributeursWithDistance
          .where((item) => (item['distance'] as double) <= 10000) // 10 km
          .take(10)
          .map((item) => item['distributeur'] as Model.SousDistributeur)
          .toList();
    });
  }

  void _updateNavigationInfo(Position position) async {
    if (_destinationPosition == null) return;

    // Calculer la distance
    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _destinationPosition!.latitude,
      _destinationPosition!.longitude,
    );

    // Estimer le temps (vitesse moyenne de 30 km/h en ville)
    double estimatedTimeMinutes = (distance / 1000) / 30 * 60;

    setState(() {
      _distanceToDestination = distance;
      _estimatedTime = estimatedTimeMinutes;
    });

    // Mettre à jour la polyligne avec l'itinéraire réel
    await _updatePolyline(LatLng(position.latitude, position.longitude));

    // Si la destination est atteinte (moins de 50m)
    if (distance < 50) {
      _onDestinationReached();
    }
  }

  Future<void> _updatePolyline(LatLng currentPosition) async {
    if (_destinationPosition == null) return;

    // Récupérer l'itinéraire réel
    final polylinePoints = await _getPolylinePoints(
      currentPosition,
      _destinationPosition!,
    );

    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('navigation_route'),
          points: polylinePoints, // Utilise les points de l'itinéraire réel
          color: globalBlue,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );
    });
  }

  void _startNavigationTo(Model.SousDistributeur distributeur) async {
    if (distributeur.localisationGps?.latitude == null ||
        distributeur.localisationGps?.longitude == null) {
      SnackBarService.warning(
          "Position GPS non disponible pour ce distributeur");
      return;
    }

    final destination = LatLng(
      distributeur.localisationGps!.latitude!,
      distributeur.localisationGps!.longitude!,
    );

    setState(() {
      _isNavigating = true;
      _destinationPosition = destination;
      _selectedDistributeur = distributeur;
      _showBottomSheet = true;

      // Ajouter le marqueur de destination
      _markers.removeWhere((m) => m.markerId.value == 'destination');
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: destination,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: distributeur.nomComplet ?? 'Destination',
            snippet: 'Point d\'arrivée',
          ),
        ),
      );
    });

    // Centrer la caméra pour montrer le trajet complet
    if (_currentPosition != null) {
      _fitBounds(_currentPosition!, destination);
      // Récupérer et afficher l'itinéraire réel
      await _updatePolyline(_currentPosition!);
    }

    HapticFeedback.mediumImpact();
    SnackBarService.success('Navigation vers ${distributeur.nomComplet}');
  }

  void _stopNavigation() {
    setState(() {
      _isNavigating = false;
      _destinationPosition = null;
      _distanceToDestination = null;
      _estimatedTime = null;
      _polylines.clear();

      // Retirer le marqueur de destination
      _markers.removeWhere((m) => m.markerId.value == 'destination');
    });

    // Recréer tous les marqueurs
    _createMarkersFromAPI();

    HapticFeedback.lightImpact();
    SnackBarService.info('Navigation arrêtée');
  }

  void _onDestinationReached() {
    HapticFeedback.heavyImpact();

    if (Platform.isIOS) {
      // ----------- DIALOG iOS -----------
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Row(
            children: const [
              Icon(CupertinoIcons.check_mark_circled,
                  color: CupertinoColors.activeGreen),
              SizedBox(width: 8),
              Text('Destination atteinte !'),
            ],
          ),
          content: Text(
            'Vous êtes arrivé à ${_selectedDistributeur?.nomComplet ?? "votre destination"}',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                _stopNavigation();
              },
              child: const Text('OK'),
            )
          ],
        ),
      );
    } else {
      // ----------- DIALOG ANDROID -----------
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: globalGreen, size: 30),
              const SizedBox(width: 12),
              const Text('Destination atteinte !'),
            ],
          ),
          content: Text(
            'Vous êtes arrivé à ${_selectedDistributeur?.nomComplet ?? "votre destination"}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _stopNavigation();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _fitBounds(LatLng point1, LatLng point2) {
    double minLat =
        point1.latitude < point2.latitude ? point1.latitude : point2.latitude;
    double maxLat =
        point1.latitude > point2.latitude ? point1.latitude : point2.latitude;
    double minLng = point1.longitude < point2.longitude
        ? point1.longitude
        : point2.longitude;
    double maxLng = point1.longitude > point2.longitude
        ? point1.longitude
        : point2.longitude;

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100,
      ),
    );
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Localisation requise'),
        content: Text(_locationError ??
            'Veuillez activer la localisation pour profiter pleinement de l\'application.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openLocationSettings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: globalBlue),
            child: const Text('Paramètres'),
          ),
        ],
      ),
    );
  }

  void _showNearbyDistributeurs() {
    if (_nearbyDistributeurs.isEmpty) {
      SnackBarService.info('Aucun distributeur à proximité trouvé');

      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.near_me, color: globalBlue, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Points de service à proximité',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: globalBlue,
                          ),
                        ),
                        Text(
                          '${_nearbyDistributeurs.length} trouvé(s) dans un rayon de 10 km',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _nearbyDistributeurs.length,
                itemBuilder: (context, index) {
                  final distributeur = _nearbyDistributeurs[index];
                  final distance = Geolocator.distanceBetween(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                    distributeur.localisationGps!.latitude!,
                    distributeur.localisationGps!.longitude!,
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.pop(context);
                        _onMarkerTapped(distributeur);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: globalBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: globalBlue,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    distributeur.nomComplet ??
                                        'Nom indisponible',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDistance(distance),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(distributeur)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          _getStatusText(distributeur),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                _getStatusColor(distributeur),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(Model.SousDistributeur distributeur) {
    final isOpen = sd.isDistributeurActuellementOuvert(distributeur);
    return isOpen ? globalGreen : Colors.red;
  }

  String _getStatusText(Model.SousDistributeur distributeur) {
    final isOpen = sd.isDistributeurActuellementOuvert(distributeur);
    return isOpen ? 'Ouvert' : 'Fermé';
  }

  void _createMarkersFromAPI() {
    final allDistributeurs = _getAllSousDistributeurs();

    // Appliquer le filtre si nécessaire
    List<Model.SousDistributeur> filteredDistributeurs = allDistributeurs;

    if (_selectedFilter == 'Ouvert') {
      filteredDistributeurs = allDistributeurs.where((d) {
        return sd.isDistributeurActuellementOuvert(d);
      }).toList();
    } else if (_selectedFilter == 'Fermé') {
      filteredDistributeurs = allDistributeurs.where((d) {
        return !sd.isDistributeurActuellementOuvert(d);
      }).toList();
    }

    setState(() {
      // Garder le marqueur de position actuelle et de destination
      final currentLocationMarker = _markers.firstWhere(
        (m) => m.markerId.value == 'currentLocation',
        orElse: () => Marker(markerId: const MarkerId('none')),
      );

      final destinationMarker = _markers.firstWhere(
        (m) => m.markerId.value == 'destination',
        orElse: () => Marker(markerId: const MarkerId('none')),
      );

      _markers.clear();

      if (currentLocationMarker.markerId.value != 'none') {
        _markers.add(currentLocationMarker);
      }

      if (destinationMarker.markerId.value != 'none') {
        _markers.add(destinationMarker);
      }

      for (var distributeur in filteredDistributeurs) {
        if (distributeur.localisationGps?.latitude != null &&
            distributeur.localisationGps?.longitude != null) {
          final position = LatLng(
            distributeur.localisationGps!.latitude!,
            distributeur.localisationGps!.longitude!,
          );

          _markers.add(
            Marker(
              markerId: MarkerId(distributeur.id.toString()),
              position: position,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                _getMarkerColorFromStatus(distributeur),
              ),
              infoWindow: InfoWindow(
                title: distributeur.nomComplet ?? 'Distributeur',
                snippet: distributeur.entreprise?.localisation ??
                    _getStatusText(distributeur),
              ),
              onTap: () => _onMarkerTapped(distributeur),
            ),
          );
        }
      }
    });
  }

  List<Model.SousDistributeur> _getAllSousDistributeurs() {
    List<Model.SousDistributeur> allSD = [];

    if (sd.hierarchy.value?.data?.villes != null) {
      for (var ville in sd.hierarchy.value!.data!.villes!) {
        if (ville.districts != null) {
          for (var district in ville.districts!) {
            if (district.quartiers != null) {
              for (var quartier in district.quartiers!) {
                if (quartier.sousDistr != null) {
                  allSD.addAll(quartier.sousDistr!);
                }
              }
            }
          }
        }
      }
    }

    return allSD;
  }

  double _getMarkerColorFromStatus(Model.SousDistributeur distributeur) {
    final isOpen = sd.isDistributeurActuellementOuvert(distributeur);
    return isOpen ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed;
  }

  void _onMarkerTapped(Model.SousDistributeur distributeur) {
    setState(() {
      _selectedDistributeur = distributeur;
      _showBottomSheet = true;
    });

    if (distributeur.localisationGps?.latitude != null &&
        distributeur.localisationGps?.longitude != null) {
      final position = LatLng(
        distributeur.localisationGps!.latitude!,
        distributeur.localisationGps!.longitude!,
      );

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(position, 15),
      );
    }
  }

  void _filterByType(String type) {
    setState(() {
      _selectedFilter = type;
      _createMarkersFromAPI();
    });
  }

  Future<void> _callDistributeur(Model.SousDistributeur distributeur) async {
    if (distributeur.telephone != null) {
      final Uri phoneUri = Uri(scheme: 'tel', path: distributeur.telephone);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        SnackBarService.error("Impossible de lancer l'appel");
      }
    }
  }

  String _formatDistance(double? distance) {
    if (distance == null) return '--';
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }

  String _formatTime(double? minutes) {
    if (minutes == null) return '--';
    if (minutes < 60) {
      return '${minutes.toStringAsFixed(0)} min';
    } else {
      int hours = minutes ~/ 60;
      int remainingMinutes = (minutes % 60).toInt();
      return '${hours}h ${remainingMinutes}min';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _mapController?.dispose();
    _positionStream?.cancel();
    _statusUpdateTimer?.cancel(); // ✅ AJOUTEZ CECI
    AppSettingsController.to.setInactivity(true);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Scaffold(
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: GoogleMap(
              mapType: _selectedMapType,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
    Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
  },
              initialCameraPosition: CameraPosition(
                target: _currentPosition ?? _initialPosition,
                zoom: 14,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onTap: (_) {
                if (_showBottomSheet && !_isNavigating) {
                  setState(() {
                    _showBottomSheet = false;
                    _selectedDistributeur = null;
                  });
                }
              },
            ),
          ),

          if (_isLoadingLocation)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: globalBlue),
                    const SizedBox(height: 16),
                    Text(
                      'Obtention de votre position...',
                      style: TextStyle(
                        color: globalBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Barre de navigation en cours
          if (_isNavigating)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: _buildNavigationBar(screenWidth),
            ),

          if (!_isNavigating) ...[
            _buildHeader(context, screenWidth),
            Positioned(
              top: MediaQuery.of(context).padding.top +
                  (screenWidth < 380
                      ? 80
                      : screenWidth < 600
                          ? 90
                          : 100),
              left: _getHorizontalPadding(screenWidth),
              right: _getHorizontalPadding(screenWidth),
              child: _buildSearchBar(screenWidth),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top +
                  (screenWidth < 380
                      ? 145
                      : screenWidth < 600
                          ? 160
                          : 175),
              left: _getHorizontalPadding(screenWidth),
              right: _getHorizontalPadding(screenWidth),
              child: _buildFilters(screenWidth),
            ),
          ],

          Positioned(
            right: _getHorizontalPadding(screenWidth),
            bottom: _showBottomSheet
                ? (screenWidth < 380
                    ? 330
                    : screenWidth < 600
                        ? 350
                        : 370)
                : 100,
            child: _buildControlButtons(screenWidth),
          ),

          if (_showBottomSheet && _selectedDistributeur != null)
            _buildBottomSheet(screenWidth, screenHeight),
        ],
      ),
    );
  }

  Widget _buildNavigationBar(double screenWidth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: globalBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.navigation, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Navigation en cours',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _selectedDistributeur?.nomComplet ?? '',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: _stopNavigation,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.straighten, color: Colors.white, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        _formatDistance(_distanceToDestination),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Distance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.access_time, color: Colors.white, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(_estimatedTime),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Temps estimé',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _getHorizontalPadding(double screenWidth) {
    if (screenWidth < 380) return 16;
    if (screenWidth < 600) return 20;
    return 40;
  }

  Widget _buildHeader(BuildContext context, double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.0),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _getHorizontalPadding(screenWidth),
            vertical: 16,
          ),
          child: Row(
            children: [
              Container(
                width: screenWidth < 380 ? 36 : 40,
                height: screenWidth < 380 ? 36 : 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back,
                    color: globalBlue,
                    size: screenWidth < 380 ? 20 : 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.location_solid,
                        color: globalOrange,
                        size: screenWidth < 380 ? 18 : 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Carte des points de service',
                          style: TextStyle(
                            color: globalBlue,
                            fontSize: screenWidth < 380 ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(double screenWidth) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Rechercher un point de service...',
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: screenWidth < 380 ? 14 : 16,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: globalBlue,
              size: screenWidth < 380 ? 20 : 24,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: screenWidth < 380 ? 12 : 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(double screenWidth) {
    final filters = ['Tous', 'Ouvert', 'Fermé'];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : globalBlue,
                          fontSize: screenWidth < 380 ? 12 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        HapticFeedback.lightImpact();
                        _filterByType(filter);
                      },
                      backgroundColor: Colors.white,
                      selectedColor: globalBlue,
                      checkmarkColor: Colors.white,
                      elevation: 3,
                      shadowColor: Colors.black.withOpacity(0.2),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth < 380 ? 8 : 12,
                        vertical: screenWidth < 380 ? 6 : 8,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            height: screenWidth < 380 ? 44 : 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<MapType>(
                  value: _selectedMapType,
                  icon: Icon(
                    Icons.map,
                    color: globalBlue,
                    size: screenWidth < 380 ? 22 : 24,
                  ),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  style: TextStyle(
                    color: globalBlue,
                    fontWeight: FontWeight.w600,
                  ),
                  isDense: true,
                  onChanged: (MapType? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedMapType = newValue;
                      });
                    }
                  },
                  items: [
                    MapType.normal,
                    MapType.satellite,
                    MapType.hybrid,
                    MapType.terrain,
                  ].map((MapType type) {
                    String name;
                    switch (type) {
                      case MapType.normal:
                        name = "Normal";
                        break;
                      case MapType.satellite:
                        name = "Satellite";
                        break;
                      case MapType.hybrid:
                        name = "Hybride";
                        break;
                      case MapType.terrain:
                        name = "Terrain";
                        break;
                      default:
                        name = "";
                    }
                    return DropdownMenuItem<MapType>(
                      value: type,
                      child: Text(
                        name,
                        style: TextStyle(
                          color: globalBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: screenWidth < 380 ? 12 : 14,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildControlButtons(double screenWidth) {
    return Column(
      children: [
        // Bouton pour afficher les distributeurs à proximité
        if (_currentPosition != null && _nearbyDistributeurs.isNotEmpty)
          Container(
            width: screenWidth < 380 ? 44 : 48,
            height: screenWidth < 380 ? 44 : 48,
            decoration: BoxDecoration(
              color: globalGreen,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showNearbyDistributeurs();
                  },
                  icon: Icon(
                    Icons.near_me,
                    color: Colors.white,
                    size: screenWidth < 380 ? 22 : 24,
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_nearbyDistributeurs.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (_currentPosition != null && _nearbyDistributeurs.isNotEmpty)
          const SizedBox(height: 12),
        Container(
          width: screenWidth < 380 ? 44 : 48,
          height: screenWidth < 380 ? 44 : 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              HapticFeedback.lightImpact();
              if (_currentPosition != null) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(_currentPosition!, 15),
                );
              } else {
                _startPositionStream();
              }
            },
            icon: Icon(
              CupertinoIcons.location_fill,
              color: globalOrange,
              size: screenWidth < 380 ? 22 : 24,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: screenWidth < 380 ? 44 : 48,
          height: screenWidth < 380 ? 44 : 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              HapticFeedback.lightImpact();
              _mapController?.animateCamera(CameraUpdate.zoomIn());
            },
            icon: Icon(
              Icons.add,
              color: globalBlue,
              size: screenWidth < 380 ? 22 : 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: screenWidth < 380 ? 44 : 48,
          height: screenWidth < 380 ? 44 : 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              HapticFeedback.lightImpact();
              _mapController?.animateCamera(CameraUpdate.zoomOut());
            },
            icon: Icon(
              Icons.remove,
              color: globalBlue,
              size: screenWidth < 380 ? 22 : 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSheet(double screenWidth, double screenHeight) {
    final distributeur = _selectedDistributeur!;
    // final isOpen =
    //     distributeur.horairesOuverture?.aujourdhui?.estOuvert ?? false;
    // final statusColor = isOpen ? globalGreen : Colors.red;

    final isOpen = sd.isDistributeurActuellementOuvert(distributeur);
    final statusColor = isOpen ? globalGreen : Colors.red;
    final statusText = isOpen ? 'Ouvert' : 'Fermé';
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(screenWidth < 380
                    ? 16
                    : screenWidth < 600
                        ? 20
                        : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: screenWidth < 380 ? 56 : 64,
                          height: screenWidth < 380 ? 56 : 64,
                          decoration: BoxDecoration(
                            color: globalBlue,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.store,
                            color: Colors.white,
                            size: screenWidth < 380 ? 28 : 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                distributeur.nomComplet ?? 'Nom indisponible',
                                style: TextStyle(
                                  fontSize: screenWidth < 380 ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: screenWidth < 380 ? 14 : 16,
                                    color: Colors.red[400],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      distributeur.adresse ??
                                          'Adresse non disponible',
                                      style: TextStyle(
                                        fontSize: screenWidth < 380 ? 12 : 14,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isOpen ? Icons.check_circle : Icons.cancel,
                                size: screenWidth < 380 ? 14 : 16,
                                color: statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isOpen ? 'Ouvert' : 'Fermé',
                                style: TextStyle(
                                  fontSize: screenWidth < 380 ? 13 : 15,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            icon: Icons.access_time,
                            label: 'Horaires',
                            value: _getHoraires(distributeur),
                            screenWidth: screenWidth,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoItem(
                            icon: Icons.phone,
                            label: 'Téléphone',
                            value: distributeur.telephone ?? 'N/A',
                            screenWidth: screenWidth,
                          ),
                        ),
                      ],
                    ),
                    if (distributeur.entreprise?.nom != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.business,
                              size: screenWidth < 380 ? 18 : 20,
                              color: globalBlue,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Entreprise',
                                    style: TextStyle(
                                      fontSize: screenWidth < 380 ? 11 : 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    distributeur.entreprise!.nom!,
                                    style: TextStyle(
                                      fontSize: screenWidth < 380 ? 13 : 14,
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: screenWidth < 380 ? 44 : 48,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                if (_isNavigating) {
                                  _stopNavigation();
                                } else {
                                  _startNavigationTo(distributeur);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _isNavigating ? Colors.red : globalBlue,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: Icon(
                                _isNavigating ? Icons.stop : Icons.directions,
                                size: screenWidth < 380 ? 18 : 20,
                              ),
                              label: Text(
                                _isNavigating ? 'Arrêter' : 'Itinéraire',
                                style: TextStyle(
                                  fontSize: screenWidth < 380 ? 14 : 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: screenWidth < 380 ? 44 : 48,
                          height: screenWidth < 380 ? 44 : 48,
                          child: OutlinedButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _callDistributeur(distributeur);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              foregroundColor: globalBlue,
                              side: BorderSide(color: globalBlue, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Icon(
                              Icons.phone,
                              size: screenWidth < 380 ? 20 : 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: screenWidth < 380 ? 44 : 48,
                          height: screenWidth < 380 ? 44 : 48,
                          child: OutlinedButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _showBottomSheet = false;
                                _selectedDistributeur = null;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              foregroundColor: globalBlue,
                              side: BorderSide(color: globalBlue, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Icon(
                              Icons.close,
                              size: screenWidth < 380 ? 20 : 22,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required double screenWidth,
  }) {
    return Container(
      padding: EdgeInsets.all(screenWidth < 380 ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: screenWidth < 380 ? 16 : 18,
                color: globalBlue,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: screenWidth < 380 ? 11 : 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth < 380 ? 13 : 15,
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getHoraires(Model.SousDistributeur distributeur) {
    final horaires = distributeur.horairesOuverture?.aujourdhui;
    if (horaires?.heureOuverture != null && horaires?.heureFermeture != null) {
      return '${horaires!.heureOuverture} - ${horaires.heureFermeture}';
    }
    return 'Non disponibles';
  }
}
