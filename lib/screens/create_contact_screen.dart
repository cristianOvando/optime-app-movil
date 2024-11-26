import 'package:flutter/material.dart';
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

    if (!RegExp(r'^[\w\.\-]+@[a-zA-Z0-9\-]+\.upchiapas\.edu\.mx$')
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

    if (result != null && result.containsKey('message')) {
      Helpers.showSuccessDialog(
        context,
        'Contacto creado',
        'Se envió un código a tu correo electrónico.',
        '/validate-code',
      );
    } else {
      Helpers.showErrorDialog(
        context,
        result != null && result.containsKey('message')
            ? result['message']
            : 'Error desconocido: ${result?['error'] ?? 'Sin detalles del error'}',
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
