    import 'dart:convert';
    import 'package:http/http.dart' as http;
    import '../utils/constants.dart';
    import 'package:shared_preferences/shared_preferences.dart';

    class AuthService {
      static Future<Map<String, dynamic>?> login(String username, String password) async {
      try {
        final url = Uri.parse('${Constants.baseUrl}/users/login');
        print('URL: $url');
        print('Enviando datos: username=$username, password=<oculto por seguridad>');

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        );

        print('Respuesta recibida: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);

          if (body.containsKey('access_token')) {
          
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('access_token', body['access_token']);
            await prefs.setString('token_type', body['token_type']);
            await prefs.setInt('user_id', body['user_id']);
            print('Token guardado: ${body['access_token']}');
            return body;
          } else {
            print('Respuesta sin token de acceso');
            return {
              'error': 'Invalid response format',
              'message': 'La API no devolvió los datos esperados.'
            };
          }
        } else {
          String? errorMessage;
          try {
            final errorBody = jsonDecode(response.body);
            errorMessage = errorBody['message'];
          } catch (e) {
            errorMessage = 'Error desconocido.';
          }
          return {
            'error': 'Error: ${response.statusCode}',
            'message': errorMessage,
          };
        }
      } catch (e) {
        print('Excepción: $e');
        return {'error': 'Exception', 'message': e.toString()};
      }
    }

      static Future<void> logout() async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        print('Sesión cerrada, datos eliminados.');
      }

      Future<Map<String, String>> getAuthHeader() async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        final tokenType = prefs.getString('token_type');

        if (token == null || tokenType == null) {
          throw Exception('Token de autorización no disponible');
        }

        return {
          'Authorization': '$tokenType $token',
          'Content-Type': 'application/json',
        };
      }

      static Future<Map<String, dynamic>?> getUserInfo(int userId) async {
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          final tokenType = prefs.getString('token_type');

          if (token == null || tokenType == null) {
            throw Exception('Token no disponible. Inicia sesión nuevamente.');
          }

          final url = Uri.parse('${Constants.baseUrl}/users/$userId');
          print('URL para obtener usuario: $url');

          final response = await http.get(
            url,
            headers: {
              'Authorization': '$tokenType $token',
              'Content-Type': 'application/json',
            },
          );

          print('Respuesta de obtener usuario: ${response.statusCode}');
          print('Cuerpo: ${response.body}');

          if (response.statusCode == 200) {
            return jsonDecode(response.body);
          } else if (response.statusCode == 404) {
            return {'error': 'Usuario no encontrado', 'message': 'ID no válido.'};
          } else {
            return {'error': 'Error desconocido', 'message': response.body};
          }
        } catch (e) {
          print('Excepción en getUserInfo: $e');
          return {'error': 'Exception', 'message': e.toString()};
        }
      }

      static Future<Map<String, dynamic>?> updatePassword(int userId, String newPassword) async {
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          final tokenType = prefs.getString('token_type');

          if (token == null || tokenType == null) {
            throw Exception('Token no disponible. Inicia sesión nuevamente.');
          }

          final url = Uri.parse('${Constants.baseUrl}/users/$userId');
          print('URL para actualizar contraseña: $url');

          final response = await http.put(
            url,
            headers: {
              'Authorization': '$tokenType $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'password': newPassword}),
          );

          print('Respuesta de actualizar contraseña: ${response.statusCode}');
          print('Cuerpo: ${response.body}');

          if (response.statusCode == 200) {
            return jsonDecode(response.body);
          } else if (response.statusCode == 404) {
            return {'error': 'Usuario no encontrado', 'message': 'ID no válido.'};
          } else {
            return {
              'error': 'Error: ${response.statusCode}',
              'message': jsonDecode(response.body)['message'] ?? 'Error inesperado',
            };
          }
        } catch (e) {
          print('Excepción en updatePassword: $e');
          return {'error': 'Exception', 'message': e.toString()};
        }
      }

      static Future<Map<String, dynamic>?> register(String username, String password, String contactId) async {
      try {
        final url = Uri.parse('${Constants.baseUrl}/users/');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username,
            'password': password,
            'contact_id': contactId,
          }),
        );

        print('Estado HTTP: ${response.statusCode}');
        print('Cuerpo de respuesta: ${response}');

        if (response.body.isEmpty) {
          return {'error': 'Respuesta vacía', 'message': 'El servidor no devolvió datos.'};
        }

        final responseBody = jsonDecode(response.body);

        if (response.statusCode == 201 || response.statusCode == 200) {
          return responseBody;
        } else {
          return {
            'error': 'Error: ${response.statusCode}',
            'message': responseBody['message'] ?? 'Error inesperado',
          };
        }
      } catch (e) {
        return {'error': 'Exception', 'message': e.toString()};
      }
    }
    }
