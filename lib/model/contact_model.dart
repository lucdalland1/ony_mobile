// ========================================
// Model/contact_model.dart
// ========================================
class ContactModel {
  final String? id;
  final String name;
  final String phone;
  final String? avatar;
  final String? image;
  bool isOnyfast;
  final String? email;

  ContactModel({
    this.id,
    required this.name,
    required this.phone,
    this.avatar,
    this.image,
    this.isOnyfast = false,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'image': image,
      'isOnyfast': isOnyfast,
      'email': email,
    };
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      id: map['id']?.toString(),
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      avatar: map['avatar'],
      image: map['image'],
      isOnyfast: map['isOnyfast'] ?? false,
      email: map['email'],
    );
  }
}
