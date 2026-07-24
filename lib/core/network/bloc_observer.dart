import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    if (kDebugMode) {
      debugPrint('🔄 ${bloc.runtimeType} → ${change.nextState}');
    }
    super.onChange(bloc, change);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ ${bloc.runtimeType} ERROR → $error');
    }
    super.onError(bloc, error, stackTrace);
  }
}
