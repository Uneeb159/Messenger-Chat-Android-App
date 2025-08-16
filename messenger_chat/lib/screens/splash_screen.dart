import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:messenger_chat/screens/welcome_screen.dart';
import 'package:messenger_chat/screens/users_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _mcController;
  late AnimationController _textController;
  late AnimationController _backgroundController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _mcScale;
  late Animation<double> _mcOpacity;
  late Animation<double> _backgroundOpacity;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _mcController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize animations
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    _mcScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _mcController, curve: Curves.bounceOut));

    _mcOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _mcController, curve: Curves.easeIn));

    _backgroundOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    // Start animation sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Start background animation
    _backgroundController.forward();

    // Wait a bit, then start logo animation
    await Future.delayed(const Duration(milliseconds: 500));
    _logoController.forward();

    // Wait for logo to finish, then start MC animation
    await Future.delayed(const Duration(milliseconds: 1500));
    _mcController.forward();

    // Wait for MC to finish, then start text animation
    await Future.delayed(const Duration(milliseconds: 1000));
    _textController.forward();

    // Navigate to appropriate screen after all animations
    await Future.delayed(const Duration(milliseconds: 4000));
    if (mounted) {
      // Check if user is already logged in
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // User is logged in, go to users screen
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                UsersScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      } else {
        // User is not logged in, go to welcome screen
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const WelcomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _mcController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(
                    0xFF0F0F23,
                  ).withValues(alpha: _backgroundOpacity.value),
                  const Color(
                    0xFF1A1A2E,
                  ).withValues(alpha: _backgroundOpacity.value),
                  const Color(
                    0xFF16213E,
                  ).withValues(alpha: _backgroundOpacity.value),
                  const Color(
                    0xFF0F3460,
                  ).withValues(alpha: _backgroundOpacity.value),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Animation
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                'images/logo.png',
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.chat_bubble_rounded,
                                    size: 60,
                                    color: Color(0xFF8B5CF6),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // MC Animation - M and C appear, then expand to full words
                  AnimatedBuilder(
                    animation: _mcController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _mcScale.value,
                        child: Opacity(
                          opacity: _mcOpacity.value,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // M expands to Messenger (clean text, no container)
                              Flexible(
                                child: AnimatedBuilder(
                                  animation: _textController,
                                  builder: (context, child) {
                                    if (_textController.value == 0) {
                                      // Show just "M" initially
                                      return Text(
                                        'M',
                                        style: TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 3.0,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.3,
                                              ),
                                              offset: const Offset(2, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      // Start typing "essenger" after M
                                      return AnimatedTextKit(
                                        key: ValueKey('messenger'),
                                        animatedTexts: [
                                          TypewriterAnimatedText(
                                            'Messenger',
                                            textStyle: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 1.5,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.3),
                                                  offset: const Offset(2, 2),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            speed: const Duration(
                                              milliseconds: 100,
                                            ),
                                            cursor: '|',
                                          ),
                                        ],
                                        totalRepeatCount: 1,
                                        displayFullTextOnTap: false,
                                        isRepeatingAnimation: false,
                                      );
                                    }
                                  },
                                ),
                              ),

                              const SizedBox(width: 20),

                              // C expands to Chat (clean text, no container)
                              Flexible(
                                child: AnimatedBuilder(
                                  animation: _textController,
                                  builder: (context, child) {
                                    if (_textController.value == 0) {
                                      // Show just "C" initially
                                      return Text(
                                        'C',
                                        style: TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 3.0,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.3,
                                              ),
                                              offset: const Offset(2, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      // Start typing "hat" after C
                                      return AnimatedTextKit(
                                        key: ValueKey('chat'),
                                        animatedTexts: [
                                          TypewriterAnimatedText(
                                            'Chat',
                                            textStyle: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 1.5,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.3),
                                                  offset: const Offset(2, 2),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            speed: const Duration(
                                              milliseconds: 100,
                                            ),
                                            cursor: '|',
                                          ),
                                        ],
                                        totalRepeatCount: 1,
                                        displayFullTextOnTap: false,
                                        isRepeatingAnimation: false,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 50),

                  // Loading indicator
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textController.value,
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
