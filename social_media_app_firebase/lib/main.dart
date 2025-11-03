import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_media_app_firebase/core/themes/theme_cubit.dart';
import 'package:social_media_app_firebase/features/auth/data/firebase_auth_repo.dart';
import 'package:social_media_app_firebase/features/auth/presentation/pages/login_page.dart';
import 'package:social_media_app_firebase/features/chat/data/firebase_chat_repo.dart';
import 'package:social_media_app_firebase/features/post/data/firebase_post_repo.dart';
import 'package:social_media_app_firebase/features/post/presentation/cubits/post_cubits.dart';
import 'package:social_media_app_firebase/features/profile/data/firebase_profile_repo.dart';
import 'package:social_media_app_firebase/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media_app_firebase/features/search/data/firebase_search_repo.dart';
import 'package:social_media_app_firebase/features/storage/data/firebase_storage_repo.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';
import 'features/chat/presentation/cubits/chat_cubit.dart';
import 'features/search/presentation/cubit/search_cubit.dart';
import 'firebase_options.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepo: FirebaseAuthRepo()),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
            profileRepo: FirebaseProfileRepo(),
            storageRepo: FirebaseStorageRepo(),
          ),
        ),
        BlocProvider<PostCubit>(
          create: (context) => PostCubit(
            postRepo: FirebasePostRepo(),
            storageRepo: FirebaseStorageRepo(),
          ),
        ),
        BlocProvider<SearchCubit>(
          create: (context) => SearchCubit(
            searchRepo: FirebaseSearchRepo(),
          ),
        ),
        BlocProvider<ChatCubit>(
          create: (context) => ChatCubit(
            chatRepo: FirebaseChatRepo(),
          ),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocBuilder<ThemeCubit, ThemeData>(
          builder: (context, themeState) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              navigatorObservers: [routeObserver],
              routes: AppRoutes.routes,
              theme: themeState, // lấy theme từ ThemeCubit
              home: LoginPage(),
            );
          },
        );
      },
    );
  }
}
