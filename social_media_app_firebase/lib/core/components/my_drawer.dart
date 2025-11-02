import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_media_app_firebase/features/profile/presentation/page/profile_page.dart';
import '../../features/auth/presentation/cubits/auth_cubit.dart';
import '../routes/app_routes.dart';
import '../utils/confirmation_dialog.dart';
import '../utils/show_snackbar.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void _logout(BuildContext context) async {
    final confirm = await showConfirmationDialog(
      context,
      title: "Logout",
      message: "Are you sure you want to logout?",
      confirmText: "Logout",
      cancelText: "Cancel",
    );

    if (confirm == true) {
      final authCubit = context.read<AuthCubit>();
      try {
        await authCubit.logout();
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
      } catch (e) {
        // Xử lý lỗi logout
        showAppSnackBar(context, 'Logout failed: $e', Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                child: Center(
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                    size: 48.sp, // responsive icon
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 25.w),
                child: ListTile(
                  title: Text(
                    "H O M E",
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  leading: Icon(Icons.home, size: 22.sp),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 25.w),
                child: ListTile(
                  title: Text(
                    "S E A R C H",
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  leading: Icon(Icons.search, size: 22.sp),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.search);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 25.w),
                child: ListTile(
                  title: Text(
                    "S E T T I N G S",
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  leading: Icon(Icons.settings, size: 22.sp),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.setting);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 25.w),
                child: ListTile(
                  title: Text(
                    "P R O F I L E",
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  leading: Icon(Icons.person, size: 22.sp),
                  onTap: () {
                    Navigator.pop(context);
                    final user  = context.read<AuthCubit>().currentUser;
                    String? uid = user!.uid;
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(uid: uid)
                      )
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 25.w),
                child: ListTile(
                  title: Text(
                    "P A S S W O R D",
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  leading: Icon(Icons.password, size: 22.sp),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.changePassword);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 25.w),
                child: ListTile(
                  title: Text(
                    "C H A T R O O M",
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  leading: Icon(Icons.message, size: 22.sp),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.chatRoom);
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 25.w, bottom: 25.h),
            child: ListTile(
              title: Text(
                "L O G O U T",
                style: TextStyle(fontSize: 16.sp),
              ),
              leading: Icon(Icons.logout, size: 22.sp),
              onTap: () => _logout(context),
            ),
          ),
        ],
      ),
    );
  }
}