import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app_firebase/features/chat/domain/repository/chat_repo.dart';
import '../domain/entities/message.dart';


class FirebaseChatRepo implements ChatRepo {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _fireStore.collection("users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        user['uid'] = doc.id;
        return user;
      }).toList();
    });
  }

  @override
  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    final newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    // Tạo chatRoomId theo 2 uid (sắp xếp để luôn cùng 1 ID)
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    final chatRoomRef = _fireStore.collection("chat_rooms").doc(chatRoomId);

    // 1. Set metadata trước (merge = true nếu đã tồn tại)
    await chatRoomRef.set({
      "users": ids,                 // danh sách thành viên
      "lastMessage": message,       // tin nhắn cuối
      "lastSenderId": currentUserId,
      "lastTimestamp": timestamp,
    }, SetOptions(merge: true));

    // 2. Thêm message vào subcollection
    await chatRoomRef.collection("message").add(newMessage.toMap());
  }

  @override
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _fireStore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("message")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  @override
  Stream<QuerySnapshot> getChatRooms() {
    final String currentUserId = _auth.currentUser!.uid;

    return _fireStore
        .collection("chat_rooms")
        .where("users", arrayContains: currentUserId) // chỉ lấy chat có mình
        .orderBy("lastTimestamp", descending: true) // sắp xếp theo mới nhất
        .snapshots();
  }

  Future<DocumentSnapshot> getChatRoom(String chatRoomId) {
    return _fireStore.collection("chat_rooms").doc(chatRoomId).get();
  }
}