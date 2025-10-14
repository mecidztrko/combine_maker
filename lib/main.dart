import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'models/outfit.dart';
import 'models/image_library.dart';
import 'services/storage.dart';
import 'screens/login_page.dart';

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
    _load();
    appState.addListener(_save);
    imageLibraryState.addListener(_save);
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
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F1113),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F1113),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF15181B),
          surfaceTintColor: Colors.white24,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF15181B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2A2F34)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2A2F34)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white70),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
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
