import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class AuthService {
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final url = Uri.parse('${Constants.baseUrl}/users/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Error: ${response.statusCode}', 'message': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'error': 'Exception', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> register(String username, String password, String contactId) async {
    try {
      final url = Uri.parse('${Constants.baseUrl}/users');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'contact_id': contactId,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Error: ${response.statusCode}', 'message': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'error': 'Exception', 'message': e.toString()};
    }
  }
}
