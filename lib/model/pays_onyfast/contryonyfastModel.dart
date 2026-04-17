class ContryOnyfast {
  final int id;
  final String designation;
  final String programme;
  final String code;
  final String indicatif;
  final int userId;
  final String startDate; // tu peux passer en DateTime si tu préfères
  final String? endDate;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  ContryOnyfast({
    required this.id,
    required this.designation,
    required this.programme,
    required this.code,
    required this.indicatif,
    required this.userId,
    required this.startDate,
    required this.createdAt,
    required this.updatedAt,
    this.endDate,
    this.deletedAt,
  });

  factory ContryOnyfast.fromJson(Map<String, dynamic> j) => ContryOnyfast(
        id: j['id'] as int,
        designation: j['designation']?.toString() ?? '',
        programme: j['programme']?.toString() ?? '',
        code: j['code']?.toString() ?? '',
        indicatif: j['indicatif']?.toString() ?? '',
        userId: (j['user_id'] ?? 0) as int,
        startDate: j['startDate']?.toString() ?? '',
        endDate: j['endDate']?.toString(),
        deletedAt: j['deleted_at']?.toString(),
        createdAt: j['created_at']?.toString() ?? '',
        updatedAt: j['updated_at']?.toString() ?? '',
      );
}

class ContryOnyfastResponse {
  final bool success;
  final String? message;
  final List<ContryOnyfast> data;

  ContryOnyfastResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory ContryOnyfastResponse.fromJson(Map<String, dynamic> j) {
    final List list = (j['data'] as List?) ?? [];
    return ContryOnyfastResponse(
      success: j['success'] == true,
      message: j['message']?.toString(),
      data: list.map((e) => ContryOnyfast.fromJson(e)).toList(),
    );
  }
}
