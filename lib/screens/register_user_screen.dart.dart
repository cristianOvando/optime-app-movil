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

  @override
  void initState() {
    super.initState();
    _loadContactId();
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

    if (passwordController.text.length < 6) {
      Helpers.showErrorDialog(
        context,
        'La contraseña debe tener al menos 6 caracteres.',
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
          'Registro exitoso',
          'El usuario fue registrado exitosamente.',
          '/Login',
        );
      }

    setState(() => isLoading = false);

    print('Resultado recibido en RegisterUserScreen: $result');

    if (result == null) {
      Helpers.showErrorDialog(
        context,
        'Error al conectar con el servidor. Inténtalo más tarde.',
      );
    } else if (result.containsKey('error')) {
      Helpers.showErrorDialog(
        context,
        result['message'] ?? 'Error desconocido: ${result['error']}',
      );
    } else {

      Helpers.showSuccessDialog(
        context,
        'Registro exitoso',
        'El usuario fue registrado exitosamente.',
        '/Login',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Registro de Usuario',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 22, 123, 206),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              MyTextField(
                controller: usernameController,
                hintText: 'Nombre de usuario',
                obscureText: false,
              ),
              const SizedBox(height: 20),
              MyTextField(
                controller: passwordController,
                hintText: 'Contraseña',
                obscureText: true,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : MyButton(
                      onTap: registerUser,
                      buttonText: 'Registrar',
                      width: double.infinity,
                      height: 50.0,
                      borderRadius: 12.0,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
