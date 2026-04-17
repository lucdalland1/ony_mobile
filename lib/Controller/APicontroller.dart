// import 'package:get/get.dart';
// import '../Api/Userapi.dart';
// import '../model/userapi.dart';

// class AuthController extends GetxController {
//   final AuthService _authService = AuthService();
//   var isLoggedIn = false.obs;
//   var userProfile = User(phone: '', password: '').obs;

//   Future<void> login(String phone, String password) async {
//     isLoggedIn.value = await _authService.login(telephone, password);
//     if (isLoggedIn.value) {
//       userProfile.value = (await _authService.getProfile())!;
//     }
//   }

//   Future<void> loadProfile() async {
//     final user = await _authService.getProfile();
//     if (user != null) {
//       userProfile.value = user;
//       isLoggedIn.value = true;
//     }
//   }
// }