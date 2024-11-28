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

  String selectedEditOption = 'Username';

  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasNumber = false;

  @override
  void initState() {
    super.initState();
    loadUserId();
    newPasswordController.addListener(validatePasswordRequirements);
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

  void validatePasswordRequirements() {
    final password = newPasswordController.text;
    setState(() {
      hasMinLength = password.length >= 8;
      hasUppercase = password.contains(RegExp(r'[A-Z]'));
      hasNumber = password.contains(RegExp(r'[0-9]'));
    });
  }

  Future<void> updatePassword() async {
  if (!hasMinLength || !hasUppercase || !hasNumber) {
    Helpers.showErrorDialog(
      context,
      'Asegúrate de que la contraseña cumpla con todos los requisitos.',
    );
    return;
  }

  setState(() => isLoading = true);
  try {
    final headers = await AuthService().getAuthHeader();
    final url = Uri.parse('${Constants.baseUrl}/users/$userId');
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode({'password': newPasswordController.text}),
    );

    if (response.statusCode == 200) {
      Helpers.showSuccessDialog(
        context,
        'Contraseña Actualizada',
        'Tu contraseña ha sido actualizada correctamente.',
      );
      await fetchUserInfo(); 
    } else if (response.statusCode == 404) {
      Helpers.showErrorDialog(context, 'Usuario no encontrado.');
    } else {
      Helpers.showErrorDialog(
        context,
        'Error al actualizar contraseña',
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
      await fetchUserInfo(); 
    } else {
      Helpers.showErrorDialog(context, 'Error al actualizar el usuario.');
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
                          Text(showCurrentPassword
                              ? 'Contraseña: ${userInfo!['password']}'
                              : 'Contraseña: ********'),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4B97D5),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedEditOption,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            isExpanded: true,
                            dropdownColor: const Color(0xFF4B97D5),
                            items: <String>['Username', 'Password'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedEditOption = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (selectedEditOption == 'Username')
                        Column(
                          children: [
                            MyTextField(
                              controller: usernameController,
                              hintText: 'Nuevo Username',
                              obscureText: false,
                              prefixIcon: const Icon(Icons.person),
                              width: 400,
                              height: 60,
                              borderRadius: 15.0,
                              hintTextStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                              textStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                              enabledBorderSide: const BorderSide(
                                color: Color(0xFFB5CEE3),
                                width: 0.5,
                              ),
                              focusedBorderSide: const BorderSide(
                                color: Color(0xFF4B97D5),
                                width: 1.5,
                              ),
                              fillColor: Colors.white,
                            ),
                            const SizedBox(height: 20),
                            MyButton(
                              onTap: isLoading ? null : updateUsername,
                              buttonText: 'Actualizar Username',
                              width: 300,
                              height: 50.0,
                              borderRadius: 20.0,
                              color: const Color(0xFF167BCE),
                              textColor: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      if (selectedEditOption == 'Password')
                        Column(
                          children: [
                            MyTextField(
                              controller: newPasswordController,
                              hintText: 'Nueva Contraseña',
                              obscureText: true,
                              toggleVisibility: true,
                              prefixIcon: const Icon(Icons.lock),
                              width: 400,
                              height: 60,
                              borderRadius: 15.0,
                              hintTextStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                              textStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                              enabledBorderSide: const BorderSide(
                                color: Color(0xFFB5CEE3),
                                width: 0.5,
                              ),
                              focusedBorderSide: const BorderSide(
                                color: Color(0xFF4B97D5),
                                width: 1.5,
                              ),
                              fillColor: Colors.white,
                            ),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildRequirement('Mínimo 8 caracteres', hasMinLength),
                                _buildRequirement('Al menos 1 mayúscula', hasUppercase),
                                _buildRequirement('Al menos 1 número', hasNumber),
                              ],
                            ),
                            const SizedBox(height: 20),
                            MyButton(
                              onTap: isLoading ? null : updatePassword,
                              buttonText: 'Actualizar Contraseña',
                              width: 300,
                              height: 50.0,
                              borderRadius: 20.0,
                              color: const Color(0xFF167BCE),
                              textColor: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isMet ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isMet ? Colors.green : Colors.grey,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
