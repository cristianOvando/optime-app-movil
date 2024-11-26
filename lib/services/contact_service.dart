import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ContactService {
  static Future<Map<String, dynamic>?> createContact(String email, String name, String lastName, String phone) async {
    try {
      final url = Uri.parse('${Constants.baseUrl}/contacts');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'name': name,
          'last_name': lastName,
          'phone': phone,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        return {
          'error': 'Error: ${response.statusCode}',
          'message': jsonDecode(response.body)['detail'] ?? 'Error de validación',
        };
      } else {
        return {
          'error': 'Error: ${response.statusCode}',
          'message': 'Error inesperado',
        };
      }
    } catch (e) {
      return {'error': 'Exception', 'message': e.toString()};
    }
  }
}
