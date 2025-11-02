import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app_firebase/core/components/my_drawer.dart';
import 'package:social_media_app_firebase/core/components/post_tile.dart';
import 'package:social_media_app_firebase/core/routes/app_routes.dart';
import 'package:social_media_app_firebase/features/post/presentation/cubits/post_cubits.dart';
import 'package:social_media_app_firebase/features/post/presentation/cubits/post_states.dart';
import '../../../../core/utils/confirmation_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

 late final postCubit = context.read<PostCubit>();

 @override
  void initState() {
    super.initState();
    fetAllPosts();
  }

  void fetAllPosts() {
    postCubit.fetchPosts();
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
     await postCubit.deletePost(postId);
     fetAllPosts();
   }
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: (){
              Navigator.pushNamed(context, AppRoutes.uploadPost);
            },
            icon: const Icon(Icons.add)
          )
        ],
      ),
      drawer: MyDrawer(),
      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          if (state is PostsUpLoading || state is PostsUpLoading){
            return const Center(child: CircularProgressIndicator());
          }

          else if (state is PostsLoaded) {
            final allPost = state.posts;
            
            if (allPost.isEmpty){
              return const Center(
                child: Text("No posts available"),
              );
            }
            return ListView.builder(
              key: PageStorageKey('allPostList'),
              itemBuilder: (context, index) {
                final post = allPost[index];
                return PostTile(
                  key: ValueKey(post.id),
                  post: post,
                  onDeletePressed: () => deletePost(context, post.id),
                );
              },
            );
          }

          else if (state is PostsError) {
            return Center(child: Text(state.message));
          } else {
            return const SizedBox();
          }
        }
      )
    );
  }
}
