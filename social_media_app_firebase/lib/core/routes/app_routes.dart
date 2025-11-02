import 'package:flutter/cupertino.dart';
import 'package:social_media_app_firebase/features/auth/presentation/pages/change_password.dart';
import 'package:social_media_app_firebase/features/auth/presentation/pages/reset_password_page.dart';
import 'package:social_media_app_firebase/features/chat/presentation/pages/chat_list_page.dart';
import 'package:social_media_app_firebase/features/home/presentation/pages/home_page.dart';
import 'package:social_media_app_firebase/features/home/presentation/pages/settings_page.dart';
import 'package:social_media_app_firebase/features/search/presentation/page/search_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/post/presentation/pages/upload_post_page.dart';


class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String changePassword = '/change-password';
  static const String setting = '/setting';
  static const String uploadPost = '/upload-post';
  static const String search = '/search';
  static const String resetPassword = '/reset-password';
  static const String chatRoom = '/chat-room';


  static Map<String, WidgetBuilder> get routes => {
    login: (context) => LoginPage(),
    register: (context) => RegisterPage(),
    home: (context) => HomePage(),
    uploadPost: (context) => UploadPostPage(),
    setting: (context) => SettingsPage(),
    search: (context) => SearchPage(),
    changePassword: (context) => ChangePasswordPage(),
    resetPassword: (context) => ResetPasswordPage(),
    chatRoom: (context) => ChatListPage()
  };
}