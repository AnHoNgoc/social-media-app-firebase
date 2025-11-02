import 'package:social_media_app_firebase/features/auth/domain/entities/app_user.dart';

class ProfileUser extends AppUser {
  final String bio;
  final String profileImageUrl;
  final List<String> followers;
  final List<String> following;


  ProfileUser({
    required super.uid,
    required super.email,
    required super.name,
    required this.bio,
    required this.profileImageUrl,
    required this.followers,
    required this.following,
  });

  ProfileUser copyWith({
    String? newBio,
    String? newProfileImageUrl,
    List<String>? newFollowers,
    List<String>? newFollowing,
  }){
    return ProfileUser(
        uid: uid,
        email: email,
        name: name,
        bio: newBio ?? bio,
        profileImageUrl: newProfileImageUrl ??  profileImageUrl,
        followers: newFollowers ?? followers,
        following: newFollowing ?? following
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'followers': followers,
      'following': following
    };
  }

  // Tạo ProfileUser từ JSON
  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      bio: json['bio'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String? ?? '',
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
    );
  }
}