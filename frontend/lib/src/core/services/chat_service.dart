import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/chat_models.dart';
import 'api_service.dart';
import 'auth_service.dart';

class ChatService {
  final ApiService _apiService;
  final AuthService _authService;
  IO.Socket? _socket;
  String? _currentSessionId;
  final List<ChatMessage> _messages = [];
  final List<void Function(ChatMessage)> _messageListeners = [];

  ChatService(this._apiService, this._authService);

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  String? get currentSessionId => _currentSessionId;

  void initializeSocket() {
    final baseUrl = _apiService.dio.options.baseUrl;
    _socket = IO.io('$baseUrl/chat', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'auth': {
        'userId': _authService.currentUser?.id,
      },
    });

    _socket!.on('connect', (_) {
      print('Connected to chat server');
    });

    _socket!.on('newMessage', (data) {
      final message = ChatMessage.fromJson(data);
      _messages.add(message);
      for (final listener in _messageListeners) {
        listener(message);
      }
    });

    _socket!.on('sessionHistory', (data) {
      _messages.clear();
      for (final messageData in data) {
        _messages.add(ChatMessage.fromJson(messageData));
      }
    });

    _socket!.on('error', (data) {
      print('Socket error: $data');
    });
  }

  void addMessageListener(void Function(ChatMessage) listener) {
    _messageListeners.add(listener);
  }

  void removeMessageListener(void Function(ChatMessage) listener) {
    _messageListeners.remove(listener);
  }

  Future<void> sendMessage(String message) async {
    if (_socket == null || !_socket!.connected) {
      // Use HTTP fallback
      await sendMessageHttp(message);
      return;
    }

    _socket!.emit('sendMessage', {
      'message': message,
      'sessionId': _currentSessionId,
    });
  }

  Future<void> sendMessageHttp(String message) async {
    try {
      final endpoint = _authService.isAuthenticated
          ? '/chatbot/message/authenticated'
          : '/chatbot/message';

      final response = await _apiService.dio.post(
        endpoint,
        data: {
          'message': message,
          'sessionId': _currentSessionId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final messages = response.data as List;
        for (final messageData in messages) {
          final chatMessage = ChatMessage.fromJson(messageData);
          _messages.add(chatMessage);
          if (_currentSessionId == null) {
            _currentSessionId = chatMessage.sessionId;
          }
          for (final listener in _messageListeners) {
            listener(chatMessage);
          }
        }
      }
    } catch (e) {
      print('Error sending message: $e');
      throw e;
    }
  }

  Future<void> loadSessionHistory(String sessionId) async {
    try {
      _currentSessionId = sessionId;
      
      if (_socket != null && _socket!.connected) {
        _socket!.emit('joinSession', sessionId);
      } else {
        final response = await _apiService.dio.get(
          '/chatbot/session/$sessionId/history',
        );

        if (response.statusCode == 200) {
          _messages.clear();
          final messages = response.data as List;
          for (final messageData in messages) {
            _messages.add(ChatMessage.fromJson(messageData));
          }
        }
      }
    } catch (e) {
      print('Error loading session history: $e');
    }
  }

  Future<List<ChatSession>> getUserSessions() async {
    try {
      final response = await _apiService.dio.get('/chatbot/sessions');
      
      if (response.statusCode == 200) {
        final sessions = response.data as List;
        return sessions.map((s) => ChatSession.fromJson(s)).toList();
      }
      return [];
    } catch (e) {
      print('Error loading user sessions: $e');
      return [];
    }
  }

  void startNewSession() {
    _currentSessionId = null;
    _messages.clear();
  }

  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _messageListeners.clear();
  }
}