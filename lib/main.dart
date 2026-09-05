import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/app.dart';
import 'core/bloc/app_bloc_observer.dart';
import 'core/firebase/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register global Bloc observer for state transition & error logging
  Bloc.observer = AppBlocObserver();

  // Initialize Firebase with cross-platform fallback safety
  await FirebaseConfig.initialize();

  runApp(const AcademicPortalApp());
}
