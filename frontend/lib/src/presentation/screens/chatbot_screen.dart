import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_export.dart';
import '../../core/models/chat_models.dart';
import '../../core/services/chat_service.dart';
import '../../injection.dart';
import '../widgets/chatbot/chat_message_widget.dart';
import '../widgets/chatbot/chat_input_widget.dart';
import '../widgets/chatbot/quick_replies_widget.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  late ChatService _chatService;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chatService = ServiceLocator().chatService;
    _chatService.initializeSocket();
    _chatService.addMessageListener(_onNewMessage);
    _sendInitialMessage();
  }

  @override
  void dispose() {
    _chatService.removeMessageListener(_onNewMessage);
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onNewMessage(ChatMessage message) {
    if (mounted) {
      setState(() {});
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendInitialMessage() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      // Send empty message to trigger welcome response
      if (mounted) {
        _chatService.sendMessage("");
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    // Allow empty message for initial welcome
    // if (message.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    _messageController.clear();

    try {
      await _chatService.sendMessage(message);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text(
          'GovConnect Assistant',
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.onPrimary),
            onPressed: () {
              _chatService.startNewSession();
              _sendInitialMessage();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                ),
                child: _chatService.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Start a conversation',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ask me about government services',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _chatService.messages.length,
                        itemBuilder: (context, index) {
                          final message = _chatService.messages[index];
                          final isLastBotMessage = message.sender == 'bot' && 
                              index == _chatService.messages.length - 1;
                          
                          return Column(
                            children: [
                              ChatMessageWidget(
                                message: message,
                                isUser: message.sender == 'user',
                              ),
                              if (isLastBotMessage && message.quickReplies != null)
                                QuickRepliesWidget(
                                  quickReplies: message.quickReplies!,
                                  onReplyTap: (value) {
                                    _messageController.text = value;
                                    _sendMessage();
                                  },
                                ),
                            ],
                          );
                        },
                      ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, -2),
                    blurRadius: 6,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: ChatInputWidget(
                controller: _messageController,
                onSend: _sendMessage,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}