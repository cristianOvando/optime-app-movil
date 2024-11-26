import 'package:flutter/material.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../utils/helpers.dart';

class ValidateCodeScreen extends StatefulWidget {
  const ValidateCodeScreen({super.key});

  @override
  State<ValidateCodeScreen> createState() => _ValidateCodeScreenState();
}

class _ValidateCodeScreenState extends State<ValidateCodeScreen> {
  final codeController = TextEditingController();
  bool isLoading = false;

  void validateCode() async {
    setState(() => isLoading = true);

    // Simula una validación exitosa del código
    await Future.delayed(const Duration(seconds: 1));
    setState(() => isLoading = false);

    if (codeController.text == '123456') {
      _showSuccessDialog('Código válido', 'El código fue verificado correctamente.', '/register-user');
    } else {
      Helpers.showErrorDialog(context, 'Código inválido. Inténtalo de nuevo.');
    }
  }

  void _showSuccessDialog(String title, String content, String nextRoute) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.blue, size: 30),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: Colors.blue)),
            ],
          ),
          content: Text(content),
          actions: [
            MyButton(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, nextRoute);
              },
              buttonText: 'Aceptar',
              width: double.infinity,
              borderRadius: 8.0,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text(
                'Validar Código',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              MyTextField(
                controller: codeController,
                hintText: 'Ingresa el código enviado a tu correo',
                obscureText: false,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : MyButton(
                      onTap: validateCode,
                      buttonText: 'Validar Código',
                      width: double.infinity,
                      height: 50.0,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
