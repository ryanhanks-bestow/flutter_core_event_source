import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

class DebugBlocObserver extends BlocObserver {
  static void observe() {
    Bloc.observer = const DebugBlocObserver();
  }

  const DebugBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    debugPrint('\nBloc.onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    debugPrint('\nBloc.onError - ${bloc.runtimeType}');
    debugPrintStack(label: error.toString(), stackTrace: stackTrace);
  }
}
