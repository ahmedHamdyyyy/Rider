import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BuildMultiProvider extends StatelessWidget {
  const BuildMultiProvider({
    super.key,
    required this.child,
  });
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        /*  BlocProvider.value(
          value: getIt<NavigationCubit>(),
        ), */
      ],
      child: child,
    );
  }
}
