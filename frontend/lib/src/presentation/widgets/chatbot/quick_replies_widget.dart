import 'package:flutter/material.dart';
import '../../../core/models/chat_models.dart';

class QuickRepliesWidget extends StatelessWidget {
  final List<QuickReply> quickReplies;
  final Function(String) onReplyTap;

  const QuickRepliesWidget({
    Key? key,
    required this.quickReplies,
    required this.onReplyTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: quickReplies.map((reply) {
          return GestureDetector(
            onTap: () => onReplyTap(reply.value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: reply.type == 'language' 
                    ? Theme.of(context).primaryColor 
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: reply.type == 'language'
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                reply.text,
                style: TextStyle(
                  color: reply.type == 'language'
                      ? Colors.white
                      : Theme.of(context).primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}