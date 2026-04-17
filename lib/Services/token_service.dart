// import 'dart:convert';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';

// class TokenService extends GetxService {
//   final box = GetStorage();
//   static const String baseUrl = 'https://api.dev.onyfastbank.com/v2';
//   static const String deviceKey =
//       'b08Zhc601YHR4LCV2gSD2cppAT0Ex+7wwbwAb/Y2thg=';

//   // Observable pour l'état de connexion
//   var isLoggedIn = false.obs;
//   var isTokenRefreshing = false.obs;
//   var shouldLogout = false.obs;
//   var autoRefreshEnabled = true.obs;

//   // Cache pour les soldes des cartes
//   final Map<String, double> _balanceCache = {};
//   final Map<String, DateTime> _balanceCacheTime = {};
//   static const Duration _cacheValidDuration = Duration(minutes: 5);

//   @override
//   void onInit() {
//     super.onInit();
//     _checkAuthStatus();
//     _setupPeriodicRefresh();
//   }

//   void _checkAuthStatus() {
//     final token = authToken;
//     final phoneNumber = this.phoneNumber;
//     isLoggedIn.value = token != null && phoneNumber != null;

//     if (isLoggedIn.value) {
//       debugStorage();
//     }
//   }

//   /// Configure un rafraîchissement périodique automatique
//   void _setupPeriodicRefresh() {
//     Stream.periodic(Duration(minutes: 5)).listen((_) {
//       if (autoRefreshEnabled.value && isLoggedIn.value && !isTokenValid) {
//         print('🔄 Rafraîchissement périodique du token...');
//         refreshToken();
//       }
//     });
//   }

//   String? get authToken => box.read('jwt_token');

//   // Récupérer le numéro de téléphone depuis userInfo
//   String? get phoneNumber {
//     final userInfo = box.read('userInfo') ?? {};
//     return userInfo['telephone']?.toString() ?? userInfo['phone']?.toString();
//   }

//   DateTime? get tokenExpiry {
//     final expiryString = box.read('token_expiry');
//     if (expiryString != null) {
//       try {
//         return DateTime.parse(expiryString);
//       } catch (e) {
//         print('❌ Erreur parsing date expiration: $e');
//         return null;
//       }
//     }
//     return null;
//   }

//   bool get isTokenValid {
//     final expiry = tokenExpiry;
//     if (expiry == null) return false;

//     // Considérer le token comme expiré 5 minutes avant l'expiration réelle
//     final now = DateTime.now().add(Duration(minutes: 5));
//     final isValid = expiry.isAfter(now);

//     if (!isValid) {
//       print('⚠️ Token expiré: expire le $expiry, maintenant: $now');
//     }

//     return isValid;
//   }

//   // Sauvegarder les informations d'authentification
//   void saveAuthData({
//     required String token,
//     required int expiresIn,
//     String? authenticatedWith,
//   }) {
//     final expiryDate = DateTime.now().add(Duration(seconds: expiresIn));

//     box.write('jwt_token', token);
//     box.write('token_expiry', expiryDate.toIso8601String());
//     if (authenticatedWith != null) {
//       box.write('auth_method', authenticatedWith);
//     }

//     isLoggedIn.value = true;
//     shouldLogout.value = false;

//     print('✅ Données d\'authentification sauvegardées');
//     print('🔑 Token expire le: $expiryDate');
//     print('📱 Authentifié avec: ${authenticatedWith ?? "unknown"}');
//   }

//   // Effacer les données d'authentification (garde userInfo intacte)
//   void clearAuthData({bool forceLogout = false}) {
//     if (!forceLogout && autoRefreshEnabled.value) {
//       print('🚫 Déconnexion empêchée - auto-refresh activé');
//       return;
//     }

//     box.remove('jwt_token');
//     box.remove('token_expiry');
//     box.remove('auth_method');
//     isLoggedIn.value = false;
//     shouldLogout.value = false;

//     // Vider le cache des soldes lors de la déconnexion
//     _balanceCache.clear();
//     _balanceCacheTime.clear();

//     print('🧹 Données d\'authentification effacées');
//   }

//   Future<http.Response> authenticatedCardRequest(String cardID, String endpoint,
//       {Map<String, String>? headers}) async {
//     if (!isTokenValid || !_isTokenForCardID(authToken, cardID)) {
//       final refreshed = await refreshToken();
//       if (!refreshed) {
//         throw TokenExpiredException('Token expiré ou invalide');
//       }

//       final tokenForCard = await _createCardAuthToken(cardID);
//       if (tokenForCard == null) {
//         throw TokenExpiredException(
//             'Impossible de créer un token pour la carte');
//       }

//       return await _makeAuthenticatedBalanceRequest(cardID, tokenForCard);
//     }

//     return await _makeAuthenticatedBalanceRequest(cardID, authToken!);
//   }

//   Future<String?> _createCardAuthToken(String cardID) async {
//     try {
//       print('🔑 Création d\'un token pour la carte: $cardID');

//       final body = json.encode({
//         'device_key': deviceKey,
//         'cardID': cardID,
//       });

//       final response = await http
//           .post(
//             Uri.parse('$baseUrl/auth.php'),
//             headers: {
//               'Content-Type': 'application/json',
//               'Accept': 'application/json',
//             },
//             body: body,
//           )
//           .timeout(Duration(seconds: 15));

//       final data = json.decode(response.body);
//       print('🧪 Réponse création token carte : $data');

//       if (data['status']?['success'] == true &&
//           data['status']?['data']?['token'] != null) {
//         return data['status']['data']['token'];
//       }

//       return null;
//     } catch (e) {
//       print('❌ Erreur création token carte : $e');
//       return null;
//     }
//   }

//   // Renouveler le token automatiquement avec le nouveau système d'auth
//   Future<bool> refreshToken({int maxRetries = 3}) async {
//     if (isTokenRefreshing.value) {
//       print('⏳ Rafraîchissement déjà en cours, attente...');
//       await Future.doWhile(() async {
//         await Future.delayed(Duration(milliseconds: 500));
//         return isTokenRefreshing.value;
//       });
//       return isTokenValid;
//     }

//     try {
//       isTokenRefreshing.value = true;
//       shouldLogout.value = false;

//       final currentPhoneNumber = phoneNumber;
//       if (currentPhoneNumber == null) {
//         print('❌ Numéro de téléphone non disponible pour le renouvellement');
//         return await _createTemporarySession();
//       }

//       print('🔄 Renouvellement du token pour: $currentPhoneNumber');

//       for (int attempt = 1; attempt <= maxRetries; attempt++) {
//         try {
//           print('🔄 Tentative $attempt/$maxRetries de renouvellement');

//           // Utiliser le nouveau système d'auth par téléphone
//           final response = await http
//               .post(
//                 Uri.parse('$baseUrl/auth.php'),
//                 headers: {'Content-Type': 'application/json'},
//                 body: json.encode({
//                   'device_key': deviceKey,
//                   'phone': currentPhoneNumber,
//                 }),
//               )
//               .timeout(Duration(seconds: 15));

//           print('📡 Réponse auth.php: ${response.statusCode}');

//           if (response.statusCode == 200) {
//             final data = json.decode(response.body);
//             print('📱 Réponse du serveur (tentative $attempt): $data');

//             // CORRECTION: Accéder aux données du token dans la bonne structure
//             if (data['status']['success'] == true &&
//                 data['status']['data'] != null) {
//               final tokenData = data['status']['data'];

//               saveAuthData(
//                 token: tokenData['token'],
//                 expiresIn: tokenData['expires_in'] ?? 86400,
//                 authenticatedWith: tokenData['authenticated_with'] ?? 'phone',
//               );
//               print('✅ Token renouvelé avec succès à la tentative $attempt');
//               return true;
//             } else {
//               print(
//                   '❌ Échec du renouvellement tentative $attempt: ${data['status']['message']}');
//             }
//           } else {
//             print('❌ Erreur HTTP tentative $attempt: ${response.statusCode}');
//             print('📄 Body: ${response.body}');
//           }
//         } catch (e) {
//           print('❌ Erreur tentative $attempt: $e');
//         }

//         if (attempt < maxRetries) {
//           await Future.delayed(Duration(seconds: attempt * 2));
//         }
//       }

//       print('⚠️ Échec de toutes les tentatives, création session temporaire');
//       return await _createTemporarySession();
//     } catch (e) {
//       print('❌ Erreur générale lors du renouvellement du token: $e');
//       return await _createTemporarySession();
//     } finally {
//       isTokenRefreshing.value = false;
//     }
//   }

//   /// Crée une session temporaire pour maintenir l'accès
//   Future<bool> _createTemporarySession() async {
//     try {
//       final tempToken = 'temp_${DateTime.now().millisecondsSinceEpoch}';
//       final tempExpiry = DateTime.now().add(Duration(hours: 2));

//       box.write('jwt_token', tempToken);
//       box.write('token_expiry', tempExpiry.toIso8601String());
//       box.write('auth_method', 'temporary');

//       isLoggedIn.value = true;
//       shouldLogout.value = false;

//       print('🆘 Session temporaire créée: expire le $tempExpiry');

//       // Programmer une nouvelle tentative de refresh dans 10 minutes
//       Future.delayed(Duration(minutes: 10), () {
//         if (authToken == tempToken) {
//           print('🔄 Tentative de remplacement de la session temporaire');
//           refreshToken();
//         }
//       });

//       return true;
//     } catch (e) {
//       print('❌ Erreur création session temporaire: $e');
//       return false;
//     }
//   }

//   // NOUVELLE MÉTHODE: Récupération du solde avec auth cardID et token JWT
//   Future<double?> getCardBalance(String cardID,
//       {bool forceRefresh = false}) async {
//     if (cardID.isEmpty) return null;

//     // Vérifier le cache si pas de refresh forcé
//     if (!forceRefresh && _balanceCache.containsKey(cardID)) {
//       final cacheTime = _balanceCacheTime[cardID];
//       if (cacheTime != null &&
//           DateTime.now().difference(cacheTime) < _cacheValidDuration) {
//         print(
//             '💰 Solde récupéré depuis le cache: ${_balanceCache[cardID]} XAF');
//         return _balanceCache[cardID];
//       }
//     }

//     try {
//       print('💰 Récupération du solde pour la carte: $cardID');

//       // S'assurer d'avoir un token valide avant l'appel
//       if (!isTokenValid) {
//         print('🔄 Token invalide, rafraîchissement automatique...');
//         final refreshed = await refreshToken();
//         if (!refreshed) {
//           throw Exception(
//               'Impossible de rafraîchir le token d\'authentification');
//         }
//       }

//       // Créer un token spécifique pour cette carte si nécessaire
//       String? authTokenForCard = authToken;

//       // Si le token actuel n'est pas basé sur cardID, en créer un nouveau
//       if (!_isTokenForCardID(authTokenForCard, cardID)) {
//         print('🔑 Création d\'un token spécifique pour la carte $cardID');
//         authTokenForCard = await _createCardAuthToken(cardID);

//         if (authTokenForCard == null) {
//           throw Exception(
//               'Impossible de créer un token d\'authentification pour cette carte');
//         }
//       }

//       // Effectuer l'appel avec le token approprié
//       final response =
//           await _makeAuthenticatedBalanceRequest(cardID, authTokenForCard!);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         // Gestion flexible des différents formats de réponse
//         bool isSuccess = false;
//         dynamic balanceData;

//         if (data['success'] == true) {
//           isSuccess = true;
//           balanceData = data['data'];
//         } else if (data['status'] == 'success') {
//           isSuccess = true;
//           balanceData = data['data'];
//         } else if (data['status']['success'] == true) {
//           isSuccess = true;
//           balanceData = data['status']['data'];
//         }

//         if (isSuccess && balanceData != null) {
//           // Essayer différents champs pour le solde
//           dynamic rawBalance = balanceData['balance'] ??
//               balanceData['amount'] ??
//               balanceData['solde'] ??
//               balanceData['montant'];

//           final balance = double.tryParse(rawBalance.toString());

//           if (balance != null) {
//             // Mettre à jour le cache
//             _balanceCache[cardID] = balance;
//             _balanceCacheTime[cardID] = DateTime.now();
//             print('✅ Solde récupéré: $balance XAF');
//             return balance;
//           } else {
//             print('⚠️ Balance reçue mais format invalide: $rawBalance');
//           }
//         } else {
//           final message = data['message'] ??
//               data['error'] ??
//               data['status']['message'] ??
//               'Erreur inconnue';
//           print('❌ Erreur API: $message');
//           throw Exception(message);
//         }
//       } else if (response.statusCode == 401) {
//         print('🔄 Token expiré ou invalide, nouvelle tentative...');

//         // Token expiré, essayer de le rafraîchir et réessayer
//         final refreshed = await refreshToken();
//         if (refreshed) {
//           final newAuthToken = await _createCardAuthToken(cardID);

//           if (newAuthToken != null) {
//             // Nouvelle tentative avec le token rafraîchi
//             final retryResponse =
//                 await _makeAuthenticatedBalanceRequest(cardID, newAuthToken);

//             if (retryResponse.statusCode == 200) {
//               final data = json.decode(retryResponse.body);

//               bool isSuccess = false;
//               dynamic balanceData;

//               if (data['success'] == true) {
//                 isSuccess = true;
//                 balanceData = data['data'];
//               } else if (data['status'] == 'success') {
//                 isSuccess = true;
//                 balanceData = data['data'];
//               } else if (data['status']['success'] == true) {
//                 isSuccess = true;
//                 balanceData = data['status']['data'];
//               }

//               if (isSuccess && balanceData != null) {
//                 dynamic rawBalance = balanceData['balance'] ??
//                     balanceData['amount'] ??
//                     balanceData['solde'] ??
//                     balanceData['montant'];

//                 final balance = double.tryParse(rawBalance.toString());
//                 if (balance != null) {
//                   _balanceCache[cardID] = balance;
//                   _balanceCacheTime[cardID] = DateTime.now();
//                   print('✅ Solde récupéré après refresh: $balance XAF');
//                   return balance;
//                 }
//               }
//             }
//           }
//         }

//         throw Exception('Session expirée. Veuillez vous reconnecter.');
//       } else if (response.statusCode == 403) {
//         throw Exception('Accès non autorisé pour cette carte');
//       } else if (response.statusCode == 404) {
//         throw Exception('Carte non trouvée ou service indisponible');
//       } else {
//         throw Exception('Erreur serveur: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('❌ Erreur lors de la récupération du solde: $e');

//       // Gestion spécifique des erreurs
//       if (e.toString().contains('SocketException')) {
//         throw Exception('Problème de connexion réseau');
//       } else if (e.toString().contains('TimeoutException')) {
//         throw Exception('Délai d\'attente dépassé');
//       } else if (e.toString().contains('FormatException')) {
//         throw Exception('Erreur de format des données');
//       }

//       // Ne pas supprimer du cache en cas d'erreur, garder la dernière valeur connue
//       rethrow;
//     }

//     return null;
//   }

//   /// Vérifie si le token actuel est basé sur le cardID spécifié
//   bool _isTokenForCardID(String? token, String cardID) {
//     if (token == null) return false;

//     try {
//       // Décoder le payload du JWT pour vérifier le cardID
//       final parts = token.split('.');
//       if (parts.length != 3) return false;

//       final payload = parts[1];
//       final normalizedPayload = _base64Normalize(payload);
//       final decodedBytes = base64.decode(normalizedPayload);
//       final decodedPayload = utf8.decode(decodedBytes);
//       final payloadJson = json.decode(decodedPayload);

//       return payloadJson['cardID'] == cardID;
//     } catch (e) {
//       print('❌ Erreur lors de la vérification du token: $e');
//       return false;
//     }
//   }

//   /// Normalise une chaîne base64
//   String _base64Normalize(String base64) {
//     String normalized = base64.replaceAll('-', '+').replaceAll('_', '/');

//     // Ajouter le padding si nécessaire
//     switch (normalized.length % 4) {
//       case 2:
//         normalized += '==';
//         break;
//       case 3:
//         normalized += '=';
//         break;
//     }

//     return normalized;
//   }

//   /// Crée un token d'authentification spécifique pour un cardID
//   Future<String?> createCardToken(String cardID) async {
//     try {
//       print('🔑 Création token pour cardID: $cardID');
//       final response = await http
//           .post(
//             Uri.parse('$baseUrl/auth.php'),
//             headers: {
//               'Content-Type': 'application/json',
//               'Accept': 'application/json',
//             },
//             body: json.encode({
//               'device_key': deviceKey,
//               'cardID': cardID,
//             }),
//           )
//           .timeout(Duration(seconds: 10));

//       final data = json.decode(response.body);
//       print('🧪 Réponse auth token: ${json.encode(data)}');

//       if (data['status']?['success'] == true &&
//           data['status']?['data']?['token'] != null) {
//         // print(data['status']['data']['token']);
//         return data['status']['data']['token'];
//       } else {
//         print('❌ Token non retourné : ${data['status']?['message']}');
//         return null;
//       }
//     } catch (e) {
//       print('❌ Erreur createCardToken: $e');
//       return null;
//     }
//   }

//   /// Effectue l'appel authentifié pour récupérer le solde
//   Future<http.Response> _makeAuthenticatedBalanceRequest(
//       String cardID, String authTokenForCard) async {
//     final url = Uri.parse('$baseUrl/balance.php?cardID=$cardID');

//     final headers = {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//       'Authorization': 'Bearer $authTokenForCard',
//       'X-Device-Key': deviceKey,
//     };

//     print('📡 Appel balance API: $url');
//     print('🔑 Token utilisé: ${authTokenForCard.substring(0, 20)}...');

//     return await http.get(url, headers: headers).timeout(Duration(seconds: 15));
//   }

//   /// Vider le cache des soldes
//   void clearBalanceCache() {
//     _balanceCache.clear();
//     _balanceCacheTime.clear();
//     print('🧹 Cache des soldes vidé');
//   }

//   /// Obtenir un solde depuis le cache uniquement
//   double? getCachedBalance(String cardID) {
//     if (_balanceCache.containsKey(cardID)) {
//       final cacheTime = _balanceCacheTime[cardID];
//       if (cacheTime != null &&
//           DateTime.now().difference(cacheTime) < _cacheValidDuration) {
//         return _balanceCache[cardID];
//       }
//     }
//     return null;
//   }

//   // Faire une requête authentifiée avec gestion automatique du token
//   Future<http.Response> authenticatedRequest({
//     required String method,
//     required String endpoint,
//     Map<String, String>? headers,
//     Object? body,
//     Duration timeout = const Duration(seconds: 15),
//   }) async {
//     // Vérifier si le token est valide
//     if (!isTokenValid) {
//       print('🔄 Token expiré, renouvellement préventif...');
//       final refreshed = await refreshToken();
//       if (!refreshed) {
//         print('⚠️ Refresh échoué, tentative de requête quand même');
//       }
//     }

//     final token = authToken;
//     print('🔑 Token utilisé: ${token?.substring(0, 20)}...');
//     if (token == null) {
//       throw TokenExpiredException('Token non disponible');
//     }

//     final requestHeaders = {
//       'Authorization': 'Bearer $token',
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//       'User-Agent': 'OnyFast-Mobile-App',
//       ...?headers,
//     };

//     final uri = Uri.parse('$baseUrl/$endpoint');
//     print('🌐 Requête: $method $uri');

//     http.Response response;

//     try {
//       switch (method.toUpperCase()) {
//         case 'GET':
//           response =
//               await http.get(uri, headers: requestHeaders).timeout(timeout);
//           break;
//         case 'POST':
//           response = await http
//               .post(uri, headers: requestHeaders, body: body)
//               .timeout(timeout);
//           break;
//         case 'PUT':
//           response = await http
//               .put(uri, headers: requestHeaders, body: body)
//               .timeout(timeout);
//           break;
//         case 'DELETE':
//           response =
//               await http.delete(uri, headers: requestHeaders).timeout(timeout);
//           break;
//         default:
//           throw Exception('Méthode HTTP non supportée: $method');
//       }

//       print('📡 Réponse: ${response.statusCode} pour $endpoint');

//       // Si le token est expiré, essayer de le renouveler une fois et refaire la requête
//       if (response.statusCode == 401) {
//         print(
//             '🔑 Token expiré (401), tentative de renouvellement automatique...');
//         final refreshed = await refreshToken();
//         if (refreshed) {
//           final newToken = authToken!;
//           requestHeaders['Authorization'] = 'Bearer $newToken';

//           print(
//               '🔄 Token renouvelé avec succès, nouvelle tentative de requête...');

//           switch (method.toUpperCase()) {
//             case 'GET':
//               response =
//                   await http.get(uri, headers: requestHeaders).timeout(timeout);
//               break;
//             case 'POST':
//               response = await http
//                   .post(uri, headers: requestHeaders, body: body)
//                   .timeout(timeout);
//               break;
//             case 'PUT':
//               response = await http
//                   .put(uri, headers: requestHeaders, body: body)
//                   .timeout(timeout);
//               break;
//             case 'DELETE':
//               response = await http
//                   .delete(uri, headers: requestHeaders)
//                   .timeout(timeout);
//               break;
//           }

//           print(
//               '✅ Requête réessayée avec succès après renouvellement du token');
//         } else {
//           print('⚠️ Impossible de renouveler le token, mais on continue');
//         }
//       }

//       return response;
//     } catch (e) {
//       print('❌ Erreur requête $method $endpoint: $e');
//       rethrow;
//     }
//   }

//   // Méthodes de convenance
//   Future<http.Response> get(String endpoint, {Map<String, String>? headers}) =>
//       authenticatedRequest(method: 'GET', endpoint: endpoint, headers: headers);

//   Future<http.Response> post(String endpoint,
//           {Object? body, Map<String, String>? headers}) =>
//       authenticatedRequest(
//           method: 'POST', endpoint: endpoint, body: body, headers: headers);

//   Future<http.Response> put(String endpoint,
//           {Object? body, Map<String, String>? headers}) =>
//       authenticatedRequest(
//           method: 'PUT', endpoint: endpoint, body: body, headers: headers);

//   Future<http.Response> delete(String endpoint,
//           {Map<String, String>? headers}) =>
//       authenticatedRequest(
//           method: 'DELETE', endpoint: endpoint, headers: headers);

//   // Méthode utilitaire pour obtenir des informations utilisateur
//   Map<String, dynamic> get userInfo => box.read('userInfo') ?? {};

//   String? get userCardID {
//     final info = userInfo;
//     return info['cardID']?.toString();
//   }

//   String? get userName {
//     final info = userInfo;
//     final firstName = info['firstName'] ?? '';
//     final lastName = info['lastName'] ?? '';
//     return '$firstName $lastName'.trim();
//   }

//   String? get authMethod => box.read('auth_method');

//   // Déconnexion complète - seulement si forcée
//   void logout({bool force = false}) {
//     if (!force && autoRefreshEnabled.value) {
//       print('🚫 Déconnexion empêchée - auto-refresh activé');
//       showSessionDialog();
//       return;
//     }

//     clearAuthData(forceLogout: true);
//     box.remove('userInfo');
//     Get.offAllNamed('/login');
//     print('🚪 Déconnexion forcée effectuée');
//   }

//   // Afficher un dialogue au lieu de déconnecter
//   void showSessionDialog() {
//     Get.dialog(
//       AlertDialog(
//         title: Row(
//           children: [
//             Icon(Icons.info_outline, color: Colors.blue),
//             SizedBox(width: 8),
//             Text('Session en cours'),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Votre session est en cours de rafraîchissement automatique.'),
//             SizedBox(height: 12),
//             Text(
//               'Vous pouvez continuer à utiliser l\'application normalement.',
//               style: TextStyle(color: Colors.grey[600]),
//             ),
//             if (authMethod != null) ...[
//               SizedBox(height: 8),
//               Text(
//                 'Authentifié avec: ${authMethod == "phone" ? "Téléphone" : authMethod}',
//                 style: TextStyle(color: Colors.grey[600], fontSize: 12),
//               ),
//             ],
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: Text('Continuer'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               logout(force: true);
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: Text('Forcer la déconnexion'),
//           ),
//         ],
//       ),
//       barrierDismissible: false,
//     );
//   }

//   // Gestion des erreurs de session - ne plus déconnecter automatiquement
//   void handleSessionError() {
//     print('⚠️ Erreur de session détectée, tentative de récupération...');

//     refreshToken().then((success) {
//       if (success) {
//         print('✅ Session récupérée automatiquement');
//         Get.snackbar(
//           'Session rafraîchie',
//           'Votre session a été automatiquement renouvelée',
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//           duration: Duration(seconds: 3),
//         );
//       } else {
//         print('❌ Impossible de récupérer la session');
//         showSessionDialog();
//       }
//     });
//   }

//   // Contrôle du rafraîchissement automatique
//   void enableAutoRefresh() {
//     autoRefreshEnabled.value = true;
//     print('✅ Rafraîchissement automatique activé');
//   }

//   void disableAutoRefresh() {
//     autoRefreshEnabled.value = false;
//     print('🚫 Rafraîchissement automatique désactivé');
//   }

//   // Méthode pour débugger les informations stockées
//   void debugStorage() {
//     print('=== DEBUG STORAGE ===');
//     print('📱 Phone Number: $phoneNumber');
//     print(
//         '🔑 Auth Token: ${authToken != null ? "Present (${authToken!.substring(0, 10)}...)" : "Absent"}');
//     print('⏰ Token Expiry: $tokenExpiry');
//     print('✅ Is Token Valid: $isTokenValid');
//     print('🔄 Is Refreshing: ${isTokenRefreshing.value}');
//     print('🏠 Is Logged In: ${isLoggedIn.value}');
//     print('🚫 Should Logout: ${shouldLogout.value}');
//     print('🔁 Auto Refresh: ${autoRefreshEnabled.value}');
//     print('🔐 Auth Method: $authMethod');
//     print('👤 User Info: ${userInfo.isNotEmpty ? "Present" : "Absent"}');
//     print('🏷️ Card ID: $userCardID');
//     print('👥 User Name: $userName');
//     print('💰 Balance Cache: ${_balanceCache.length} entries');
//     print('==================');
//   }

//   // Vérifier l'état de la connexion réseau
//   Future<bool> checkNetworkConnection() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/auth.php'),
//         headers: {'Content-Type': 'application/json'},
//       ).timeout(Duration(seconds: 5));

//       return response.statusCode == 200 ||
//           response.statusCode ==
//               405; // 405 = Method not allowed (GET sur POST endpoint)
//     } catch (e) {
//       print('❌ Pas de connexion réseau: $e');
//       return false;
//     }
//   }

//   // Méthode pour tester l'authentification avec le téléphone
//   Future<bool> testPhoneAuth() async {
//     final phone = phoneNumber;
//     if (phone == null) {
//       print('❌ Aucun numéro de téléphone disponible');
//       return false;
//     }

//     try {
//       print('🧪 Test d\'authentification pour: $phone');

//       final response = await http
//           .post(
//             Uri.parse('$baseUrl/auth.php'),
//             headers: {'Content-Type': 'application/json'},
//             body: json.encode({
//               'device_key': deviceKey,
//               'phone': phone,
//             }),
//           )
//           .timeout(Duration(seconds: 10));

//       print('📡 Test auth response: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print('✅ Test auth réussi: ${data['status']['success']}');
//         return data['status']['success'] == true;
//       }

//       return false;
//     } catch (e) {
//       print('❌ Erreur test auth: $e');
//       return false;
//     }
//   }
// }

// class TokenExpiredException implements Exception {
//   final String message;
//   TokenExpiredException(this.message);

//   @override
//   String toString() => 'TokenExpiredException: $message';
// }

import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class TokenService extends GetxService {
  final box = GetStorage();
  static const String baseUrl = 'https://api.dev.onyfastbank.com/v2';
  static const String deviceKey =
      'b08Zhc601YHR4LCV2gSD2cppAT0Ex+7wwbwAb/Y2thg=';

  // Observable pour l'état de connexion
  var isLoggedIn = false.obs;
  var isTokenRefreshing = false.obs;
  var shouldLogout = false.obs;
  var autoRefreshEnabled = true.obs;

  // Cache pour les soldes des cartes
  final Map<String, double> _balanceCache = {};
  final Map<String, DateTime> _balanceCacheTime = {};
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
    _setupPeriodicRefresh();
  }

  void _checkAuthStatus() {
    final token = authToken;
    final phoneNumber = this.phoneNumber;
    isLoggedIn.value = token != null && phoneNumber != null;

    if (isLoggedIn.value) {
      debugStorage();
    }
  }

  /// Configure un rafraîchissement périodique automatique
  void _setupPeriodicRefresh() {
    Stream.periodic(Duration(minutes: 5)).listen((_) {
      if (autoRefreshEnabled.value && isLoggedIn.value && !isTokenValid) {
        print('🔄 Rafraîchissement périodique du token...');
        refreshToken();
      }
    });
  }

  String? get authToken => box.read('jwt_token');

  // Récupérer le numéro de téléphone depuis userInfo
  String? get phoneNumber {
    final userInfo = box.read('userInfo') ?? {};
    return userInfo['telephone']?.toString() ?? userInfo['phone']?.toString();
  }

  DateTime? get tokenExpiry {
    final expiryString = box.read('token_expiry');
    if (expiryString != null) {
      try {
        return DateTime.parse(expiryString);
      } catch (e) {
        print('❌ Erreur parsing date expiration: $e');
        return null;
      }
    }
    return null;
  }

  bool get isTokenValid {
    final expiry = tokenExpiry;
    if (expiry == null) return false;

    // Considérer le token comme expiré 5 minutes avant l'expiration réelle
    final now = DateTime.now().add(Duration(minutes: 5));
    final isValid = expiry.isAfter(now);

    if (!isValid) {
      print('⚠️ Token expiré: expire le $expiry, maintenant: $now');
    }

    return isValid;
  }

  // Sauvegarder les informations d'authentification
  void saveAuthData({
    required String token,
    required int expiresIn,
    String? authenticatedWith,
  }) {
    final expiryDate = DateTime.now().add(Duration(seconds: expiresIn));

    box.write('jwt_token', token);
    box.write('token_expiry', expiryDate.toIso8601String());
    if (authenticatedWith != null) {
      box.write('auth_method', authenticatedWith);
    }

    isLoggedIn.value = true;
    shouldLogout.value = false;

    print('✅ Données d\'authentification sauvegardées');
    print('🔑 Token expire le: $expiryDate');
    print('📱 Authentifié avec: ${authenticatedWith ?? "unknown"}');
  }

  // Effacer les données d'authentification (garde userInfo intacte)
  void clearAuthData({bool forceLogout = false}) {
    if (!forceLogout && autoRefreshEnabled.value) {
      print('🚫 Déconnexion empêchée - auto-refresh activé');
      return;
    }

    box.remove('jwt_token');
    box.remove('token_expiry');
    box.remove('auth_method');
    isLoggedIn.value = false;
    shouldLogout.value = false;

    // Vider le cache des soldes lors de la déconnexion
    _balanceCache.clear();
    _balanceCacheTime.clear();

    print('🧹 Données d\'authentification effacées');
  }

  Future<http.Response> authenticatedCardRequest(String cardID, String endpoint,
      {Map<String, String>? headers}) async {
    if (!isTokenValid || !_isTokenForCardID(authToken, cardID)) {
      final refreshed = await refreshToken();
      if (!refreshed) {
        throw TokenExpiredException('Token expiré ou invalide');
      }

      final tokenForCard = await _createCardAuthToken(cardID);
      if (tokenForCard == null) {
        throw TokenExpiredException(
            'Impossible de créer un token pour la carte');
      }

      return await _makeAuthenticatedBalanceRequest(cardID, tokenForCard);
    }

    return await _makeAuthenticatedBalanceRequest(cardID, authToken!);
  }

  Future<String?> _createCardAuthToken(String cardID) async {
    try {
      print('🔑 Création d\'un token pour la carte: $cardID');

      final body = json.encode({
        'device_key': deviceKey,
        'cardID': cardID,
      });

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth.php'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(Duration(seconds: 15));

      final data = json.decode(response.body);
      print('🧪 Réponse création token carte : $data');

      if (data['status']?['success'] == true &&
          data['status']?['data']?['token'] != null) {
        return data['status']['data']['token'];
      }

      return null;
    } catch (e) {
      print('❌ Erreur création token carte : $e');
      return null;
    }
  }

  Future<String?> createCardAuthToken(String cardID) async {
    try {
      print('🔑 Création d\'un token pour la carte: $cardID');

      final body = json.encode({
        'device_key': deviceKey,
        'cardID': cardID,
      });

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth.php'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(Duration(seconds: 15));

      final data = json.decode(response.body);
      print('🧪 Réponse création token carte : $data');

      if (data['status']?['success'] == true &&
          data['status']?['data']?['token'] != null) {
        return data['status']['data']['token'];
      }

      return null;
    } catch (e) {
      print('❌ Erreur création token carte : $e');
      return null;
    }
  }

  // Renouveler le token automatiquement avec le nouveau système d'auth
  Future<bool> refreshToken({int maxRetries = 3}) async {
    if (isTokenRefreshing.value) {
      print('⏳ Rafraîchissement déjà en cours, attente...');
      await Future.doWhile(() async {
        await Future.delayed(Duration(milliseconds: 500));
        return isTokenRefreshing.value;
      });
      return isTokenValid;
    }

    try {
      isTokenRefreshing.value = true;
      shouldLogout.value = false;

      final currentPhoneNumber = phoneNumber;
      if (currentPhoneNumber == null) {
        print('❌ Numéro de téléphone non disponible pour le renouvellement');
        return await _createTemporarySession();
      }

      print('🔄 Renouvellement du token pour: $currentPhoneNumber');

      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          print('🔄 Tentative $attempt/$maxRetries de renouvellement');

          // Utiliser le nouveau système d'auth par téléphone
          final response = await http
              .post(
                Uri.parse('$baseUrl/auth.php'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode({
                  'device_key': deviceKey,
                  'phone': currentPhoneNumber,
                }),
              )
              .timeout(Duration(seconds: 15));

          print('📡 Réponse auth.php: ${response.statusCode}');

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            print('📱 Réponse du serveur (tentative $attempt): $data');

            // CORRECTION: Accéder aux données du token dans la bonne structure
            if (data['status']['success'] == true &&
                data['status']['data'] != null) {
              final tokenData = data['status']['data'];

              saveAuthData(
                token: tokenData['token'],
                expiresIn: tokenData['expires_in'] ?? 86400,
                authenticatedWith: tokenData['authenticated_with'] ?? 'phone',
              );
              print('✅ Token renouvelé avec succès à la tentative $attempt');
              return true;
            } else {
              print(
                  '❌ Échec du renouvellement tentative $attempt: ${data['status']['message']}');
            }
          } else {
            print('❌ Erreur HTTP tentative $attempt: ${response.statusCode}');
            print('📄 Body: ${response.body}');
          }
        } catch (e) {
          print('❌ Erreur tentative $attempt: $e');
        }

        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }

      print('⚠️ Échec de toutes les tentatives, création session temporaire');
      return await _createTemporarySession();
    } catch (e) {
      print('❌ Erreur générale lors du renouvellement du token: $e');
      return await _createTemporarySession();
    } finally {
      isTokenRefreshing.value = false;
    }
  }

  /// Crée une session temporaire pour maintenir l'accès
  Future<bool> _createTemporarySession() async {
    try {
      final tempToken = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final tempExpiry = DateTime.now().add(Duration(hours: 2));

      box.write('jwt_token', tempToken);
      box.write('token_expiry', tempExpiry.toIso8601String());
      box.write('auth_method', 'temporary');

      isLoggedIn.value = true;
      shouldLogout.value = false;

      print('🆘 Session temporaire créée: expire le $tempExpiry');

      // Programmer une nouvelle tentative de refresh dans 10 minutes
      Future.delayed(Duration(minutes: 10), () {
        if (authToken == tempToken) {
          print('🔄 Tentative de remplacement de la session temporaire');
          refreshToken();
        }
      });

      return true;
    } catch (e) {
      print('❌ Erreur création session temporaire: $e');
      return false;
    }
  }

  // NOUVELLE MÉTHODE: Récupération du solde avec auth cardID et token JWT
  Future<double?> getCardBalance(String cardID,
      {bool forceRefresh = false}) async {
    if (cardID.isEmpty) return null;

    // Vérifier le cache si pas de refresh forcé
    if (!forceRefresh && _balanceCache.containsKey(cardID)) {
      final cacheTime = _balanceCacheTime[cardID];
      if (cacheTime != null &&
          DateTime.now().difference(cacheTime) < _cacheValidDuration) {
        print(
            '💰 Solde récupéré depuis le cache: ${_balanceCache[cardID]} XAF');
        return _balanceCache[cardID];
      }
    }

    try {
      print('💰 Récupération du solde pour la carte: $cardID');

      // S'assurer d'avoir un token valide avant l'appel
      if (!isTokenValid) {
        print('🔄 Token invalide, rafraîchissement automatique...');
        final refreshed = await refreshToken();
        if (!refreshed) {
          throw Exception(
              'Impossible de rafraîchir le token d\'authentification');
        }
      }

      // Créer un token spécifique pour cette carte si nécessaire
      String? authTokenForCard = authToken;

      // Si le token actuel n'est pas basé sur cardID, en créer un nouveau
      if (!_isTokenForCardID(authTokenForCard, cardID)) {
        print('🔑 Création d\'un token spécifique pour la carte $cardID');
        authTokenForCard = await _createCardAuthToken(cardID);

        if (authTokenForCard == null) {
          throw Exception(
              'Impossible de créer un token d\'authentification pour cette carte');
        }
      }

      // Effectuer l'appel avec le token approprié
      final response =
          await _makeAuthenticatedBalanceRequest(cardID, authTokenForCard!);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Gestion flexible des différents formats de réponse
        bool isSuccess = false;
        dynamic balanceData;

        if (data['success'] == true) {
          isSuccess = true;
          balanceData = data['data'];
        } else if (data['status'] == 'success') {

          isSuccess = true;
          balanceData = data['data'];

        } else if (data['status']['success'] == true) {
          isSuccess = true;
          balanceData = data['status']['data'];
        }

        if (isSuccess && balanceData != null) {
          // Essayer différents champs pour le solde
          dynamic rawBalance = balanceData['balance'] ??
              balanceData['amount'] ??
              balanceData['solde'] ??
              balanceData['montant'];

          final balance = double.tryParse(rawBalance.toString());

          if (balance != null) {
            // Mettre à jour le cache
            _balanceCache[cardID] = balance;
            _balanceCacheTime[cardID] = DateTime.now();
            print('✅ Solde récupéré: $balance XAF');
            return balance;
          } else {
            print('⚠️ Balance reçue mais format invalide: $rawBalance');
          }
        } else {
          final message = data['message'] ??
              data['error'] ??
              data['status']['message'] ??
              'Erreur inconnue';
          print('❌ Erreur API: $message');
          throw Exception(message);
        }
      } else if (response.statusCode == 401) {
        print('🔄 Token expiré ou invalide, nouvelle tentative...');

        // Token expiré, essayer de le rafraîchir et réessayer
        final refreshed = await refreshToken();
        if (refreshed) {
          final newAuthToken = await _createCardAuthToken(cardID);

          if (newAuthToken != null) {
            // Nouvelle tentative avec le token rafraîchi
            final retryResponse =
                await _makeAuthenticatedBalanceRequest(cardID, newAuthToken);

            if (retryResponse.statusCode == 200) {
              final data = json.decode(retryResponse.body);

              bool isSuccess = false;
              dynamic balanceData;

              if (data['success'] == true) {
                isSuccess = true;
                balanceData = data['data'];
              } else if (data['status'] == 'success') {
                isSuccess = true;
                balanceData = data['data'];
              } else if (data['status']['success'] == true) {
                isSuccess = true;
                balanceData = data['status']['data'];
              }

              if (isSuccess && balanceData != null) {
                dynamic rawBalance = balanceData['balance'] ??
                    balanceData['amount'] ??
                    balanceData['solde'] ??
                    balanceData['montant'];

                final balance = double.tryParse(rawBalance.toString());
                if (balance != null) {
                  _balanceCache[cardID] = balance;
                  _balanceCacheTime[cardID] = DateTime.now();
                  print('✅ Solde récupéré après refresh: $balance XAF');
                  return balance;
                }
              }
            }
          }
        }

        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else if (response.statusCode == 403) {
        throw Exception('Accès non autorisé pour cette carte');
      } else if (response.statusCode == 404) {
        throw Exception('Carte non trouvée ou service indisponible');
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération du solde: $e');

      // Gestion spécifique des erreurs
      if (e.toString().contains('SocketException')) {
        throw Exception('Problème de connexion réseau');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Délai d\'attente dépassé');
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Erreur de format des données');
      }

      // Ne pas supprimer du cache en cas d'erreur, garder la dernière valeur connue
      rethrow;
    }

    return null;
  }

  /// Vérifie si le token actuel est basé sur le cardID spécifié
  bool _isTokenForCardID(String? token, String cardID) {
    if (token == null) return false;

    try {
      // Décoder le payload du JWT pour vérifier le cardID
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final payload = parts[1];
      final normalizedPayload = _base64Normalize(payload);
      final decodedBytes = base64.decode(normalizedPayload);
      final decodedPayload = utf8.decode(decodedBytes);
      final payloadJson = json.decode(decodedPayload);

      return payloadJson['cardID'] == cardID;
    } catch (e) {
      print('❌ Erreur lors de la vérification du token: $e');
      return false;
    }
  }

  /// Normalise une chaîne base64
  String _base64Normalize(String base64) {
    String normalized = base64.replaceAll('-', '+').replaceAll('_', '/');

    // Ajouter le padding si nécessaire
    switch (normalized.length % 4) {
      case 2:
        normalized += '==';
        break;
      case 3:
        normalized += '=';
        break;
    }

    return normalized;
  }

  /// Crée un token d'authentification spécifique pour un cardID
  Future<String?> createCardToken(String cardID) async {
    try {
      print('🔑 Création token pour cardID: $cardID');
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth.php'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'device_key': deviceKey,
              'cardID': cardID,
            }),
          )
          .timeout(Duration(seconds: 10));

      final data = json.decode(response.body);
      print('🧪 Réponse auth token: ${json.encode(data)}');

      if (data['status']?['success'] == true &&
          data['status']?['data']?['token'] != null) {
        // print(data['status']['data']['token']);
        return data['status']['data']['token'];
      } else {
        print('❌ Token non retourné : ${data['status']?['message']}');
        return null;
      }
    } catch (e) {
      print('❌ Erreur createCardToken: $e');
      return null;
    }
  }

  /// Effectue l'appel authentifié pour récupérer le solde
  Future<http.Response> _makeAuthenticatedBalanceRequest(
      String cardID, String authTokenForCard) async {
    final url = Uri.parse('$baseUrl/balance.php?cardID=$cardID');

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $authTokenForCard',
      'X-Device-Key': deviceKey,
    };

    print('📡 Appel balance API: $url');
    print('🔑 Token utilisé: ${authTokenForCard.substring(0, 20)}...');

    return await http.get(url, headers: headers).timeout(Duration(seconds: 15));
  }

  /// Vider le cache des soldes
  void clearBalanceCache() {
    _balanceCache.clear();
    _balanceCacheTime.clear();
    print('🧹 Cache des soldes vidé');
  }

  /// Obtenir un solde depuis le cache uniquement
  double? getCachedBalance(String cardID) {
    if (_balanceCache.containsKey(cardID)) {
      final cacheTime = _balanceCacheTime[cardID];
      if (cacheTime != null &&
          DateTime.now().difference(cacheTime) < _cacheValidDuration) {
        return _balanceCache[cardID];
      }
    }
    return null;
  }

  // Faire une requête authentifiée avec gestion automatique du token
  Future<http.Response> authenticatedRequest({
    required String method,
    required String endpoint,
    Map<String, String>? headers,
    Object? body,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    // Vérifier si le token est valide
    if (!isTokenValid) {
      print('🔄 Token expiré, renouvellement préventif...');
      final refreshed = await refreshToken();
      if (!refreshed) {
        print('⚠️ Refresh échoué, tentative de requête quand même');
      }
    }

    final token = authToken;
    print('🔑 Token utilisé: ${token?.substring(0, 20)}...');
    if (token == null) {
      throw TokenExpiredException('Token non disponible');
    }

    final requestHeaders = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'OnyFast-Mobile-App',
      ...?headers,
    };

    final uri = Uri.parse('$baseUrl/$endpoint');
    print('🌐 Requête: $method $uri');

    http.Response response;

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response =
              await http.get(uri, headers: requestHeaders).timeout(timeout);
          break;
        case 'POST':
          response = await http
              .post(uri, headers: requestHeaders, body: body)
              .timeout(timeout);
          break;
        case 'PUT':
          response = await http
              .put(uri, headers: requestHeaders, body: body)
              .timeout(timeout);
          break;
        case 'DELETE':
          response =
              await http.delete(uri, headers: requestHeaders).timeout(timeout);
          break;
        default:
          throw Exception('Méthode HTTP non supportée: $method');
      }

      print('📡 Réponse: ${response.statusCode} pour $endpoint');

      // Si le token est expiré, essayer de le renouveler une fois et refaire la requête
      if (response.statusCode == 401) {
        print(
            '🔑 Token expiré (401), tentative de renouvellement automatique...');
        final refreshed = await refreshToken();
        if (refreshed) {
          final newToken = authToken!;
          requestHeaders['Authorization'] = 'Bearer $newToken';

          print(
              '🔄 Token renouvelé avec succès, nouvelle tentative de requête...');

          switch (method.toUpperCase()) {
            case 'GET':
              response =
                  await http.get(uri, headers: requestHeaders).timeout(timeout);
              break;
            case 'POST':
              response = await http
                  .post(uri, headers: requestHeaders, body: body)
                  .timeout(timeout);
              break;
            case 'PUT':
              response = await http
                  .put(uri, headers: requestHeaders, body: body)
                  .timeout(timeout);
              break;
            case 'DELETE':
              response = await http
                  .delete(uri, headers: requestHeaders)
                  .timeout(timeout);
              break;
          }

          print(
              '✅ Requête réessayée avec succès après renouvellement du token');
        } else {
          print('⚠️ Impossible de renouveler le token, mais on continue');
        }
      }

      return response;
    } catch (e) {
      print('❌ Erreur requête $method $endpoint: $e');
      rethrow;
    }
  }

  // Méthodes de convenance
  Future<http.Response> get(String endpoint, {Map<String, String>? headers}) =>
      authenticatedRequest(method: 'GET', endpoint: endpoint, headers: headers);

  Future<http.Response> post(String endpoint,
          {Object? body, Map<String, String>? headers}) =>
      authenticatedRequest(
          method: 'POST', endpoint: endpoint, body: body, headers: headers);

  Future<http.Response> put(String endpoint,
          {Object? body, Map<String, String>? headers}) =>
      authenticatedRequest(
          method: 'PUT', endpoint: endpoint, body: body, headers: headers);

  Future<http.Response> delete(String endpoint,
          {Map<String, String>? headers}) =>
      authenticatedRequest(
          method: 'DELETE', endpoint: endpoint, headers: headers);

  // Méthode utilitaire pour obtenir des informations utilisateur
  Map<String, dynamic> get userInfo => box.read('userInfo') ?? {};

  String? get userCardID {
    final info = userInfo;
    return info['cardID']?.toString();
  }

  String? get userName {
    final info = userInfo;
    final firstName = info['firstName'] ?? '';
    final lastName = info['lastName'] ?? '';
    return '$firstName $lastName'.trim();
  }

  String? get authMethod => box.read('auth_method');

  // Déconnexion complète - seulement si forcée
  void logout({bool force = false}) {
    if (!force && autoRefreshEnabled.value) {
      print('🚫 Déconnexion empêchée - auto-refresh activé');
      showSessionDialog();
      return;
    }

    clearAuthData(forceLogout: true);
    box.remove('userInfo');
    Get.offAllNamed('/login');
    print('🚪 Déconnexion forcée effectuée');
  }

  // Afficher un dialogue au lieu de déconnecter
  void showSessionDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Session en cours'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Votre session est en cours de rafraîchissement automatique.'),
            SizedBox(height: 12),
            Text(
              'Vous pouvez continuer à utiliser l\'application normalement.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (authMethod != null) ...[
              SizedBox(height: 8),
              Text(
                'Authentifié avec: ${authMethod == "phone" ? "Téléphone" : authMethod}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Continuer'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              logout(force: true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Forcer la déconnexion'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Gestion des erreurs de session - ne plus déconnecter automatiquement
  void handleSessionError() {
    print('⚠️ Erreur de session détectée, tentative de récupération...');

    refreshToken().then((success) {
      if (success) {
        print('✅ Session récupérée automatiquement');
        // Get.snackbar(
        //   'Session rafraîchie',
        //   'Votre session a été automatiquement renouvelée',
        //   snackPosition: SnackPosition.TOP,
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        //   duration: Duration(seconds: 3),
        // );
      } else {
        print('❌ Impossible de récupérer la session');
        showSessionDialog();
      }
    });
  }

  // Contrôle du rafraîchissement automatique
  void enableAutoRefresh() {
    autoRefreshEnabled.value = true;
    print('✅ Rafraîchissement automatique activé');
  }

  void disableAutoRefresh() {
    autoRefreshEnabled.value = false;
    print('🚫 Rafraîchissement automatique désactivé');
  }

  // Méthode pour débugger les informations stockées
  void debugStorage() {
    print('=== DEBUG STORAGE ===');
    print('📱 Phone Number: $phoneNumber');
    print(
        '🔑 Auth Token: ${authToken != null ? "Present (${authToken!.substring(0, 10)}...)" : "Absent"}');
    print('⏰ Token Expiry: $tokenExpiry');
    print('✅ Is Token Valid: $isTokenValid');
    print('🔄 Is Refreshing: ${isTokenRefreshing.value}');
    print('🏠 Is Logged In: ${isLoggedIn.value}');
    print('🚫 Should Logout: ${shouldLogout.value}');
    print('🔁 Auto Refresh: ${autoRefreshEnabled.value}');
    print('🔐 Auth Method: $authMethod');
    print('👤 User Info: ${userInfo.isNotEmpty ? "Present" : "Absent"}');
    print('🏷️ Card ID: $userCardID');
    print('👥 User Name: $userName');
    print('💰 Balance Cache: ${_balanceCache.length} entries');
    print('==================');
  }

  // Vérifier l'état de la connexion réseau
  Future<bool> checkNetworkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth.php'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 5));

      return response.statusCode == 200 ||
          response.statusCode ==
              405; // 405 = Method not allowed (GET sur POST endpoint)
    } catch (e) {
      print('❌ Pas de connexion réseau: $e');
      return false;
    }
  }

  // Méthode pour tester l'authentification avec le téléphone
  Future<bool> testPhoneAuth() async {
    final phone = phoneNumber;
    if (phone == null) {
      print('❌ Aucun numéro de téléphone disponible');
      return false;
    }

    try {
      print('🧪 Test d\'authentification pour: $phone');

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth.php'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'device_key': deviceKey,
              'phone': phone,
            }),
          )
          .timeout(Duration(seconds: 10));

      print('📡 Test auth response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Test auth réussi: ${data['status']['success']}');
        return data['status']['success'] == true;
      }

      return false;
    } catch (e) {
      print('❌ Erreur test auth: $e');
      return false;
    }
  }
}

class TokenExpiredException implements Exception {
  final String message;
  TokenExpiredException(this.message);

  @override
  String toString() => 'TokenExpiredException: $message';
}
