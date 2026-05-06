import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'home_screen.dart';
import 'database_screen.dart';
import 'banding_screen.dart';
import 'profil_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

const Color primaryColor   = Color(0xFF283593); // Indigo Tua
const Color secondaryColor = Color(0xFF3949AB); // Indigo Medium
const Color accentColor    = Color(0xFFFFC107); // Amber/Kuning Emas
const Color surfaceColor   = Color(0xFFE8EAF6); // Indigo Sangat Muda
const Color bgColor        = Color(0xFFF5F5F5); // Abu Muda
const Color dangerColor    = Color(0xFFD32F2F); // Merah
const Color warningColor   = Color(0xFFF57C00); // Oranye

// GlobalKey untuk mengakses MainScreenState agar dapat mengontrol navigasi antar tab
final GlobalKey<MainScreenState> mainScreenKey = GlobalKey<MainScreenState>();

void main() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CariKampus',
      theme: ThemeData(
        scaffoldBackgroundColor: bgColor,
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: primaryColor,
          secondary: accentColor,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: mainScreenKey);

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<int> _history = [0];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _history.add(index);
        _selectedIndex = index;
      });
    }
  }

  void goBack() {
    if (_history.length > 1) {
      setState(() {
        _history.removeLast();
        _selectedIndex = _history.last;
      });
    }
  }

  void goHome() {
    if (_selectedIndex != 0) {
      setState(() {
        _history.add(0);
        _selectedIndex = 0;
      });
    }
  }

  void _navigateToHome() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      const HomeScreen(),
      DatabaseScreen(onHomeTapped: _navigateToHome),
      BandingScreen(onHomeTapped: _navigateToHome),
      ProfilScreen(onHomeTapped: _navigateToHome),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: primaryColor,
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Database',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.compare_arrows),
            label: 'Banding',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
