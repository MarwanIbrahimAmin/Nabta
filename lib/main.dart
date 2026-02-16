import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'l10n/app_ar.dart';
import 'theme/app_colors.dart';
import 'screens/dashboard_screen.dart';
import 'screens/smart_reports_screen.dart';
import 'screens/timeline_screen.dart';
import 'screens/geo_map_screen.dart';

/// Nabta - Client portal for farmers to view soil reports from labs.
void main() {
  runApp(const NabtaApp());
}

class NabtaApp extends StatelessWidget {
  const NabtaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppAr.appTitle,
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [Locale('ar', 'EG')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.agriGreen,
          primary: AppColors.agriGreen,
          secondary: AppColors.earthBrown,
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.agriGreen,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: AppColors.agriGreen,
          unselectedItemColor: AppColors.earthBrown,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    DashboardScreen(),
    SmartReportsScreen(),
    TimelineScreen(),
    GeoMapScreen(),
  ];

  void _onTabTapped(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppAr.appTitle),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.layoutDashboard),
              label: AppAr.navDashboardLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.fileBarChart),
              label: AppAr.navSmartReportsLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.history),
              label: AppAr.navTimelineLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.map),
              label: AppAr.navGeoMapLabel,
            ),
          ],
        ),
      ),
    );
  }
}
