import 'package:emonic/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:emonic/screens/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/sign_up_bloc/sign_up_bloc.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(
      initialIndex: 0,
      length: 2, 
      vsync: this
    );
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
              Color(0xFF1976D2),
              Color(0xFF42A5F5),
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
                  // Profile avatar
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Welcome Text
                  const Text(
                    'Hello !',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Card for content
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          // Tabs for Sign In / Sign Up
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TabBar(
                              controller: tabController,
                              unselectedLabelColor: Colors.grey,
                              labelColor: const Color(0xFF2196F3),
                              indicatorColor: const Color(0xFF2196F3),
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
                                  create: (context) => SignInBloc(
                                    context.read<AuthenticationBloc>().userRepository
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    child: SignInScreen(),
                                  ),
                                ),
                                
                                // Sign Up Tab
                                BlocProvider<SignUpBloc>(
                                  create: (context) => SignUpBloc(
                                    context.read<AuthenticationBloc>().userRepository
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
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