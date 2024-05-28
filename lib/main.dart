import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'domain/usecases/manage_beachsection.dart';
import 'domain/services/beachsection_service.dart';
import 'presentation/bloc/beachsection_bloc.dart';
import 'presentation/pages/beachsection_screen.dart';
import 'presentation/pages/home_screen.dart';

void main() {
  final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => NoTransitionPage(child: const HomeScreen()),
      ),
      GoRoute(
        path: '/setup',
        pageBuilder: (context, state) => NoTransitionPage(child: const BeachSectionScreen()),
      ),
    ],
  );

  runApp(MyApp(router: router));
}

class MyApp extends StatelessWidget {
  final GoRouter router;

  const MyApp({required this.router, super.key});

  @override
  Widget build(BuildContext context) {
    // Initialisiere die Service- und UseCase-Klassen
    final beachSectionService = BeachSectionService();
    final manageBeachSection = ManageBeachSection(beachSectionService);

    return MultiBlocProvider(
      providers: [
        BlocProvider<BeachSectionBloc>(
          create: (context) => BeachSectionBloc(manageBeachSection),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        title: 'Smartkorb',
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class NoTransitionPage extends CustomTransitionPage<void> {
  NoTransitionPage({required Widget child})
      : super(
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child; // Keine Animation
          },
        );
}
