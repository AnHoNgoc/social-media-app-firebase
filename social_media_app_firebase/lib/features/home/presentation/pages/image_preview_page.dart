import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImagePreviewPage extends StatelessWidget {
  final String imageUrl;

  const ImagePreviewPage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Ảnh full màn hình
          Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: imageUrl ?? "",
                fit: BoxFit.contain,
                placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                const Icon(Icons.error, color: Colors.white),
              ),
            ),
          ),

          Positioned(
            top: 50.r,
            left: 8.r,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}