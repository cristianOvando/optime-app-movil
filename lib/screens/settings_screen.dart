import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../services/auth_service.dart';
import '../components/my_textfield.dart';
import '../components/my_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final usernameController = TextEditingController();
  final newPasswordController = TextEditingController();

  bool isLoading = false;
  bool showCurrentPassword = false;
  int? userId;
  Map<String, dynamic>? userInfo;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');
    if (id != null) {
      setState(() {
        userId = id;
      });
      fetchUserInfo();
    } else {
      Helpers.showErrorDialog(context, 'No se pudo obtener el ID del usuario.');
    }
  }

  Future<void> fetchUserInfo() async {
    if (userId == null) {
      Helpers.showErrorDialog(context, 'ID de usuario no disponible.');
      return;
    }

    setState(() => isLoading = true);
    try {
      final headers = await AuthService().getAuthHeader();
      final url = Uri.parse('${Constants.baseUrl}/users/$userId');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userInfo = data;
          usernameController.text = data['username'];
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
    final newPassword = newPasswordController.text;

    if (!validatePassword(newPassword)) {
      Helpers.showErrorDialog(context,
          'La nueva contraseña debe tener al menos 8 caracteres, incluir letras y números.');
      return;
    }

    setState(() => isLoading = true);
    try {
      final headers = await AuthService().getAuthHeader();
      final url = Uri.parse('${Constants.baseUrl}/users/$userId');
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode({'password': newPassword}),
      );

      if (response.statusCode == 200) {
        Helpers.showSuccessDialog(
          context,
          'Contraseña Actualizada',
          'Tu contraseña ha sido actualizada correctamente.',
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

  Future<void> updateUsername() async {
    final newUsername = usernameController.text.trim();

    if (newUsername.isEmpty) {
      Helpers.showErrorDialog(context, 'El nombre de usuario no puede estar vacío.');
      return;
    }

    setState(() => isLoading = true);
    try {
      final headers = await AuthService().getAuthHeader();
      final url = Uri.parse('${Constants.baseUrl}/users/$userId');
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode({'username': newUsername}),
      );

      if (response.statusCode == 200) {
        Helpers.showSuccessDialog(
          context,
          'Usuario Actualizado',
          'Tu nombre de usuario ha sido actualizado correctamente.',
        );
      } else {
        Helpers.showErrorDialog(context, 'Error al actualizar el usuario.');
      }
    } catch (e) {
      Helpers.showErrorDialog(context, 'Error de conexión: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool validatePassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF167BCE),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: const Text(
          'Perfil de Usuario',
          style: TextStyle(
            color: Color(0xFF167BCE),
            fontWeight: FontWeight.bold,
          ),
        ),
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
                          color: Color(0xFF167BCE),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('Nombre de Usuario: ${userInfo!['username']}'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text('Contraseña: ********'),
                          IconButton(
                            icon: Icon(
                              showCurrentPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                showCurrentPassword = !showCurrentPassword;
                              });
                            },
                          ),
                        ],
                      ),
                      const Divider(height: 40, color: Colors.grey),
                      const Text(
                        'Editar Información',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF167BCE),
                        ),
                      ),
                      const SizedBox(height: 10),
                      MyTextField(
                        controller: usernameController,
                        hintText: 'Nuevo Nombre de Usuario',
                        obscureText: false,
                        borderRadius: 15.0,
                        textStyle: const TextStyle(color: Colors.black, fontSize: 16),
                        fillColor: const Color(0xFFF7F8FA),
                        enabledBorderSide: const BorderSide(color: Colors.grey),
                        focusedBorderSide: const BorderSide(color: Color(0xFF167BCE), width: 1.5),
                      ),
                      const SizedBox(height: 20),
                      MyButton(
                        onTap: isLoading ? null : updateUsername,
                        buttonText: 'Actualizar Usuario',
                        width: double.infinity,
                        height: 50,
                        borderRadius: 15.0,
                        color: const Color(0xFF167BCE),
                        textColor: Colors.white,
                      ),
                       const SizedBox(height: 10),
                      MyTextField(
                        controller: newPasswordController,
                        hintText: 'Nueva Contraseña',
                        obscureText: true,
                        borderRadius: 15.0,
                        textStyle: const TextStyle(color: Colors.black, fontSize: 16),
                        fillColor: const Color(0xFFF7F8FA),
                        enabledBorderSide: const BorderSide(color: Colors.grey),
                        focusedBorderSide: const BorderSide(color: Color(0xFF167BCE), width: 1.5),
                      ),
                      const SizedBox(height: 20),
                      MyButton(
                        onTap: isLoading ? null : updatePassword,
                        buttonText: 'Actualizar Contraseña',
                        width: double.infinity,
                        height: 50,
                        borderRadius: 15.0,
                        color: const Color(0xFF167BCE),
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),
    );
  }
}
