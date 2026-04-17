import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/View/Connecter/View/connect.dart';
import 'package:onyfast/View/inscrit.dart';
import 'package:onyfast/View/menuscreen.dart';
import 'package:onyfast/Widget/container.dart';
import '../Color/app_color_model.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color lightBlue = Color(0xFF3B82F6);
  static const Color orange = Color(0xFFF97316);
  static const Color red = Color(0xFFEF4444);
  static const Color green = Color(0xFF10B981);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color grey = Color(0xFF6B7280);
  static const Color lightGrey = Color(0xFFF3F4F6);
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _buttonController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _descriptionFadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;
  late Animation<double> _buttonFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Controller pour le logo
    _logoController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    // Controller pour le texte
    _textController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    // Controller pour les boutons
    _buttonController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    // Animations du logo
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Animations du titre
    _titleSlideAnimation = Tween<Offset>(
      begin: Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    // Animation de la description
    _descriptionFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    // Animations des boutons
    _buttonSlideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeOut,
      ),
    );

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeIn,
      ),
    );

    // Démarrer les animations en séquence
    _startAnimations();
  }

  void _startAnimations() async {
    await _logoController.forward();
    await _textController.forward();
    await _buttonController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? size.width * 0.15 : size.width * 0.08,
              ),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    maxWidth: isTablet ? 500 : double.infinity,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(
                            height: isSmallScreen
                                ? size.height * 0.05
                                : size.height * 0.1),

                        // Logo avec animation
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _logoFadeAnimation.value,
                              child: Transform.scale(
                                scale: _logoScaleAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: CupertinoColors.transparent,
                                    border: Border.all(
                                        color: CupertinoColors.white, width: 2),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                        isSmallScreen ? 12.dp : 17.dp),
                                    child: Container(
                                      width: isSmallScreen
                                          ? size.width * 0.3
                                          : size.width * 0.4,
                                      height: isSmallScreen
                                          ? size.width * 0.3
                                          : size.width * 0.4,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: CupertinoColors.white,
                                        border: Border.all(
                                            color: CupertinoColors.white,
                                            width: 2),
                                      ),
                                      child: Center(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.dp),
                                          child: Image.asset(
                                            "asset/onylogo.png",
                                            height: isSmallScreen
                                                ? size.width * 0.25
                                                : size.width * 0.3,
                                            width: isSmallScreen
                                                ? size.width * 0.28
                                                : size.width * 0.35,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(
                            height: isSmallScreen
                                ? size.height * 0.03
                                : size.height * 0.05),

                        // Titre avec animation
                        AnimatedBuilder(
                          animation: _textController,
                          builder: (context, child) {
                            return SlideTransition(
                              position: _titleSlideAnimation,
                              child: FadeTransition(
                                opacity: _titleFadeAnimation,
                                child: Text(
                                  'Onyfast',
                                  style: TextStyle(
                                    fontSize: isTablet
                                        ? 48
                                        : (isSmallScreen
                                            ? size.width * 0.1
                                            : size.width * 0.12),
                                    fontWeight: FontWeight.bold,
                                    color: CupertinoColors.white,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(
                            height: isSmallScreen
                                ? size.height * 0.02
                                : size.height * 0.03),

                        // Description avec animation
                        AnimatedBuilder(
                          animation: _textController,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _descriptionFadeAnimation,
                              child: Text(
                                'Faites vos dépôts et retraits, effectuez vos paiements en ligne et en magasin en sécurité avec Onyfast.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: isTablet
                                      ? 16
                                      : 12.sp,
                                  color: CupertinoColors.white.withOpacity(0.8),
                                  height: 1.5,
                                ),
                              ),
                            );
                          },
                        ),

                        Spacer(),

                        AnimatedBuilder(
                          animation: _buttonController,
                          builder: (context, child) {
                            return SlideTransition(
                              position: _buttonSlideAnimation,
                              child: FadeTransition(
                                opacity: _buttonFadeAnimation,
                                child: Column(
                                  children: [
                                    // Question
                                    Text(
                                      'Vous n\'avez pas de compte ?',
                                      style: TextStyle(
                                        decoration: TextDecoration.none,
                                        fontSize: isTablet
                                            ? 16
                                            : 12.sp,
                                        color: CupertinoColors.white,
                                      ),
                                    ),

                                    SizedBox(
                                        height: isSmallScreen
                                            ? size.height * 0.02
                                            : size.height * 0.03),

                                    // Bouton inscription avec bordure
                                    SizedBox(
                                      width: double.infinity,
                                      height: isSmallScreen
                                          ? 50
                                          : size.height * 0.07,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColors.lightBlue,
                                            width: 1.5,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: CupertinoButton(
                                          color: Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                          onPressed: () =>
                                              Get.to(() => Inscrit()),
                                          child: Text(
                                            'Inscrivez-vous',
                                            style: TextStyle(
                                              decoration: TextDecoration.none,
                                              fontSize: isTablet
                                                  ? 16
                                                  : 12.sp,
                                              color: CupertinoColors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: size.height * 0.02),

                                    // Bouton connexion
                                    SizedBox(
                                      width: double.infinity,
                                      height: isSmallScreen
                                          ? 50
                                          : size.height * 0.07,
                                      child: CupertinoButton(
                                        color: AppColors.lightBlue,
                                        borderRadius: BorderRadius.circular(12),
                                        onPressed: () =>
                                            Get.to(() => Connect()),
                                        child: Text(
                                          'Connexion',
                                          style: TextStyle(
                                            decoration: TextDecoration.none,
                                            fontSize: isTablet
                                                ? 16
                                                : 12.sp,
                                            color: CupertinoColors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(
                            height: isSmallScreen
                                ? size.height * 0.03
                                : size.height * 0.05),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
