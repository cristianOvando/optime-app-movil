import 'dart:convert';
import 'package:dart_amqp/dart_amqp.dart';

class RabbitMQConsumer {
  late Client client;
  late Channel channel;
  late Queue queue;

  final Function(dynamic) onMessageReceived;

  RabbitMQConsumer(this.onMessageReceived) {
    final settings = ConnectionSettings(
      host: '52.72.86.85',
      port: 5672,
      authProvider: PlainAuthenticator('optimeroot', 'optimeroot'),
    );

    client = Client(settings: settings);

    _initializeConsumer();
  }

  Future<void> _initializeConsumer() async {
    try {
      print('Intentando conectar a RabbitMQ...');
      channel = await client.channel();
      print('Conexión establecida con RabbitMQ');

      // Verificar si la cola existe y si es accesible
      queue = await channel.queue('messages_queue', durable: true);
      print('Cola "messages_queue" creada o ya existe');

      final consumer = await queue.consume();
      print('Consumiendo mensajes de la cola...');
      
      consumer.listen((AmqpMessage message) {
        try {
          final payload = message.payloadAsString;
          print('Mensaje recibido desde RabbitMQ (crudo): $payload');

          if (payload == "global.announcement") {
            print('Mensaje de anuncio global recibido');
            onMessageReceived({
              'subject': 'Anuncio Global',
              'username': 'Sistema',
              'message': '¡Nuevo anuncio global!',
              'contact': '',
            });
          } else if (_isJson(payload)) {
            final decodedMessage = jsonDecode(payload);
            print('Mensaje decodificado como JSON: $decodedMessage');
            onMessageReceived(decodedMessage); 
          }

          message.ack();  // Acknowledge the message after processing
        } catch (e) {
          print('Error procesando mensaje: $e');
        }
      });

      print('Conectado a RabbitMQ y escuchando mensajes...');
    } catch (e) {
      print('Error al inicializar RabbitMQ: $e');
      await Future.delayed(const Duration(seconds: 5));
      _initializeConsumer();  // Intentar reconectar en caso de fallo
    }
  }

  void stop() {
    client.close();
    print('Desconexión de RabbitMQ');
  }

  bool _isJson(String str) {
    try {
      jsonDecode(str);
      return true;
    } catch (e) {
      return false;
    }
  }
}
