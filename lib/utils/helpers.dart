import 'package:flutter/material.dart';
import '../components/my_button.dart';

class Helpers {
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error', style: TextStyle(color: Colors.red)),
          content: Text(message),
          actions: [
            MyButton(
              onTap: () => Navigator.pop(context),
              buttonText: 'Aceptar',
              width: double.infinity,
              height: 50,
              borderRadius: 12.0,
            ),
          ],
        );
      },
    );
  }

  static void showSuccessDialog(
      BuildContext context, String title, String message, [String? nextRoute]) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.blue, size: 30),
              const SizedBox(width: 5),
              Text(title, style: const TextStyle(color: Colors.blue)),
            ],
          ),
          content: Text(message),
          actions: [
            MyButton(
              onTap: () {
                Navigator.pop(context);
                if (nextRoute != null) {
                  Navigator.pushNamed(context, nextRoute);
                }
              },
              buttonText: 'Aceptar',
              width: double.infinity,
              height: 50,
              borderRadius: 12.0,
            ),
          ],
        );
      },
    );
  }
}
