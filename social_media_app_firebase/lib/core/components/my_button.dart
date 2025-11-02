import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  final bool isLoading;
  final Color? textColor;

  const MyButton({
    super.key,
    required this.text,
    this.onTap,
    this.isLoading = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12.r), // bo góc co giãn
        ),
        padding: EdgeInsets.all(18.h), // padding responsive
        margin: EdgeInsets.symmetric(horizontal: 25.w), // margin responsive
        child: Center(
          child: isLoading
              ? SizedBox(
            width: 22.w,
            height: 22.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.blue,
            ),
          ) : Text(text),
        ),
      ),
    );
  }
}