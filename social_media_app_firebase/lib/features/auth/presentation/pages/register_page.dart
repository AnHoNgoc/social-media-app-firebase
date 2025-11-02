import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_media_app_firebase/core/utils/validators.dart';
import '../../../../core/components/my_button.dart';
import '../../../../core/components/my_text_field.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/auth_states.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _register() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      context.read<AuthCubit>().register(name, email, password);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
            showAppSnackBar(context, "Account registered successfully", Colors.green);
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
                  Icon(
                    Icons.lock_outline,
                    size: 60.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(height: 50.h),
                  Text(
                    "Let's create an account for you",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 25.h),
                  MyTextField(
                    hintText: "Name",
                    obscureText: false,
                    controller: _nameController,
                    validator: Validators.validateUser,
                  ),
                  SizedBox(height: 10.h),
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
                  MyTextField(
                    hintText: "Confirm Password",
                    obscureText: true,
                    controller: _confirmPasswordController,
                    validator: (value) => Validators.validateConfirmPassword(
                      value,
                      _passwordController.text,
                    ),
                  ),
                  SizedBox(height: 25.h),

                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return MyButton(
                        text: "Register",
                        onTap: isLoading ? null : _register,
                        isLoading: isLoading,
                      );
                    },
                  ),

                  SizedBox(height: 25.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Login now",
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