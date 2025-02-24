import 'dart:developer' as developer;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  WebSocketChannel? _channel;
  Stream? _broadcastStream;
  bool _isConnected = false;

  // Singleton instance
  static final WebSocketService _instance = WebSocketService._internal();

  factory WebSocketService() {
    return _instance;
  }

  WebSocketService._internal();

  // The _isConnected flag  prevents multiple connection attempts and ensures that I  only connect to the WebSocket once.
  void connect(String url) {
    if (_isConnected) {
      developer.log("WebSocket already connected", name: "WebSocketService");
      return;
    }

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _broadcastStream = _channel!.stream.asBroadcastStream();

      _broadcastStream!.listen(
        (message) {
          developer.log('Received: $message', name: 'WebSocketService');
        },
        onError: (error, StackTrace stackTrace) {
          developer.log('WebSocket Error: $error',
              name: 'WebSocketService',
              level: 1,
              error: error,
              stackTrace: stackTrace);
          _isConnected = false; // Reset connection status on error
        },
        onDone: () {
          developer.log('WebSocket Disconnected', name: 'WebSocketService');
          _isConnected = false; // Reset connection status on disconnect
        },
      );
      _isConnected = true; // Set connection status to true
    } catch (e, stackTrace) {
      developer.log('WebSocket Connect Error: $e',
          name: 'WebSocketService', error: e, stackTrace: stackTrace);
      _isConnected = false; // Reset connection status on error
    }
  }

  void listen(void Function(dynamic message) onMessage) {
    if (_broadcastStream != null) {
      _broadcastStream!.listen(onMessage);
    } else {
      developer.log("Broadcast stream is null, cannot listen",
          name: "WebSocketService");
    }
  }

  void sendMessage(String message) {
    if (_channel != null) {
      _channel!.sink.add(message);
    } else {
      developer.log("Channel is null, cannot send message",
          name: "WebSocketService");
    }
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
      _isConnected = false; // Reset connection status on disconnect
    } else {
      developer.log("Channel is null, cannot disconnect",
          name: "WebSocketService");
    }
  }
}
