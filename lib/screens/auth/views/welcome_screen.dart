import 'package:emonic/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:emonic/screens/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/sign_up_bloc/sign_up_bloc.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import 'package:emonic/constants/colors.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryBlue,
              AppColors.secondaryBlue,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Image.asset(
                    'assets/logo.png',
                    height: 100,
                    width: 100,
                  ),
                  //Gap between logo and text
                  const SizedBox(height: 30),
                  // Welcome Text
                  const Text(
                    'Welcome to Emonic',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Card for content
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          // Tabs for Sign In / Sign Up
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TabBar(
                              controller: tabController,
                              unselectedLabelColor: AppColors.grey,
                              labelColor: AppColors.primaryBlue,
                              indicatorColor: AppColors.secondaryBlue,
                              indicatorSize: TabBarIndicatorSize.label,
                              dividerColor: Colors.transparent,
                              tabs: const [
                                Tab(text: 'Sign In'),
                                Tab(text: 'Sign Up'),
                              ],
                            ),
                          ),

                          // TabBarView for Sign In / Sign Up forms
                          Expanded(
                            child: TabBarView(
                              controller: tabController,
                              children: [
                                // Sign In Tab
                                BlocProvider<SignInBloc>(
                                  create: (context) => SignInBloc(context
                                      .read<AuthenticationBloc>()
                                      .userRepository),
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: SignInScreen(),
                                  ),
                                ),

                                // Sign Up Tab
                                BlocProvider<SignUpBloc>(
                                  create: (context) => SignUpBloc(context
                                      .read<AuthenticationBloc>()
                                      .userRepository),
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: SignUpScreen(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
