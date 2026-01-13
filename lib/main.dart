import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/feedback_repository.dart';
import 'data/repositories/mock_auth_repository.dart';
import 'data/repositories/mock_feedback_repository.dart';
import 'presentation/screens/landing_screen.dart';
// import 'firebase_options.dart'; // TODO: Run flutterfire configure to generate this

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool firebaseInitialized = false;
  
  // Initialize Firebase
  // For now, we'll try to initialize. If you haven't run `flutterfire configure`,
  // this might fail on platforms other than Android/iOS setup manually.
  try {
     await Firebase.initializeApp(
        // options: DefaultFirebaseOptions.currentPlatform, // Uncomment after generation
     );
     firebaseInitialized = true;
  } catch (e) {
    print("Firebase init failed (expected if not configured): $e");
    print("Switching to MOCK MODE");
  }

  runApp(
    ProviderScope(
      overrides: firebaseInitialized ? [] : [
        authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        feedbackRepositoryProvider.overrideWithValue(MockFeedbackRepository()),
      ],
      child: const SilentSignalsApp(),
    ),
  );
}

class SilentSignalsApp extends ConsumerStatefulWidget {
  const SilentSignalsApp({super.key});

  @override
  ConsumerState<SilentSignalsApp> createState() => _SilentSignalsAppState();
}

class _SilentSignalsAppState extends ConsumerState<SilentSignalsApp> {
  @override
  void initState() {
    super.initState();
    // Anonymous Sign-in on startup
    ref.read(authRepositoryProvider).signInAnonymously();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silent Signals',
      theme: AppTheme.darkTheme,
      home: const LandingScreen(),
    );
  }
}

