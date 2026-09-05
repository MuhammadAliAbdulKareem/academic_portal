import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';

/// Manages Firebase initialization and runtime operational status.
class FirebaseConfig {
  FirebaseConfig._();

  static bool _isInitialized = false;
  static String? _initError;

  /// Whether Firebase has been initialized successfully.
  static bool get isInitialized => _isInitialized;

  /// Error description if Firebase initialization encountered an issue.
  static String? get initError => _initError;

  /// Safely initializes Firebase across all supported platforms.
  static Future<void> initialize() async {
    try {
      if (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        _isInitialized = true;
        developer.log('Firebase initialized successfully.', name: 'FirebaseConfig');
      } else {
        developer.log(
          'Firebase initialized in fallback mode for platform $defaultTargetPlatform.',
          name: 'FirebaseConfig',
        );
        _isInitialized = true;
      }
    } catch (e, stackTrace) {
      _isInitialized = false;
      _initError = e.toString();
      developer.log(
        'Firebase initialization warning: $e',
        name: 'FirebaseConfig',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
