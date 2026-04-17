import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:onyfast/View/home.dart';

class ApiManager {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController Passwordcontroller= TextEditingController();
  bool isLoading = false;

  void dispose() {
    phoneController.dispose();
    Passwordcontroller.dispose();
  }

  Future<void> login(BuildContext context, String phone, String password) async {
    phone =phoneController.text;
    password = Passwordcontroller.text;
    if (!formKey.currentState!.validate()) return;

    isLoading = true;

    try {
      final response = await _performLogin();
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status']['code'] == 200) {
        _navigateToHome(context);
      } else {
        _showSnackBar(context, data['message'] ?? 'Erreur d\'authentification');
      }
    } catch (e) {
      _showSnackBar(context, 'Erreur de connexion');
    } finally {
      isLoading = false;
    }
  }

  Future<http.Response> _performLogin() {
    final uri = Uri.parse(
      'https://api.dev.onyfastbank.com/v1/auth2.php?method=login&phone=${phoneController.text}&password=${Passwordcontroller.text}',
    );
    return http.get(uri);
  }

  void _navigateToHome(BuildContext context) {
    if (!Navigator.of(context).canPop()) return; // Check if can pop to avoid errors
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => Home()),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
