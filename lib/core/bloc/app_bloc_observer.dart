import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';

/// Global BlocObserver for monitoring state mutations, events, and errors.
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    developer.log(
      'Bloc Change [${bloc.runtimeType}]: ${change.currentState} -> ${change.nextState}',
      name: 'AppBlocObserver',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    developer.log(
      'Bloc Error in ${bloc.runtimeType}: $error',
      name: 'AppBlocObserver',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
