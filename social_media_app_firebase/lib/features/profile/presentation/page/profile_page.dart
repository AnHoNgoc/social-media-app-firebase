import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_media_app_firebase/core/components/bio_box.dart';
import 'package:social_media_app_firebase/core/components/app_action_button.dart';
import 'package:social_media_app_firebase/core/components/post_tile.dart';
import 'package:social_media_app_firebase/core/components/profile_status.dart';
import 'package:social_media_app_firebase/features/auth/domain/entities/app_user.dart';
import 'package:social_media_app_firebase/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_app_firebase/features/post/presentation/cubits/post_cubits.dart';
import 'package:social_media_app_firebase/features/post/presentation/cubits/post_states.dart';
import 'package:social_media_app_firebase/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media_app_firebase/features/profile/presentation/cubits/profile_states.dart';
import 'package:social_media_app_firebase/features/profile/presentation/page/edit_profile_page.dart';
import 'package:social_media_app_firebase/features/profile/presentation/page/follower_page.dart';

import '../../../../core/utils/confirmation_dialog.dart';
import '../../../chat/presentation/pages/chat_page.dart';


class ProfilePage extends StatefulWidget {

  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  
  late AppUser? currentUser = authCubit.currentUser;

  int postCount = 0;

  @override
  void initState() {
    super.initState();
    profileCubit.fetchUserProfile(widget.uid);
  }

  void followButtonPressed(){
    final profileState = profileCubit.state;
    if(profileState is! ProfileLoaded){
      return;
    }

    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    setState(() {
      if(isFollowing){
        profileUser.followers.remove(currentUser!.uid);
      } else {
        profileUser.followers.add(currentUser!.uid);
      }
    });

    profileCubit.toggleFollow(currentUser!.uid, widget.uid).catchError((error){
      setState(() {
        if(isFollowing){
          profileUser.followers.add(currentUser!.uid);
        } else {
          profileUser.followers.remove(currentUser!.uid);
        }
      });
    });
  }

  Future<void> deletePost(BuildContext context, String postId) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: "Delete Post",
      message: "Are you sure you want to delete this post?",
      confirmText: "Delete",
      cancelText: "Cancel",
    );

    if (confirmed == true) {
      await context.read<PostCubit>().deletePost(postId);
    }
  }
  
  @override
  Widget build(BuildContext context) {

    bool isOwnPost = (widget.uid == currentUser!.uid);

    return BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state){
          if (state is ProfileLoaded){

            final user = state.profileUser;

            return Scaffold(
              appBar: AppBar(
                title: Text(user.name),
                centerTitle: true,
                foregroundColor: Theme.of(context).colorScheme.primary,
                actions: [

                  if(isOwnPost)
                  IconButton(
                    onPressed: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfilePage(user: user)
                          )
                      );
                    },
                    icon: const Icon(Icons.settings)
                  )
                ],
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        user.email,
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                      SizedBox(height: 25.h),
                      CachedNetworkImage(
                        imageUrl: user.profileImageUrl,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(
                          Icons.person,
                          size: 72.sp,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        imageBuilder: (context, imageProvider) => Container(
                          height: 120.h,
                          width: 120.w ,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover
                            )
                          ),
                        )
                      ),
                      SizedBox(height: 25.h),

                      ProfileStatus(
                        postCount: state.postCount,
                        followerCount: user.followers.length,
                        followingCount: user.following.length,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FollowerPage(
                                  followers: user.followers,
                                  following: user.following,
                                )
                            )
                        ),
                      ),
                      SizedBox(height: 25.h),
                      if (!isOwnPost)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Follow / Unfollow button
                            AppActionButton(
                              icon: user.followers.contains(currentUser!.uid)
                                  ? Icons.person_remove
                                  : Icons.person_add,
                              isFollowing: user.followers.contains(currentUser!.uid),
                              onPressed: followButtonPressed,
                            ),
                            SizedBox(width: 16.w),

                            // Message button
// Message button
                            AppActionButton(
                              icon: Icons.message,
                              text: "Message",
                              color: Theme.of(context).colorScheme.inversePrimary,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      receiverName: user.name,
                                      receiverId: user.uid,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                      SizedBox(height: 25.h),
                      Text(
                        "Bio",
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                      SizedBox(height: 10.h),
                      BioBox(text: user.bio),
                      SizedBox(height: 25.h),
                      Text(
                        "Post",
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                      SizedBox(height: 25.h),
                      BlocBuilder<PostCubit, PostState>(
                        builder: (context,state) {
                          
                          if(state is PostsLoaded){
                            
                            final userPosts = state.posts
                                .where((post) => post.userId == widget.uid)
                                .toList();
                            postCount = userPosts.length;

                            return ListView.builder(
                              itemCount: postCount,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final post = userPosts[index];

                                return PostTile(
                                  key: ValueKey(post.id),
                                  post: post,
                                  onDeletePressed: () => deletePost(context, post.id),
                                );
                              },
                            );


                          } 
                          
                          else if (state is PostsLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else {
                            return const Center(
                              child: Text("No posts.."),
                            );
                          }
                        }
                      )
                    ],
                  ),
                ),
              ),
            );
          } else if (state is ProfileLoading){
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return const Center(
              child: Text("No profile found.."),
            );
          }
        }
    );
  }
}
