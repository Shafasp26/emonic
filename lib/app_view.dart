import 'package:emonic/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:emonic/screens/auth/views/welcome_screen.dart';
import 'package:emonic/screens/home/views/home_screen.dart';
import 'package:emonic/screens/splash/splash_screen.dart';  // Add this import
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emonic',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          surface: Colors.grey.shade100,
          onSurface: Colors.black,
          primary: Colors.blue,
          onPrimary: Colors.white,
        )
      ),
      home: FutureBuilder(
        future: Future.delayed(const Duration(seconds: 3)), // 3 seconds delay
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          return BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: ((context, state) {
              if(state.status == AuthenticationStatus.authenticated) {
                return const HomeScreen();
              } else {
                return const WelcomeScreen();
              }
            }),
          );
        },
      ),
    );
  }
}