import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onyfast/model/IpAddressNetwork/addressNetword.dart';

class IpInfoService {
  static const String _baseUrl = "https://ipinfo.io/json";
  // Pour production :
  // static const String _baseUrl = "https://ipinfo.io/json?token=TON_TOKEN";

  static Future<NetworkInfoModel?> getNetworkInfo() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NetworkInfoModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print("Erreur IpInfoService: $e");
      return null;
    }
  }
}