import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/supabase_config.dart';
import '../models/message.dart';

class ChatNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  ChatNotifier() : super(const AsyncValue.data([]));

  final _client = SupabaseConfig.client;
  String? _currentChatRoomId;

  Future<void> loadMessages(String chatRoomId) async {
    _currentChatRoomId = chatRoomId;

    try {
      final response = await _client
          .from('messages')
          .select()
          .eq('chat_room_id', chatRoomId)
          .order('created_at', ascending: true);

      final messages = (response as List)
          .map((json) => Message.fromJson(json))
          .toList();

      state = AsyncValue.data(messages);

      // Subscribe to real-time updates
      _client
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('chat_room_id', chatRoomId)
          .listen((data) {
            final messages = data
                .map((json) => Message.fromJson(json))
                .toList();
            messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            state = AsyncValue.data(messages);
          });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<String> getOrCreateChatRoom(String userId, String doctorId) async {
    try {
      // Try to find existing chat room
      final existingRoom = await _client
          .from('chat_rooms')
          .select()
          .eq('user_id', userId)
          .eq('doctor_id', doctorId)
          .maybeSingle();

      if (existingRoom != null) {
        return existingRoom['id'];
      }

      // Create new chat room
      final newRoom = await _client
          .from('chat_rooms')
          .insert({'user_id': userId, 'doctor_id': doctorId})
          .select()
          .single();

      return newRoom['id'];
    } catch (e) {
      throw Exception('Failed to create chat room: $e');
    }
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderType,
    required String content,
  }) async {
    try {
      await _client.from('messages').insert({
        'chat_room_id': chatRoomId,
        'sender_id': senderId,
        'sender_type': senderType,
        'content': content,
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
}

final chatProvider =
    StateNotifierProvider<ChatNotifier, AsyncValue<List<Message>>>((ref) {
      return ChatNotifier();
    });
