import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/helpers.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? userInfo;
  final newPasswordController = TextEditingController();
  bool isLoading = false;

  // Simulación del ID del usuario actual
  final int userId = 1;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    setState(() => isLoading = true);
    try {
      final url = Uri.parse('${Constants.baseUrl}/users/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          userInfo = jsonDecode(response.body);
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        Helpers.showErrorDialog(context, 'Usuario no encontrado.');
      } else {
        Helpers.showErrorDialog(context, 'Error al obtener datos del usuario.');
      }
    } catch (e) {
      Helpers.showErrorDialog(context, 'Error de conexión: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updatePassword() async {
    if (newPasswordController.text.isEmpty) {
      Helpers.showErrorDialog(context, 'La contraseña no puede estar vacía.');
      return;
    }

    setState(() => isLoading = true);
    try {
      final url = Uri.parse('${Constants.baseUrl}/users/$userId');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'password': newPasswordController.text}),
      );

      if (response.statusCode == 200) {
        Helpers.showSuccessDialog(
          context,
          'Contraseña Actualizada',
          'Tu contraseña ha sido actualizada correctamente.',
          null,
        );
      } else if (response.statusCode == 404) {
        Helpers.showErrorDialog(context, 'Usuario no encontrado.');
      } else {
        Helpers.showErrorDialog(
          context,
          'Error al actualizar contraseña: ${response.body}',
        );
      }
    } catch (e) {
      Helpers.showErrorDialog(context, 'Error de conexión: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: const Color.fromARGB(255, 22, 123, 206),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userInfo == null
              ? const Center(child: Text('Cargando información...'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información del Usuario',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('ID: ${userInfo!['id']}'),
                      Text('Nombre de Usuario: ${userInfo!['username']}'),
                      Text('Correo Electrónico: ${userInfo!['email']}'),
                      Text('Estado: ${userInfo!['status']}'),
                      const Divider(height: 40),
                      const Text(
                        'Cambiar Contraseña',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: newPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Nueva Contraseña',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: updatePassword,
                        child: const Text('Actualizar Contraseña'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
