class TypePieceModel {
  final int id;
  final String designation;
  final String? description;

  TypePieceModel({
    required this.id,
    required this.designation,
    this.description,
  });

  factory TypePieceModel.fromJson(Map<String, dynamic> json) {
    return TypePieceModel(
      id: json['id'],
      designation: json['designation'],
      description: json['description'],
    );
  }
}
