import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Widget/alerte.dart';

// Controller pour gérer le thème
class ThemeController extends GetxController {
  final GetStorage _storage = GetStorage();
  final _themeMode = 'system'.obs; // 'light', 'dark', 'system'

  String get themeMode => _themeMode.value;

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }

  void _loadThemeMode() {
    _themeMode.value = _storage.read('theme_mode') ?? 'system';
    _applyTheme();
  }

  void setThemeMode(String mode) {
    _themeMode.value = mode;
    _storage.write('theme_mode', mode);
    _applyTheme();
    
    String message = '';
    switch (mode) {
      case 'light':
        message = 'Mode clair activé';
        break;
      case 'dark':
        message = 'Mode sombre activé';
        break;
      case 'system':
        message = 'Mode système activé';
        break;
    }
    SnackBarService.success(message);
  }

  void _applyTheme() {
    switch (_themeMode.value) {
      case 'light':
        Get.changeThemeMode(ThemeMode.light);
        break;
      case 'dark':
        Get.changeThemeMode(ThemeMode.dark);
        break;
      case 'system':
        Get.changeThemeMode(ThemeMode.system);
        break;
    }
  }

  ThemeMode getCurrentThemeMode() {
    switch (_themeMode.value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

class ThemeModePage extends StatelessWidget {
  final Color globalColor = Color(0xFF1E3A8A);
  final ThemeController themeController = Get.put(ThemeController());

  ThemeModePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        backgroundColor: globalColor,
        leading: BackButton(color: Colors.white),
        title: Text(
          "Apparence",
          style: TextStyle(
            fontSize: isSmallScreen ? 14.sp : 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Obx(() => Column(
          children: [
            // En-tête avec illustration
            _buildHeader(screenWidth, screenHeight, isSmallScreen, isDarkMode),
            
            SizedBox(height: screenHeight * 0.03),

            // Options de thème
            _buildThemeOptions(screenWidth, screenHeight, isSmallScreen, isDarkMode),
            
            SizedBox(height: screenHeight * 0.02),

            // Aperçu du thème actuel
            _buildThemePreview(screenWidth, screenHeight, isSmallScreen, isDarkMode),
            
            SizedBox(height: screenHeight * 0.02),

            // Informations
            _buildInfo(screenWidth, screenHeight, isSmallScreen, isDarkMode),
          ],
        )),
      ),
    );
  }

  Widget _buildHeader(double screenWidth, double screenHeight, bool isSmallScreen, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
              ? Colors.black.withOpacity(0.3)
              : Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icône animée
          Container(
            width: screenWidth * (isSmallScreen ? 0.25 : 0.22),
            height: screenWidth * (isSmallScreen ? 0.25 : 0.22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  globalColor.withOpacity(0.2),
                  globalColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.brightness_6,
                  size: screenWidth * (isSmallScreen ? 0.12 : 0.11),
                  color: globalColor,
                ),
              ],
            ),
          ),
          
          SizedBox(height: screenHeight * 0.02),
          
          Text(
            'Personnalisez votre thème',
            style: TextStyle(
              fontSize: isSmallScreen ? 18.sp : 20.sp,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          
          SizedBox(height: screenHeight * 0.01),
          
          Text(
            'Choisissez le mode d\'affichage qui vous convient le mieux',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 12.sp : 13.sp,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOptions(double screenWidth, double screenHeight, bool isSmallScreen, bool isDarkMode) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
              ? Colors.black.withOpacity(0.3)
              : Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildThemeOption(
            icon: Icons.light_mode,
            title: 'Mode clair',
            description: 'Thème lumineux pour une utilisation de jour',
            value: 'light',
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            isSmallScreen: isSmallScreen,
            isDarkMode: isDarkMode,
            index: 0,
            totalItems: 3,
          ),
          _buildThemeOption(
            icon: Icons.dark_mode,
            title: 'Mode sombre',
            description: 'Thème sombre pour réduire la fatigue oculaire',
            value: 'dark',
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            isSmallScreen: isSmallScreen,
            isDarkMode: isDarkMode,
            index: 1,
            totalItems: 3,
          ),
          _buildThemeOption(
            icon: Icons.settings_brightness,
            title: 'Mode système',
            description: 'Suit automatiquement les paramètres de votre appareil',
            value: 'system',
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            isSmallScreen: isSmallScreen,
            isDarkMode: isDarkMode,
            index: 2,
            totalItems: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String title,
    required String description,
    required String value,
    required double screenWidth,
    required double screenHeight,
    required bool isSmallScreen,
    required bool isDarkMode,
    required int index,
    required int totalItems,
  }) {
    final isSelected = themeController.themeMode == value;

    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => themeController.setThemeMode(value),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected 
                  ? globalColor.withOpacity(0.05)
                  : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Icône avec container stylé
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? globalColor.withOpacity(0.15)
                        : (isDarkMode ? Colors.grey[800] : globalColor.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? globalColor : (isDarkMode ? Colors.grey[400] : globalColor),
                      size: 24,
                    ),
                  ),

                  SizedBox(width: 15),

                  // Texte
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14.sp : 16.sp,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected 
                              ? globalColor 
                              : (isDarkMode ? Colors.white : Colors.black87),
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11.sp : 12.sp,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            decoration: TextDecoration.none,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 10),

                  // Indicateur de sélection
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? globalColor : (isDarkMode ? Colors.grey[600]! : Colors.grey[400]!),
                        width: 2,
                      ),
                      color: isSelected ? globalColor : Colors.transparent,
                    ),
                    child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Divider
        if (index < totalItems - 1)
          Container(
            height: 0.5,
            margin: EdgeInsets.symmetric(horizontal: 32),
            color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
          ),
      ],
    );
  }

  Widget _buildThemePreview(double screenWidth, double screenHeight, bool isSmallScreen, bool isDarkMode) {
    String currentMode = themeController.themeMode;
    String previewText = '';
    IconData previewIcon = Icons.brightness_6;
    
    switch (currentMode) {
      case 'light':
        previewText = 'Thème clair actif';
        previewIcon = Icons.light_mode;
        break;
      case 'dark':
        previewText = 'Thème sombre actif';
        previewIcon = Icons.dark_mode;
        break;
      case 'system':
        previewText = 'Mode système actif';
        previewIcon = Icons.settings_brightness;
        break;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            globalColor.withOpacity(0.1),
            globalColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: globalColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: globalColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              previewIcon,
              color: globalColor,
              size: 28,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aperçu actuel',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11.sp : 12.sp,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  previewText,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 15.sp : 16.sp,
                    fontWeight: FontWeight.w600,
                    color: globalColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: globalColor,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(double screenWidth, double screenHeight, bool isSmallScreen, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800]?.withOpacity(0.5) : Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            size: isSmallScreen ? 24 : 28,
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            'À propos du thème',
            style: TextStyle(
              fontSize: isSmallScreen ? 13.sp : 14.sp,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            '• Mode clair : Idéal pour une utilisation en journée\n'
            '• Mode sombre : Réduit la fatigue oculaire le soir\n'
            '• Mode système : Change automatiquement selon l\'heure',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: isSmallScreen ? 11.sp : 12.sp,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// CONFIGURATION DANS main.dart
// ============================================

/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  
  final ThemeController themeController = Get.put(ThemeController());
  
  runApp(MyApp(themeController: themeController));
}

class MyApp extends StatelessWidget {
  final ThemeController themeController;
  
  const MyApp({Key? key, required this.themeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Onyfast',
          
          // Thèmes
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Color(0xFF1E3A8A),
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: AppBarTheme(
              backgroundColor: Color(0xFF1E3A8A),
              elevation: 0,
            ),
            // ... autres configurations du thème clair
          ),
          
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Color(0xFF1E3A8A),
            scaffoldBackgroundColor: Colors.grey[900],
            appBarTheme: AppBarTheme(
              backgroundColor: Color(0xFF1E3A8A),
              elevation: 0,
            ),
            cardColor: Colors.grey[850],
            // ... autres configurations du thème sombre
          ),
          
          themeMode: themeController.getCurrentThemeMode(),
          
          home: YourHomePage(),
        ));
      },
    );
  }
}
*/