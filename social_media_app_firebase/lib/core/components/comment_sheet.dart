import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../features/post/domain/entities/comment.dart';
import '../../features/post/domain/entities/post.dart';
import '../../features/post/presentation/cubits/post_cubits.dart';
import '../../features/post/presentation/cubits/post_states.dart';
import 'comment_tile.dart';
import 'my_text_field.dart';

class CommentSheet extends StatefulWidget {
  final Post post;
  const CommentSheet({super.key, required this.post});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void addComment() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final authCubit = context.read<AuthCubit>();
    final currentUser = authCubit.currentUser!;

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      userId: currentUser.uid,
      userName: currentUser.name,
      text: text,
      timestamp: DateTime.now(),
    );

    context.read<PostCubit>().addComment(widget.post.id, newComment);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: 0.8.sh, // 90% màn hình
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              // drag handle
              Container(
                width: 50.w,
                height: 5.h,
                margin: EdgeInsets.only(bottom: 20.h),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  "COMMENT",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // comment list
              Expanded(
                child: BlocBuilder<PostCubit, PostState>(
                  builder: (context, state) {
                    if (state is PostsLoaded) {
                      final post = state.posts.firstWhere(
                            (p) => p.id == widget.post.id,
                      );
                      return ListView.builder(
                        itemCount: post.comments.length,
                        itemBuilder: (context, index) {
                          final comment = post.comments[index];
                          return CommentTile(
                            comment: comment,
                            postOwnerId: post.userId,
                          );
                        },
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ),

              // input field
              Row(
                children: [
                  Expanded(
                    child: MyTextField(
                      controller: _controller,
                      hintText: "Comment...",
                      obscureText: false,
                      validator: null,
                    ),
                  ),
                  IconButton(
                    onPressed: addComment,
                    icon: Icon(Icons.send, size: 24.sp),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}