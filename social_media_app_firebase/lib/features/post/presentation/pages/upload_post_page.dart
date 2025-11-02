import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_media_app_firebase/core/components/my_text_field.dart';
import 'package:social_media_app_firebase/core/utils/show_snackbar.dart';
import 'package:social_media_app_firebase/features/auth/domain/entities/app_user.dart';
import 'package:social_media_app_firebase/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter/foundation.dart' show  kIsWeb;
import 'package:social_media_app_firebase/features/post/domain/entities/post.dart';
import 'package:social_media_app_firebase/features/post/presentation/cubits/post_cubits.dart';
import 'package:social_media_app_firebase/features/post/presentation/cubits/post_states.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {

  PlatformFile? imagePickerFile;

  Uint8List? webImage;

  final textController = TextEditingController();

  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUSer();

  }

  void getCurrentUSer() async {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  Future<void> pickImage () async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: kIsWeb
    );

    if (result != null){
      setState(() {
        imagePickerFile = result.files.first;
        if(kIsWeb){
          webImage = imagePickerFile!.bytes;
        }
      });
    }
  }

  void uploadPost() {
    if(imagePickerFile == null || textController.text.isEmpty){
      showAppSnackBar(context, "Both image and caption are required", Colors.redAccent);
      return;
    }

    final newPost = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUser!.uid,
        userName: currentUser!.name,
        text: textController.text,
        imageUrl: '',
        timestamp: DateTime.now(),
        likes: [],
        comments: []
    );

    final postCubit = context.read<PostCubit>();

    if(kIsWeb){
      postCubit.createPost(newPost, imageBytes: imagePickerFile?.bytes);
    }else{
      postCubit.createPost(newPost, imagePath: imagePickerFile?.path);
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      builder: (context, state){
        if (state is PostsLoading || state is PostsUpLoading){
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return buildUploadPage();
      },
      listener: (context, state) {
        if (state is PostsLoaded) {
          Navigator.pop(context);
        }
      });
  }

  Widget buildUploadPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(onPressed: uploadPost, icon: const Icon(Icons.upload)),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (kIsWeb && webImage != null)
                  Image.memory(
                    webImage!,
                    height: 300.h,
                    fit: BoxFit.cover,
                  ),
                if (!kIsWeb && imagePickerFile != null)
                  Image.file(
                    File(imagePickerFile!.path!),
                    height: 400.h,
                    fit: BoxFit.cover,
                  ),
                SizedBox(height: 16.h),
                Center(
                  child: MaterialButton(
                    onPressed: pickImage,
                    color: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    child: const Text(
                      "Pick Image",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                MyTextField(
                  hintText: "Caption",
                  obscureText: false,
                  controller: textController,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
