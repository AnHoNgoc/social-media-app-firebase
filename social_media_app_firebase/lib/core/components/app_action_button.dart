import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppActionButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool? isFollowing;
  final String? text;
  final IconData icon;
  final Color? color;

  const AppActionButton({
    super.key,
    this.onPressed,
    this.isFollowing,
    this.text,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonLabel = text ??
        (isFollowing != null
            ? (isFollowing! ? "Unfollow" : "Follow")
            : "Message");

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: MaterialButton(
        onPressed: onPressed,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
        minWidth: 160.w, // 🔑 chỉnh độ rộng tối thiểu
        color: color ??
            (isFollowing != null
                ? (isFollowing!
                ? Theme.of(context).colorScheme.primary
                : Colors.blue)
                : Colors.green),
        child: Row(
          mainAxisSize: MainAxisSize.min, // 🔑 fit nội dung
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.secondary),
            SizedBox(width: 8.w),
            Text(
              buttonLabel,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
