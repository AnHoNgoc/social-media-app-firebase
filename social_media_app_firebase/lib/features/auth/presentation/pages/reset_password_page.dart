import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/components/my_button.dart';
import '../../../../core/components/my_text_field.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/utils/validators.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/auth_states.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().resetPassword(_emailController.text.trim());
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Reset Password"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetEmailSent) {
            showAppSnackBar(
              context,
              "Password reset email sent! Check your inbox.",
              Colors.green,
            );
          } else if (state is PasswordResetError) {
            showAppSnackBar(
              context,
              state.message,
              Colors.red,
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    SizedBox(height: 100.h),
                    Text(
                      "Enter your email to reset your password",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 25.h),
                    MyTextField(
                      hintText: "Email",
                      obscureText: false,
                      controller: _emailController,
                      validator: Validators.validateEmail,
                    ),
                    SizedBox(height: 25.h),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return MyButton(
                          text: "Send Reset Email",
                          onTap: isLoading ? null : _resetPassword,
                          isLoading: isLoading,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
