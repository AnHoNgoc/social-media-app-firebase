import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:social_media_app_firebase/features/profile/domain/entities/profile_user.dart';
import 'package:social_media_app_firebase/features/profile/domain/repository/profile_repo.dart';
import 'package:social_media_app_firebase/features/profile/presentation/cubits/profile_states.dart';
import 'package:social_media_app_firebase/features/storage/domain/storage_repo.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;

  ProfileCubit({required this.profileRepo, required this.storageRepo }) : super(ProfileInitial());

  Future<void> fetchUserProfile(String uid) async {
    try {
      emit(ProfileLoading());

      final user = await profileRepo.fetchUserProfile(uid);
      if (user == null) {
        emit(ProfileError("User not found"));
        return;
      }

      final count = await profileRepo.fetchPostCount(uid);

      emit(ProfileLoaded(profileUser: user, postCount: count));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<ProfileUser?> getUserProfile(String uid) async {
    final user = await profileRepo.fetchUserProfile(uid);
    return user;
  }


  Future<void> updateProfile ({
    required String uid,
    String? newBio,
    Uint8List? imageWebBytes,
    String? imageMobilePath
  }) async {
    emit(ProfileLoading());
    try {
      final currentUser = await profileRepo.fetchUserProfile(uid);

      if( currentUser == null){
        emit(ProfileError("Failed to fetch user for profile update"));
        return;
      }

      String? imageDownloadUrl;

      if(imageWebBytes != null || imageMobilePath != null){

        if(imageMobilePath != null){

          imageDownloadUrl = await storageRepo.uploadProfileImageMobile(imageMobilePath, uid);

        } else if (imageWebBytes != null) {

          imageDownloadUrl = await storageRepo.uploadProfileImageWeb(imageWebBytes, uid);
        }

      }

      if(imageDownloadUrl == null){
        emit(ProfileError("Failed to upload image"));
      }

      final updateProfile = currentUser.copyWith(
        newBio: newBio ?? currentUser.bio,
        newProfileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl
      );
      await profileRepo.updateProfile(updateProfile);
      await fetchUserProfile(uid);
    } catch (e) {
      emit(ProfileError("Error updating profile: $e"));
    }
  }

  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    try {
      await profileRepo.toggleFollow(currentUserId, targetUserId);

      await fetchUserProfile(targetUserId);
    } catch (e) {
      emit(ProfileError("Error toggling follow: $e"));
    }
  }

}