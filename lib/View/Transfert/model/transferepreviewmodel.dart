class TransferPreviewResponse {
  final bool status;
  final String message;
  final dynamic data; 
  // Remplace "dynamic" par un vrai modèle si tu connais la structure

  TransferPreviewResponse( {
    required this.status,
    required this.message,
    this.data,
  });

  factory TransferPreviewResponse.fromJson(Map<String, dynamic> json) {
    return TransferPreviewResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}
