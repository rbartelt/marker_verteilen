import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'domain/usecases/manage_beachsection.dart';
import 'data/repositories/beachsection_repository_impl.dart';
import 'data/datasources/supabase_beachsection_datasource.dart';
import 'presentation/bloc/beachsection_bloc.dart';
import 'presentation/pages/beachsection_screen.dart';
import 'presentation/pages/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://faoaccqijwrgblcewkur.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZhb2FjY3FpandyZ2JsY2V3a3VyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTc1MzM4OTYsImV4cCI6MjAzMzEwOTg5Nn0.S4gGDdAdFyVSD7YKHUrCbL0Go5vrA8gcdQySEagjmwQ',
  );

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
    // Initialisiere die Datenquelle und das Repository
    final supabaseClient = Supabase.instance.client;
    final beachSectionDataSource = SupabaseBeachSectionDataSource(supabaseClient);
    final beachSectionRepository = BeachSectionRepositoryImpl(beachSectionDataSource);
    final manageBeachSection = ManageBeachSection(beachSectionRepository);

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
