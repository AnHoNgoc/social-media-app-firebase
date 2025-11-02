import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BioBox extends StatelessWidget {
  final String text;
  const BioBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
      ),
      width: double.infinity,
      child: Text(text.isNotEmpty ?  text : "Empty bio.."),
    );
  }
}
