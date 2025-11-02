import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileStatus extends StatelessWidget {
  final int postCount;
  final int followerCount;
  final int followingCount;
  final void Function()? onTap;

  const ProfileStatus({
    super.key,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    var textStyleForCount = TextStyle(
      fontSize: 15.sp, color: Theme.of(context).colorScheme.inversePrimary
    );

    var textStyleForText = TextStyle(
        fontSize: 15.sp, color: Theme.of(context).colorScheme.primary
    );

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          SizedBox(
            width: 110.w,
            child: Column(
              children: [
                Text(postCount.toString(), style: textStyleForCount),
                Text("Posts", style: textStyleForText,)
              ],
            ),
          ),

          SizedBox(
            width: 110.w,
            child: Column(
              children: [
                Text(followerCount.toString(), style: textStyleForCount),
                Text("Followers", style: textStyleForText)
              ],
            ),
          ),

          SizedBox(
            width: 110.w,
            child: Column(
              children: [
                Text(followingCount.toString(), style: textStyleForCount,),
                Text("Following", style: textStyleForText)
              ],
            ),
          )
        ],
      ),
    );
  }
}
