import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_media_app_firebase/core/utils/validators.dart';
import 'package:lottie/lottie.dart';
import 'package:social_media_app_firebase/features/auth/presentation/cubits/auth_cubit.dart';
import '../../../../core/components/my_button.dart';
import '../../../../core/components/my_text_field.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../cubits/auth_states.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
                  (route) => false,
            );
          } else if (state is AuthError) {
            showAppSnackBar(context, state.message, Colors.red);
          }
        },
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/lottie/social_media.json',
                    width: 250.sp,
                    height: 150.sp,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Welcome Back, you've been missed!",
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
                  SizedBox(height: 10.h),
                  MyTextField(
                    hintText: "Password",
                    obscureText: true,
                    controller: _passwordController,
                    validator: Validators.validatePassword,
                  ),
                  SizedBox(height: 10.h),

                  Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.resetPassword);
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Button hiển thị loading dựa trên state
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return MyButton(
                        text: "Login",
                        onTap: isLoading ? null : _login,
                        isLoading: isLoading,
                      );
                    },
                  ),

                  SizedBox(height: 25.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not a member?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: Text(
                          "Register now",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}