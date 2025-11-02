import 'package:social_media_app_firebase/features/profile/domain/entities/profile_user.dart';

abstract class ProfileRepo {
  Future<ProfileUser?> fetchUserProfile (String uid);
  Future<void> updateProfile (ProfileUser updatedProfile);
  Future<void> toggleFollow (String currentUid, String targetUid);
  Future<int> fetchPostCount(String uid);
}