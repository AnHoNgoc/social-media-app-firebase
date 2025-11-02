import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app_firebase/features/post/domain/entities/comment.dart';
import 'package:social_media_app_firebase/features/post/domain/entities/post.dart';
import 'package:social_media_app_firebase/features/post/domain/repository/post_repo.dart';

class FirebasePostRepo implements PostRepo {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final CollectionReference postCollection =
  FirebaseFirestore.instance.collection("posts");

  @override
  Future<void> createPost(Post post) async {
    try {
      await postCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception("Error creating post: $e");
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await postCollection.doc(postId).delete();
    } catch (e) {
      throw Exception("Error deleting post: $e");
    }
  }

  @override
  Future<List<Post>> fetchAllPosts() async {
    try {
      final snapshot =
      await postCollection.orderBy("timestamp", descending: true).get();

      return snapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Error fetching all posts: $e");
    }
  }

  @override
  Future<List<Post>> fetchPostByUserId(String userId) async {
    try {
      final snapshot = await postCollection
          .where("userId", isEqualTo: userId)
          .orderBy("timestamp", descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Error fetching posts by userId: $e");
    }
  }

  @override
  Future<void> toggleLikePost(String postId, String userId) async {
    try {

      final postDoc = await postCollection.doc(postId).get();

      if(postDoc.exists){
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        final hasLike = post.likes.contains(userId);

        if (hasLike) {
          post.likes.remove(userId);
        } else {
          post.likes.add(userId);
        }

        await postCollection.doc(postId).update({
          'likes': post.likes
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error toggling like: $e");
    }
  }

  @override
  Future<void> addComment(String postId, Comment comment) async {
    try {
      final postDoc = await postCollection.doc(postId).get();

      if (postDoc.exists){
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        post.comments.add(comment);

        await postCollection.doc(postId).update({
          'comments' : post.comments.map((comment) => comment.toJson()).toList()
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error adding comment: $e");
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      final postDoc = await postCollection.doc(postId).get();

      if (postDoc.exists){
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        post.comments.removeWhere((comment) => comment.id == commentId);

        await postCollection.doc(postId).update({
          'comments' : post.comments.map((comment) => comment.toJson()).toList()
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error deleting comment: $e");
    }
  }
}