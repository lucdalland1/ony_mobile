class ApiResponse {
  final String message;
  final bool success;

  ApiResponse({required this.message, required this.success});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      message: json['message'],
      success: json['success'],
    );
  }
}
