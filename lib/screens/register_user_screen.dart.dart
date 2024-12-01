import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../utils/helpers.dart';
import '../components/my_textfield.dart';
import '../components/my_button.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? contactId;

  // Requisitos de contraseña
  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasNumber = false;

  @override
  void initState() {
    super.initState();
    _loadContactId();
    passwordController.addListener(validatePasswordRequirements);
  }

  Future<void> _loadContactId() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedContactId = prefs.getString('contact_id');
    if (loadedContactId == null || loadedContactId.isEmpty) {
      Helpers.showErrorDialog(
        context,
        'No se encontró el Contact ID. Vuelve a intentar el proceso desde el inicio.',
      );
    }
    setState(() {
      contactId = loadedContactId;
    });
  }

  void validatePasswordRequirements() {
    final password = passwordController.text;
    setState(() {
      hasMinLength = password.length >= 8;
      hasUppercase = password.contains(RegExp(r'[A-Z]'));
      hasNumber = password.contains(RegExp(r'[0-9]'));
    });
  }

  void registerUser() async {
    if (contactId == null) {
      Helpers.showErrorDialog(
        context,
        'Error: No se encontró el Contact ID. Vuelve a intentar el proceso desde el inicio.',
      );
      return;
    }

    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      Helpers.showErrorDialog(
        context,
        'Todos los campos son obligatorios.',
      );
      return;
    }

    if (!hasMinLength || !hasUppercase || !hasNumber) {
      Helpers.showErrorDialog(
        context,
        'Asegúrate de que la contraseña cumpla con todos los requisitos:\n'
        '- Mínimo 8 caracteres.\n'
        '- Al menos 1 mayúscula.\n'
        '- Al menos 1 número.',
      );
      return;
    }

    setState(() => isLoading = true);

    final result = await AuthService.register(
      usernameController.text.trim(),
      passwordController.text.trim(),
      contactId!,
    );

    if (result == null || result.isEmpty || result.containsKey('error')) {
      Helpers.showErrorDialog(
        context,
        result?['message'] ?? 'El servidor no devolvió datos. Por favor, inténtalo más tarde.',
      );
    } else {
      Helpers.showSuccessDialog(
        context,
        'Registro Exitoso',
        'Tu cuenta ha sido creada correctamente.',
      );
      Navigator.of(context).pop();
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Registro de Usuario',
          style: TextStyle(
            color: Color(0xFF167BCE),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Crea tu cuenta',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF167BCE),
              ),
            ),
            const SizedBox(height: 10),
            MyTextField(
              controller: usernameController,
              hintText: 'Username',
              obscureText: false,
              prefixIcon: const Icon(Icons.person),
              width: 400,
              height: 60,
              borderRadius: 15.0,
            ),
            const SizedBox(height: 20),
            MyTextField(
              controller: passwordController,
              hintText: 'Contraseña',
              obscureText: true,
              toggleVisibility: true,
              prefixIcon: const Icon(Icons.lock),
              width: 400,
              height: 60,
              borderRadius: 15.0,
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
              onTap: isLoading ? null : registerUser,
              buttonText: 'Registrar',
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
