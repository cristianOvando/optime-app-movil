import 'dart:convert';
import 'package:http/http.dart' as http;

class ContactService {
  static Future<Map<String, dynamic>?> createContact(
      String email, String name, String lastName, String phone) async {
    try {
      final url = Uri.parse('http://52.72.86.85:8000/api/v1/contacts/');
      print('URL: $url'); 
      print('Cuerpo de la solicitud: ${jsonEncode({
        'email': email,
        'name': name,
        'last_name': lastName,
        'phone': phone,
      })}');

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

      print('Estado de la respuesta: ${response.statusCode}'); 
      print('Cuerpo de la respuesta: ${response.body}'); 

      if (response.statusCode == 200 || response.statusCode == 201) {
       
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
      print('Excepción: $e');
      return {'error': 'Exception', 'message': e.toString()};
    }
  }
}