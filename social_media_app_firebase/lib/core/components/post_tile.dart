import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_media_app_firebase/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_app_firebase/features/post/presentation/cubits/post_cubits.dart';
import 'package:social_media_app_firebase/features/profile/domain/entities/profile_user.dart';
import 'package:social_media_app_firebase/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media_app_firebase/features/profile/presentation/page/profile_page.dart';
import '../../features/auth/domain/entities/app_user.dart';
import '../../features/home/presentation/pages/image_preview_page.dart';
import '../../features/post/domain/entities/post.dart';
import 'comment_sheet.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;

  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePressed,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;
  AppUser? currentUser;
  ProfileUser? postUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchPostUser();
  }


  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = widget.post.userId == currentUser!.uid;
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (!mounted) return;
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  void toggleLikePost() {
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid);
      } else {
        widget.post.likes.add(currentUser!.uid);
      }
    });

    postCubit.toggleLikePost(widget.post.id, currentUser!.uid).catchError((_) {
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid);
        } else {
          widget.post.likes.remove(currentUser!.uid);
        }
      });
    });
  }

  String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return '${diff.inSeconds} seconds ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 30) return '${diff.inDays} days ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
    return '${(diff.inDays / 365).floor()} years ago';
  }

  void openCommentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CommentSheet(post: widget.post);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          SizedBox(height: 10.h),

          // user info
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(uid: widget.post.userId),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(8.r),
              child: Row(
                children: [
                  postUser?.profileImageUrl != null
                      ? CachedNetworkImage(
                    imageUrl: postUser!.profileImageUrl,
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.person),
                    imageBuilder: (context, imageProvider) => Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                      : const Icon(Icons.person, size: 40),
                  SizedBox(width: 10.w),
                  Text(
                    widget.post.userName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  const Spacer(),
                  if (isOwnPost)
                    IconButton(
                      onPressed: widget.onDeletePressed,
                      icon: const Icon(Icons.delete),
                    ),
                ],
              ),
            ),
          ),

          // post text
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    widget.post.text,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ],
            ),
          ),

          // post image
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ImagePreviewPage(imageUrl: widget.post.imageUrl),
                ),
              );
            },
            child: CachedNetworkImage(
              imageUrl: widget.post.imageUrl,
              height: 430.h,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => SizedBox(height: 430.h),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),

          // like & comment actions
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                GestureDetector(
                  onTap: toggleLikePost,
                  child: Icon(
                    widget.post.likes.contains(currentUser!.uid)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.post.likes.contains(currentUser!.uid)
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(widget.post.likes.length.toString(),
                    style: TextStyle(fontSize: 12.sp)),
                SizedBox(width: 20.w),
                GestureDetector(
                  onTap: openCommentsSheet,
                  child: Icon(
                    Icons.comment,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(widget.post.comments.length.toString(),
                    style: TextStyle(fontSize: 12.sp)),
                const Spacer(),
                Text(
                  timeAgo(widget.post.timestamp),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}