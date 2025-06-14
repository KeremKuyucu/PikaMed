import 'package:PikaMed/model/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Menu/navigation_home_screen.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'functions.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:PikaMed/Service/NotificationService.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _requestNotificationPermission();
  await NotificationService.instance.initialize();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) => runApp(MyApp()));
  Locale deviceLocale = PlatformDispatcher.instance.locale;
  localLanguage = deviceLocale.languageCode;
  if (kDebugMode) {
    NotificationService.instance.showNotification(
      'Debug Test Bildimi',
      'Eğer bu bildirimi görüyorsan lütfen geliştirici ile iletişime geç hatayı düzeltsin.',
    );
  }
}

Future<void> _requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    Permission.notification.request();
  }
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    return MaterialApp(
      title: 'PikaMed',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: AppTheme.textTheme,
        platform: TargetPlatform.iOS,
      ),
      themeMode: ThemeMode.light,
      home: NavigationHomeScreen(),
    );
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}

/*
flutter pub run flutter_launcher_icons:main

flutter build apk --release --split-per-abi

 */