class OtpResponse {
  final bool success;
  final String otp;
  final SmsResponse smsResponse;

  OtpResponse({
    required this.success,
    required this.otp,
    required this.smsResponse,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      success: json['success'],
      otp: json['otp'],
      smsResponse: SmsResponse.fromJson(json['sms_response']),
    );
  }
}

class SmsResponse {
  final bool success;
  final String data;

  SmsResponse({
    required this.success,
    required this.data,
  });

  factory SmsResponse.fromJson(Map<String, dynamic> json) {
    return SmsResponse(
      success: json['success'],
      data: json['data'],
    );
  }
}