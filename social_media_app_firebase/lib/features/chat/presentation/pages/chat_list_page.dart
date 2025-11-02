import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../main.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../cubits/chat_cubit.dart';
import '../cubits/chat_states.dart';
import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> with RouteAware {
  late AuthCubit authCubit;
  late ChatCubit chatCubit;

  final Map<String, DocumentSnapshot> userCache = {};

  @override
  void initState() {
    super.initState();
    authCubit = context.read<AuthCubit>();
    chatCubit = context.read<ChatCubit>();
    chatCubit.loadChatRooms(); // load chat rooms 1 lần
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    chatCubit.loadChatRooms(); // refresh khi quay lại
  }

  Future<DocumentSnapshot> getUserData(String userId) async {
    if (userCache.containsKey(userId)) {
      return userCache[userId]!;
    }
    final doc = await FirebaseFirestore.instance.collection("users").doc(userId).get();
    userCache[userId] = doc;
    return doc;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = authCubit.currentUser;
    if (currentUser == null) {
      return Scaffold(
        body: Center(child: Text("User not logged in", style: TextStyle(fontSize: 16.sp))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Chats", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ChatRoomsLoaded) {
            final chatRooms = state.chatRooms;
            if (chatRooms.isEmpty) {
              return Center(child: Text("No chats yet", style: TextStyle(fontSize: 16.sp)));
            }

            return ListView.separated(
              padding: EdgeInsets.all(12.w),
              itemCount: chatRooms.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final chatRoom = chatRooms[index];
                final users = chatRoom.users;
                final lastMessage = chatRoom.lastMessage ?? "";
                final otherUserId = users.firstWhere((uid) => uid != currentUser.uid);

                return FutureBuilder<DocumentSnapshot>(
                  future: getUserData(otherUserId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return ListTile(title: Text("Loading...", style: TextStyle(fontSize: 14.sp)));
                    }

                    final otherUserData = snapshot.data!;
                    final username = otherUserData['name'] ?? "Unknown";

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        title: Text(username, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                        subtitle: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatPage(
                                receiverId: otherUserId,
                                receiverName: username,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          } else if (state is ChatError) {
            return Center(
              child: Text(state.message, style: TextStyle(fontSize: 16.sp)),
            );
          }

          return SizedBox.shrink();
        },
      ),
    );
  }
}