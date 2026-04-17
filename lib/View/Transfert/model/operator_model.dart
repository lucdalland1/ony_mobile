class OperatorModel {
  final bool success;
  final List<Operator> operators;

  OperatorModel({
    required this.success,
    required this.operators,
  });

  factory OperatorModel.fromJson(Map<String, dynamic> json) {
    return OperatorModel(
      success: json['success'] ?? false,
      operators: (json['operators'] as List)
          .map((e) => Operator.fromJson(e))
          .toList(),
    );
  }
}

class Operator {
  final int id;
  final String name;
  final String imagePath;

  Operator({
    required this.id,
    required this.name,
    required this.imagePath,
  });

  factory Operator.fromJson(Map<String, dynamic> json) {
    return Operator(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imagePath: json['logo_url'] ?? '',
    );
  }
}
