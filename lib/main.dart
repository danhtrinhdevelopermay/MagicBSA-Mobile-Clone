import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/generation_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/editor_screen.dart';
import 'screens/apple_photos_cleanup_screen.dart';
import 'providers/image_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set transparent system bars
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  
  // Enable edge-to-edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  runApp(const AIImageEditorApp());
}

class AIImageEditorApp extends StatelessWidget {
  const AIImageEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ImageEditProvider(),
      child: MaterialApp(
        title: 'MagicBSA',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366f1),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const SplashScreen(),
        routes: {
          '/generation': (context) => const GenerationScreen(),
          '/upload': (context) => const UploadScreen(),
          '/editor': (context) => const EditorScreen(),
          '/apple-cleanup': (context) => const ApplePhotosCleanupScreen(),
        },
      ),
    );
  }
}