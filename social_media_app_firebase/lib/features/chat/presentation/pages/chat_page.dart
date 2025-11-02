import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/components/chat_bubble.dart';
import '../../../../core/components/my_text_field.dart';
import '../cubits/chat_cubit.dart';
import '../cubits/chat_states.dart';

class ChatPage extends StatefulWidget {
  final String receiverName;
  final String receiverId;

  const ChatPage({
    Key? key,
    required this.receiverName,
    required this.receiverId,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final String senderId;

  // trạng thái scroll
  bool _isUserNearBottom = true;
  bool _hasInitialLoad = false; // để phân biệt lần load đầu tiên

  @override
  void initState() {
    super.initState();
    senderId = FirebaseAuth.instance.currentUser!.uid;

    // listen thay đổi vị trí scroll để biết user có đang ở đáy hay không
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final current = _scrollController.position.pixels;
      const threshold = 100.0; // cận đáy trong 100px
      _isUserNearBottom = (maxScroll - current) <= threshold;
    });

    // Load messages (Cubit sẽ subscribe stream)
    context.read<ChatCubit>().loadMessages(senderId, widget.receiverId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    context.read<ChatCubit>().sendMessage(widget.receiverId, messageText);
    _messageController.clear();

    // Không scroll ở đây: scroll sẽ được quyết định trong builder khi message mới đến
  }

  Future<void> _animateToBottomIfNeeded({required double maxScroll}) async {
    if (!_scrollController.hasClients) return;
    // Nếu đã gần đáy thì animate, hoặc luôn animate khi chính bạn gửi (handled in caller)
    // animate xuống đáy
    await _scrollController.animateTo(
      maxScroll,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          // bạn có thể bỏ state loading cho chat realtime nếu muốn
          return const Center(child: CircularProgressIndicator());
        } else if (state is ChatEmpty) {
          return const Center(child: Text("No messages yet"));
        } else if (state is ChatMessagesLoaded) {
          final messages = state.messages; // assumed sorted ascending (oldest -> newest)

          // Sau khi widget build xong, xử lý auto-scroll theo quy tắc:
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_scrollController.hasClients) return;

            final maxScroll = _scrollController.position.maxScrollExtent;

            // 1) Lần load đầu tiên:
            if (!_hasInitialLoad) {
              _hasInitialLoad = true;
              // Nếu nội dung vượt quá trang (maxScroll > 0) -> auto scroll xuống đáy
              if (maxScroll > 0) {
                _animateToBottomIfNeeded(maxScroll: maxScroll);
              }
              // nếu maxScroll == 0 (vừa màn hình) -> không cuộn (giữ top)
              return;
            }

            // 2) Những lần sau (có message mới):
            // Nếu nội dung vượt quá trang và user đang ở gần đáy -> auto-scroll
            if (maxScroll > 0 && _isUserNearBottom) {
              _animateToBottomIfNeeded(maxScroll: maxScroll);
            } else {
              // nếu user không ở đáy và bạn muốn khi chính bạn gửi thì vẫn scroll:
              final last = messages.isNotEmpty ? messages.last : null;
              if (last != null && last.senderId == senderId) {
                // nếu message cuối là do chính user gửi -> scroll để user thấy
                _animateToBottomIfNeeded(maxScroll: maxScroll);
              }
            }
          });

          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index]; // oldest -> newest
              final isCurrentUser = message.senderId == senderId;

              return Container(
                alignment: isCurrentUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                margin: EdgeInsets.symmetric(vertical: 5.h),
                child: ChatBubble(
                  message: message.message,
                  isCurrentUser: isCurrentUser,
                ),
              );
            },
          );
        } else if (state is ChatError) {
          return Center(child: Text(state.message));
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h, left: 12.w, right: 12.w),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: "Type a message",
              obscureText: false,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}