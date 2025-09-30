class Message {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderType;
  final String content;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderType,
    required this.content,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      chatRoomId: json['chat_room_id'],
      senderId: json['sender_id'],
      senderType: json['sender_type'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_room_id': chatRoomId,
      'sender_id': senderId,
      'sender_type': senderType,
      'content': content,
    };
  }
}
