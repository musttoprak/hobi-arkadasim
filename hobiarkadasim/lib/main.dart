import 'package:flutter/material.dart';
import 'package:hobiarkadasim/components/bottom_navigation_bar.dart';
import 'package:hobiarkadasim/screens/Welcome/welcome_screen.dart';
import 'package:hobiarkadasim/screens/home_screen.dart';
import 'package:hobiarkadasim/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'constants/app_colors.dart';
import 'constants/constants.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? isLogin;

  @override
  void initState() {
    _checkLogin();
    super.initState();
  }

  Future<void> _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('id') != null) {
      setState(() {
        isLogin = true;
      });
    } else {
      setState(() {
        isLogin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hobi Arkadaşım',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: AppColors.primaryWhiteColor,
          scaffoldBackgroundColor: Colors.white,
          canvasColor: const Color(0xFFCADCF8),
          backgroundColor: AppColors.primaryWhiteColor,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: Colors.white,
              backgroundColor: kPrimaryColor,
              shape: const StadiumBorder(),
              maximumSize: const Size(double.infinity, 56),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: kPrimaryLightColor,
            iconColor: kPrimaryColor,
            prefixIconColor: kPrimaryColor,
            contentPadding: EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide.none,
            ),
          ),
          textTheme: const TextTheme(
              headline1: TextStyle(
                  color: AppColors.headerTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 28),
              headline2:
              TextStyle(color: AppColors.headerTextColor, fontSize: 24),
              headline3: TextStyle(
                  color: AppColors.primaryWhiteColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFCADCF8), elevation: 0)),
      home: isLogin == null
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : isLogin!
          ? const HomeTabbarView()
          : const WelcomeScreen(),
    );
  }
}