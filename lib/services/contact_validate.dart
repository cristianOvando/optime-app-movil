import 'dart:convert';
import 'package:http/http.dart' as http;

class ContactValidateService {
  static Future<Map<String, dynamic>?> validateContact(String contactId, String otp) async {
    try {
      final url = Uri.parse('https://gazxiyw6xpb23pniw76bmgjibq0hlnuz.lambda-url.us-east-1.on.aws/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contact_id': contactId,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
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
