import 'package:social_media_app_firebase/features/profile/domain/entities/profile_user.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState{}

class ProfileLoading extends ProfileState{}

class ProfileLoaded extends ProfileState {
  final ProfileUser profileUser;
  final int postCount; // thêm field

  ProfileLoaded({required this.profileUser, this.postCount = 0});
}

class ProfileError extends ProfileState{
  final String message;
  ProfileError(this.message);
}