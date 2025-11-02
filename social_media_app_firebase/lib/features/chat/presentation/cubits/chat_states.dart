import '../../domain/entities/chat_room.dart';
import '../../domain/entities/message.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatUsersLoaded extends ChatState {
  final List<Map<String, dynamic>> users;
  ChatUsersLoaded(this.users);
}

class ChatMessagesLoaded extends ChatState {
  final List<Message> messages;
  ChatMessagesLoaded(this.messages);
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}

class ChatRoomsLoaded extends ChatState {
  final List<ChatRoom> chatRooms;
  ChatRoomsLoaded(this.chatRooms);
}

class ChatEmpty extends ChatState {}