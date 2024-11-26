import 'package:flutter/material.dart';
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

  final String contactId = "1"; 
  void registerUser() async {
    
    setState(() => isLoading = true);

    final result = await AuthService.register(
      usernameController.text,
      passwordController.text,
      contactId,
    );

    setState(() => isLoading = false);

    if (result != null && result['success'] == true) {
      Helpers.showSuccessDialog(
        context,
        'Registro exitoso',
        'El usuario fue registrado exitosamente.',
        '/', 
      );
    } else if (result != null && result.containsKey('message')) {

      Helpers.showErrorDialog(
        context,
        result['message'] ?? 'Error desconocido: ${result['error']}',
      );
    } else {
      
      Helpers.showErrorDialog(
        context,
        'Error al registrar al usuario. Por favor, verifica tu conexión o los datos ingresados.',
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
