import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_media_app_firebase/core/components/my_text_field.dart';
import 'package:social_media_app_firebase/features/profile/domain/entities/profile_user.dart';
import 'package:social_media_app_firebase/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media_app_firebase/features/profile/presentation/cubits/profile_states.dart';
import 'package:flutter/foundation.dart' show  kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';


class EditProfilePage extends StatefulWidget {
  final ProfileUser user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  PlatformFile? imagePickerFile;

  Uint8List? webImage;

  final bioTextController = TextEditingController();

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

  void updateProfile() async {
    final profileCubit = context.read<ProfileCubit>();

    final String uid = widget.user.uid;
    final String? newBio = bioTextController.text.isNotEmpty ? bioTextController.text : null;
    final imageMobilePath = kIsWeb ? null : imagePickerFile?.path;
    final imageWebBytes = kIsWeb ? imagePickerFile?.bytes : null;

    if(imagePickerFile != null || newBio != null){
      profileCubit.updateProfile(
        uid: uid,
        newBio: newBio,
        imageMobilePath: imageMobilePath,
        imageWebBytes: imageWebBytes
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      builder:(context, state){
        if (state is ProfileLoading){
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text("Uploading...")
                ],
              ),
            ),
          );
        } else {
          return buildEditPage();
        }
      },
      listener: (context, state) {
        if (state is ProfileLoaded){
          Navigator.pop(context);
        }
      }
    );
  }

  Widget buildEditPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: updateProfile,
            icon: Icon(Icons.upload)
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10.h),
          Center(
            child: Container(
              height: 200.h,
              width: 200.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle
              ),
              clipBehavior: Clip.hardEdge,
              child:
              (!kIsWeb && imagePickerFile != null)
                ? Image.file(
                  File(imagePickerFile!.path!),
                  fit: BoxFit.cover,
                ) 
                : (kIsWeb && webImage != null)
                  ? Image.memory(webImage!)
                  :
                  CachedNetworkImage(
                    imageUrl: widget.user.profileImageUrl,
                    placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(
                      Icons.person,
                      size: 72.sp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    imageBuilder: (context, imageProvider) =>
                    Image(
                        image: imageProvider,
                        fit: BoxFit.cover
                    ),
                  )
            ),
          ),
          SizedBox(height: 20.h),
          Center(
            child: MaterialButton(
              onPressed: pickImage,
              color: Colors.blue,
              child: const Text("Pick Image"),
            ),
          ),
          SizedBox(height: 25.h),
          const Text("Bio"),
          SizedBox(height: 10.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.r),
            child: MyTextField(
              controller: bioTextController,
              hintText: widget.user.bio ,
              obscureText: false,
            ),
          )
        ],
      ),
    );
  }
}
