import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/components/my_button.dart';
import '../../../../core/components/my_text_field.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/utils/validators.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/auth_states.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().changePassword(
        _oldPasswordController.text.trim(),
        _newPasswordController.text.trim(),
      );
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Change password",
          style: TextStyle(fontSize: 18.sp),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is PasswordChanged) {
            showAppSnackBar(context, "Password changed successfully!", Colors.green);
            Navigator.pop(context);
          } else if (state is PasswordChangeError) {
            showAppSnackBar(context, state.message, Colors.red);
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 60.r,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(height: 50.h),
                  Text(
                    "For your security, please set a new password",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 25.h),
                  MyTextField(
                    hintText: "Old Password",
                    obscureText: true,
                    controller: _oldPasswordController,
                    validator: Validators.validatePassword,
                  ),
                  SizedBox(height: 10.h),
                  MyTextField(
                    hintText: "New Password",
                    obscureText: true,
                    controller: _newPasswordController,
                    validator: (value) =>
                        Validators.validateNewPassword(value, _oldPasswordController.text),
                  ),
                  SizedBox(height: 10.h),
                  MyTextField(
                    hintText: "Confirm New Password",
                    obscureText: true,
                    controller: _confirmNewPasswordController,
                    validator: (value) =>
                        Validators.validateConfirmPassword(value, _newPasswordController.text),
                  ),
                  SizedBox(height: 25.h),

                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return MyButton(
                        text: "Change Password",
                        onTap: isLoading ? null : _changePassword,
                        isLoading: isLoading,
                      );
                    },
                  ),

                  SizedBox(height: 25.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}