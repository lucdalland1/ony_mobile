import 'package:get_storage/get_storage.dart';

class User {
  String telephone;
  String password;
  String confirmPassword;
  String otp;

  // Constructeur vide par défaut
  User.empty()
      : telephone = '',
        password = '',
        confirmPassword = '',
        otp = '';

  // Factory pour créer un utilisateur depuis le stockage
  factory User.fromStorage(GetStorage storage) {
    return User.empty()
      ..telephone = storage.read('register_phone') ?? ''
      ..password = storage.read('temp_password') ?? ''
      ..confirmPassword = storage.read('temp_confirm_password') ?? '';
  }

  // Sauvegarde des informations temporaires de l'utilisateur
  void saveTempCredentials(GetStorage storage) {
    if (telephone.isNotEmpty) {
      storage.write('register_phone', telephone);
    }
    if (password.isNotEmpty) {
      storage.write('temp_password', password);
    }
    if (confirmPassword.isNotEmpty) {
      storage.write('temp_confirm_password', confirmPassword);
    }
  }

  // Méthode pour vider les informations temporaires
  void clearTempCredentials(GetStorage storage) {
    storage.remove('register_phone');
    storage.remove('temp_password');
    storage.remove('temp_confirm_password');
  }
}