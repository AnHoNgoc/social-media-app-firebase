import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app_firebase/features/auth/domain/entities/app_user.dart';
import 'package:social_media_app_firebase/features/auth/domain/repository/auth_repo.dart';
import 'auth_states.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}) : super(AuthInitial());

  void checkAuth() async {
    try {
      final AppUser? user = await authRepo.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError('Error checking auth: $e'));
    }
  }

  AppUser? get currentUser => _currentUser;

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final AppUser? user = await authRepo.loginWithEmailPassword(email, password);
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      String errorMessage = 'Login failed. Please try again.';
      if (e is Exception) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      emit(AuthError(errorMessage));
    }
  }

  Future<void> register(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      final AppUser? user = await authRepo.registerWithEmailPassword(name, email, password);
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      String errorMessage = 'Registration failed. Please try again.';
      if (e is Exception) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      emit(AuthError(errorMessage));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await authRepo.logout();
      _currentUser = null;
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError('Logout error: $e'));
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    emit(AuthLoading());
    try {
      await authRepo.changePassword(currentPassword, newPassword);
      emit(PasswordChanged());
    } catch (e) {
      String errorMessage = 'Password change failed. Please try again.';
      if (e is Exception) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      emit(PasswordChangeError(errorMessage));
    }
  }

  Future<void> resetPassword(String email) async {
    emit(AuthLoading()); // có thể dùng loading để UI biết đang gửi email
    try {
      await authRepo.resetPassword(email);
      emit(PasswordResetEmailSent());
    } catch (e) {
      String errorMessage = 'Failed to reset password. Please try again.';
      if (e is Exception) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      emit(PasswordResetError(errorMessage));
    }
  }
}