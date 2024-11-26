import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/contact_service.dart';
import '../utils/helpers.dart';
import '../components/my_textfield.dart';
import '../components/my_button.dart';

class CreateContactScreen extends StatefulWidget {
  const CreateContactScreen({super.key});

  @override
  State<CreateContactScreen> createState() => _CreateContactScreenState();
}

class _CreateContactScreenState extends State<CreateContactScreen> {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  bool isLoading = false;

  void createContact() async {
    if (emailController.text.isEmpty ||
        nameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        phoneController.text.isEmpty) {
      Helpers.showErrorDialog(
        context,
        'Todos los campos son obligatorios.',
      );
      return;
    }

    if (!RegExp(r'^[\w\.\-]+@([\w\-]+\.)?upchiapas\.edu\.mx$')
        .hasMatch(emailController.text.trim())) {
      Helpers.showErrorDialog(
        context,
        'El correo debe ser válido y terminar con @upchiapas.edu.mx.',
      );
      return;
    }

    setState(() => isLoading = true);

    final result = await ContactService.createContact(
      emailController.text.trim(),
      nameController.text.trim(),
      lastNameController.text.trim(),
      phoneController.text.trim(),
    );

    setState(() => isLoading = false);

    if (result != null) {
      print('Resultado completo: $result');

      if (result.containsKey('error')) {
        Helpers.showErrorDialog(
          context,
          result['message'] ?? 'Error desconocido',
        );
      } else if (result.containsKey('contact_id')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('contact_id', result['contact_id'].toString());

        Helpers.showSuccessDialog(
          context,
          'Contacto creado',
          result['message'] ?? 'El contacto fue creado exitosamente.',
          '/Validate-code',
        );
      } else {
        Helpers.showErrorDialog(
          context,
          'Respuesta inesperada del servidor.',
        );
      }
    } else {
      Helpers.showErrorDialog(
        context,
        'No se pudo conectar con el servidor. Por favor, inténtalo más tarde.',
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
                'Crear Contacto',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              MyTextField(
                controller: emailController,
                hintText: 'Correo Electrónico',
                obscureText: false,
              ),
              const SizedBox(height: 20),
              MyTextField(
                controller: nameController,
                hintText: 'Nombre',
                obscureText: false,
              ),
              const SizedBox(height: 20),
              MyTextField(
                controller: lastNameController,
                hintText: 'Apellido',
                obscureText: false,
              ),
              const SizedBox(height: 20),
              MyTextField(
                controller: phoneController,
                hintText: 'Teléfono',
                obscureText: false,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : MyButton(
                      onTap: createContact,
                      buttonText: 'Siguiente',
                      width: double.infinity,
                      height: 50,
                      borderRadius: 12.0,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
