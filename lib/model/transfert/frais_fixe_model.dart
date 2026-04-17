class FraisFixeModel {
  final int pourcentage;
  final String designation;

  FraisFixeModel({
    required this.pourcentage,
    required this.designation,
  });

  factory FraisFixeModel.fromJson(Map<String, dynamic> json) {
    return FraisFixeModel(
      pourcentage: json['pourcentage'],
      designation: json['designation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pourcentage': pourcentage,
      'designation': designation,
    };
  }
}
