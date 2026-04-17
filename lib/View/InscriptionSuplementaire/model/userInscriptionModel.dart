// ignore: file_names
class UserInscriptionModel {
  int id;
  String name;
  String email;
  String prenom;
  String adresse;
  String? profilePhotoPath;

  UserInscriptionModel({
    required this.id,
    required this.name,
    required this.email,
    required this.prenom,
    required this.adresse,
    this.profilePhotoPath,
  });

  factory UserInscriptionModel.fromJson(Map<String, dynamic> json) => UserInscriptionModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        prenom: json['prenom'],
        adresse: json['adresse'],
        profilePhotoPath: json['profile_photo_path'],
      );
}
