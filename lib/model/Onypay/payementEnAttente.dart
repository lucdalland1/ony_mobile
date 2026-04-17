class PendingPaymentsResponse {
  final bool success;
  final List<PendingPayment> data;
  final int count;

  PendingPaymentsResponse({
    required this.success,
    required this.data,
    required this.count,
  });

  factory PendingPaymentsResponse.fromJson(Map<String, dynamic> json) {
    return PendingPaymentsResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => PendingPayment.fromJson(e))
          .toList(),
      count: json['count'] ?? 0,
    );
  }
}
class PendingPayment {
  final int otpId;
  final String paymentId;
  final double amount;
  final String currency;
  final String description;
  final String merchant;
  final int attemptsLeft;
  final DateTime expiresAt;
  final double ttlSeconds;

  PendingPayment({
    required this.otpId,
    required this.paymentId,
    required this.amount,
    required this.currency,
    required this.description,
    required this.merchant,
    required this.attemptsLeft,
    required this.expiresAt,
    required this.ttlSeconds,
  });

  factory PendingPayment.fromJson(Map<String, dynamic> json) {
    return PendingPayment(
      otpId: json['otp_id'] ?? 0,
      paymentId: json['payment_id'] ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      currency: json['currency'] ?? '',
      description: json['description'] ?? '',
      merchant: json['merchant'] ?? '',
      attemptsLeft: json['attempts_left'] ?? 0,
      expiresAt: DateTime.tryParse(json['expires_at'] ?? '') ?? DateTime.now(),
      ttlSeconds: (json['ttl_seconds'] as num?)?.toDouble() ?? 0.0,
    );
  }
}