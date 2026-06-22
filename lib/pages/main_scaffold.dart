import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import 'home/home_page.dart';
import 'calendar/calendar_page.dart';
import 'log/log_page.dart';
import 'prediction/prediction_page.dart';
import 'profile/profile_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  final _calendarKey = GlobalKey<CalendarPageState>();

  void _onNavTap(int index) {
    if (index == 2) return; // FAB handles this
    setState(() => _selectedIndex = index);
  }

  Future<void> _openLogPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LogPage()),
    );
    // Refresh kalender setelah kembali dari halaman Catat,
    // supaya titik indikator catatan langsung muncul.
    _calendarKey.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex == 2 ? 0 : _selectedIndex,
        children: [
          const HomePage(),
          CalendarPage(key: _calendarKey),
          const SizedBox(),
          const PredictionPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, 'Beranda'),
              _navItem(1, Icons.calendar_month_outlined, 'Kalender'),
              const SizedBox(width: 48),
              _navItem(3, Icons.bar_chart_rounded, 'Prediksi'),
              _navItem(4, Icons.person_outline_rounded, 'Profil'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openLogPage,
        backgroundColor: AppTheme.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.primary : AppTheme.textLight,
            size: 22,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: isSelected ? AppTheme.primary : AppTheme.textLight,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}