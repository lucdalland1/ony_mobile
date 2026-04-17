class Bank {
  final int id;
  final String designation;

  Bank({required this.id, required this.designation});

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'],
      designation: json['designation'],
    );
  }
}