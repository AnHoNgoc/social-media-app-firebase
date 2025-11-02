import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app_firebase/features/post/domain/entities/comment.dart';
import 'package:social_media_app_firebase/features/post/domain/repository/post_repo.dart';
import 'package:social_media_app_firebase/features/post/presentation/cubits/post_states.dart';
import '../../../storage/domain/storage_repo.dart';
import '../../domain/entities/post.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({
    required this.postRepo,
    required this.storageRepo,
  }) : super(PostsInitial());

  // Lấy tất cả bài post
  Future<void> fetchPosts() async {
    try {
      emit(PostsLoading());
      final posts = await postRepo.fetchAllPosts();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError(e.toString()));
    }
  }

  // Tạo bài post mới
  Future<void> createPost(Post post, {String? imagePath, Uint8List? imageBytes}) async {
    String? imageUrl;
    try {
      if(imagePath != null){
        emit(PostsUpLoading());
        imageUrl = await storageRepo.uploadPostImageMobile(imagePath, post.id);
      } else if (imageBytes != null){
        emit(PostsUpLoading());
        imageUrl = await storageRepo.uploadPostImageWeb(imageBytes, post.id) ;
      }

      final newPost = post.copyWith(imageUrl: imageUrl);
      postRepo.createPost(newPost);
      await fetchPosts();
    } catch (e) {
      emit(PostsError(e.toString()));
    }
  }

  // Xóa bài post
  Future<void> deletePost(String postId) async {
    try {
      emit(PostsLoading());
      await postRepo.deletePost(postId);
      await fetchPosts();
    } catch (e) {
      emit(PostsError(e.toString()));
    }
  }

  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      await postRepo.toggleLikePost(postId, userId);
      // await fetchPosts();
    } catch (e){
      emit(PostsError("Failed to toggle like: $e"));
    }
  }



  Future<void> addComment(String postId, Comment comment) async {
    try {
      await postRepo.addComment(postId, comment);

      await fetchPosts();
    } catch (e){
      emit(PostsError("Failed to add comment: $e"));
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await postRepo.deleteComment(postId, commentId);

      await fetchPosts();
    } catch (e){
      emit(PostsError("Failed to delete comment: $e"));
    }
  }

}