import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_media_app_firebase/features/auth/domain/entities/app_user.dart';
import 'package:social_media_app_firebase/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_app_firebase/features/post/domain/entities/comment.dart';
import 'package:social_media_app_firebase/features/post/presentation/cubits/post_cubits.dart';
import '../utils/confirmation_dialog.dart';

class CommentTile extends StatefulWidget {
  final Comment comment;
  final String postOwnerId; // thêm vào

  const CommentTile({
    super.key,
    required this.comment,
    required this.postOwnerId,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  AppUser? currentUser;
  bool canDelete = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;

    final isOwnComment = widget.comment.userId == currentUser!.uid;
    final isPostOwner = widget.postOwnerId == currentUser!.uid;

    canDelete = isOwnComment || isPostOwner;
  }

  void deleteComment() async {
    final confirmed = await showConfirmationDialog(
      context,
      title: "Delete Comment",
      message: "Are you sure you want to delete this comment?",
      confirmText: "Delete",
      cancelText: "Cancel",
    );

    if (confirmed == true && mounted) { // <-- check mounted
      final postCubit = context.read<PostCubit>();
      await postCubit.deleteComment(widget.comment.postId, widget.comment.id);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, top: 20.h),
      child: Row(
        children: [
          Text(
            widget.comment.userName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10.w),
          Text(widget.comment.text),
          const Spacer(),
          if (canDelete)
            GestureDetector(
              onTap: deleteComment,
              child: Icon(
                Icons.more_horiz,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
        ],
      ),
    );
  }
}