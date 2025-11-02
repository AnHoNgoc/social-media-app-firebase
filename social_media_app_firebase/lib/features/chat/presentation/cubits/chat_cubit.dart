import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/message.dart';
import '../../domain/repository/chat_repo.dart';
import 'chat_states.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo chatRepo;

  ChatCubit({required this.chatRepo}) : super(ChatInitial());

  void loadUsers() {
    emit(ChatLoading());
    try {
      chatRepo.getUsersStream().listen((users) {
        emit(ChatUsersLoaded(users));
      });
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void loadMessages(String userId, String otherUserId) async {

    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    try {
      final chatRoomDoc = await chatRepo.getChatRoom(chatRoomId);

      if (!chatRoomDoc.exists) {
        // Room chưa có thì báo empty, không listen messages
        emit(ChatEmpty());
        return;
      }

      // Room có thì mới listen messages
      chatRepo.getMessages(userId, otherUserId).listen(
            (snapshot) {
          final messages = snapshot.docs
              .map((doc) => Message.fromMap(doc.data() as Map<String, dynamic>))
              .toList();
          if (messages.isEmpty) {
            emit(ChatEmpty());
          } else {
            emit(ChatMessagesLoaded(messages));
          }
        },
        onError: (error) => emit(ChatError(error.toString())),
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> sendMessage(String receiverId, String message) async {
    try {
      await chatRepo.sendMessage(receiverId, message);
      // KHÔNG emit gì ở đây, để stream tự update
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void loadChatRooms() {
    emit(ChatLoading());
    try {
      chatRepo.getChatRooms().listen((snapshot) {
        final chatRooms = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return ChatRoom(
            chatRoomId: doc.id,
            users: List<String>.from(data['users']),
            lastMessage: data['lastMessage'] ?? '',
            lastSenderId: data['lastSenderId'] ?? '',
            lastTimestamp: data['lastTimestamp'] ?? Timestamp.now(),
          );
        }).toList();

        emit(ChatRoomsLoaded(chatRooms));
      });
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}