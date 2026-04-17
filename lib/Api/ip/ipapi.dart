import 'package:http/http.dart' as http;

Future<String> getPublicIP() async {
  final response = await http.get(Uri.parse('https://api.ipify.org'));
  return response.body;
}