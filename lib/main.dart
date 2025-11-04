
import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'models/outfit.dart';
import 'models/image_library.dart';
import 'services/storage.dart';
import 'screens/login_page.dart';
import 'services/user_service.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppState appState = AppState();
  final ImageLibraryState imageLibraryState = ImageLibraryState();
  final StorageService storage = StorageService();
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    appState.addListener(_save);
    imageLibraryState.addListener(_save);
    _load();

    // Optional sample call to verify backend connectivity
    final userService = UserService();
    userService.registerUser(
      name: "Test User",
      email: "test@example.com",
      password: "12345678",
    );
  }


  Future<void> _load() async {
    final (outfits, images) = await storage.loadState();
    appState.value = outfits;
    imageLibraryState.value = images;
    setState(() {
      _loaded = true;
    });
  }

  Future<void> _save() async {
    await storage.saveState(outfits: appState.value, images: imageLibraryState.value);
  }

  @override
  void dispose() {
    appState.removeListener(_save);
    imageLibraryState.removeListener(_save);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kombin Oluşturucu',
      navigatorKey: _navKey,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF5F5F0), // Light beige
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F0), // Light beige background
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFF5F5F0),
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.black.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          labelStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
          hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 12);
            }
            return const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.black, size: 24);
            }
            return const IconThemeData(color: Color(0xFF9E9E9E), size: 24);
          }),
          elevation: 0,
          height: 70,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.black, letterSpacing: -0.5),
          titleMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF5A5A5A)),
        ),
      ),
      home: _loaded
          ? LoginPage(
              onSuccess: () {
                _navKey.currentState?.pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => HomePage(
                      appState: appState,
                      imageLibraryState: imageLibraryState,
                    ),
                  ),
                );
              },
            )
          : const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
