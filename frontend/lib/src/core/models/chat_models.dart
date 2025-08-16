class ChatMessage {
  final String id;
  final String sessionId;
  final String message;
  final String sender;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
  final List<QuickReply>? quickReplies;

  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.message,
    required this.sender,
    required this.createdAt,
    this.metadata,
    this.quickReplies,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      sessionId: json['sessionId'],
      message: json['message'],
      sender: json['sender'],
      createdAt: DateTime.parse(json['createdAt']),
      metadata: json['metadata'],
      quickReplies: json['quickReplies'] != null
          ? (json['quickReplies'] as List)
              .map((e) => QuickReply.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'message': message,
      'sender': sender,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
      'quickReplies': quickReplies?.map((e) => e.toJson()).toList(),
    };
  }
}

class QuickReply {
  final String text;
  final String value;
  final String? type;

  QuickReply({
    required this.text,
    required this.value,
    this.type,
  });

  factory QuickReply.fromJson(Map<String, dynamic> json) {
    return QuickReply(
      text: json['text'],
      value: json['value'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'value': value,
      'type': type,
    };
  }
}

class ChatSession {
  final String id;
  final String? userId;
  final String title;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? context;

  ChatSession({
    required this.id,
    this.userId,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.context,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      context: json['context'],
    );
  }
}