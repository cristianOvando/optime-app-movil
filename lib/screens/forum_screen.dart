import 'package:flutter/material.dart';
import 'package:dart_amqp/dart_amqp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({Key? key}) : super(key: key);

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  List<Map<String, dynamic>> messages = []; 
  TextEditingController _subjectController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  late Client client;
  bool isLoading = false;
  String? username;
  String? email;
  List<String> _rabbitMessages = [];

  @override
  void initState() {
    super.initState();
    _loadUserData(); 
    _connectToRabbitMQ(); 
    _loadMessages(); 
  }

  @override
  void dispose() {
    client.close(); 
    super.dispose();
  }

  void _connectToRabbitMQ() {
  final connectionSettings = ConnectionSettings(
    host: '52.72.86.85',
    authProvider: PlainAuthenticator('optimeroot', 'optimeroot'),
  );

  client = Client(settings: connectionSettings);

  client.channel().then((Channel channel) async {
    final exchange = await channel.exchange('messages_exchange', ExchangeType.FANOUT, durable: true);
    final queue = await channel.queue('', exclusive: true);
    await queue.bind(exchange, '');

    Consumer consumer = await queue.consume();
    consumer.listen((AmqpMessage message) async {
      setState(() {
        _rabbitMessages.add(String.fromCharCodes(message.payload ?? []));
      });

      await _loadMessages();
    });
  }).catchError((error) {
    debugPrint('Error al conectar a RabbitMQ: $error');
  });
}

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0;
    final userData = await AuthService.getUserInfo(userId);

    if (userData != null && !userData.containsKey('error')) {
      setState(() {
        username = userData['username'];
        email = userData['contact'] != null ? userData['contact']['email'] : null;
      });
    } else {
      print('Error al cargar los datos del usuario: ${userData?['message'] ?? 'Desconocido'}');
    }
  }

  Future<void> _loadMessages() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedMessages = await AuthService.getMessages(); 
      setState(() {
        messages = fetchedMessages ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar los mensajes: $e')));
    }
  }

  void _showMessageForm() async {
    if (username == null || email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos del usuario no disponibles.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nuevo mensaje'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _subjectController,
                decoration: InputDecoration(labelText: 'Asunto'),
              ),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Contenido'),
              ),
              Text('De: $username'),
              Text('Email: $email'),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                postMessage(_subjectController.text, _contentController.text, email ?? '');
                Navigator.of(context).pop();
              },
              child: Text('Enviar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> postMessage(String subject, String content, String contact) async {
    if (username == null || email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener el nombre de usuario o correo.')),
      );
      return;
    }

    final result = await AuthService.postMessage(subject, username!, content, contact);

    if (result == null || result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result?['message'] ?? 'Error desconocido.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mensaje publicado con éxito.')),
      );
      _loadMessages(); 
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? const Center(
                  child: Text(
                    'Aún no hay mensajes. Sé el primero en publicar uno.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(message['subject'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('De: ${message['username']}'),
                            const SizedBox(height: 4),
                            Text(message['message'] ?? ''),
                            const SizedBox(height: 4),
                            if (message['contact'] != null && message['contact'] is Map) ...[
                              Text('Email: ${(message['contact'] as Map)['email']}'),
                            ] else if (message['contact'] is String) ...[
                              Text('Email: ${message['contact']}'),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _showMessageForm,
            child: const Text('Publicar Mensaje'),
          ),
        ),
      ],
    ),
  );
}
}
