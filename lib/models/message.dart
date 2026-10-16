class ConversationSummary {
  final String id;
  final String otherUserId;
  final String otherName;
  final String? otherAvatarUrl;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  const ConversationSummary({
    required this.id,
    required this.otherUserId,
    required this.otherName,
    required this.otherAvatarUrl,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  bool get unread => unreadCount > 0;

  factory ConversationSummary.fromMap(Map<String, dynamic> m) =>
      ConversationSummary(
        id: m['id'] as String,
        otherUserId: m['other_user_id'] as String,
        otherName: (m['other_name'] as String?) ?? '',
        otherAvatarUrl: m['other_avatar_url'] as String?,
        lastMessage: (m['last_message'] as String?) ?? '',
        lastMessageAt: DateTime.parse(m['last_message_at'] as String).toLocal(),
        unreadCount: (m['unread_count'] as num?)?.toInt() ?? 0,
      );
}

class ChatMessage {
  final int id;
  final String senderId;
  final String body;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.body,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> m) => ChatMessage(
    id: (m['id'] as num).toInt(),
    senderId: m['sender_id'] as String,
    body: m['body'] as String,
    createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
  );
}
