import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await dotenv.load(fileName: '.env').catchError(
    (_) => debugPrint('Warning: .env not found'),
  );
  runApp(const AutoTesterApp());
}

class AutoTesterApp extends StatelessWidget {
  const AutoTesterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoTester AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      home: const SplashScreen(),
    );
  }
}

class AppColors {
  static const bg         = Color(0xFF080810);
  static const surface    = Color(0xFF0E0E1A);
  static const glass      = Color(0x0AFFFFFF);
  static const glassBorder= Color(0x14FFFFFF);
  static const accent     = Color(0xFF8B5CF6);
  static const accentDim  = Color(0x268B5CF6);
  static const accentGlow = Color(0x408B5CF6);
  static const white      = Color(0xFFF8FAFC);
  static const secondary  = Color(0x99FFFFFF);
  static const muted      = Color(0x40FFFFFF);
  static const faint      = Color(0x18FFFFFF);
  static const success    = Color(0xFF22C55E);
  static const successDim = Color(0x1522C55E);
  static const error      = Color(0xFFEF4444);
  static const errorDim   = Color(0x15EF4444);
  static const border     = Color(0x12FFFFFF);
}
