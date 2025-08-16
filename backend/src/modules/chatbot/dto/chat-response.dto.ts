export class ChatResponseDto {
  id: string;
  sessionId: string;
  message: string;
  sender: 'user' | 'bot';
  createdAt: Date;
  metadata?: Record<string, any>;
  quickReplies?: QuickReply[];
}

export class QuickReply {
  text: string;
  value: string;
  type?: 'language' | 'action' | 'tag';
}