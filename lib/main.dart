import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gh6_ucap/bloc/auth/auth_bloc.dart';
import 'package:gh6_ucap/bloc/login/login_bloc.dart';
import 'package:gh6_ucap/firebase_options.dart';
import 'package:gh6_ucap/firebase_seeder.dart';
import 'package:gh6_ucap/routes/routes.dart';
import 'package:gh6_ucap/services/article_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final ArticleService articleService = ArticleService();
  await FirebaseSeeder.seedAllData();
  await articleService.seedArticles();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginBloc()),
        BlocProvider(create: (context) => AuthBloc()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(412, 917),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => MaterialApp.router(
          routerConfig: routes,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
