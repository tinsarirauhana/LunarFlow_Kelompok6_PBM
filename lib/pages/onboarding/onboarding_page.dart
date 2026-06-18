import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../auth/login_page.dart';
import '../auth/register_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Data tiap slide
  final List<_OnboardingData> _slides = [
    _OnboardingData(
      imagePath: 'assets/images/onboarding1.png',
      title: 'Halo Teman,\nLunarFlow!',
      titleBoldSecondLine: true,
      subtitle:
          'LunaFlow hadir untuk membantumu\nmemahami ritme tubuhmu dengan lebih baik.',
      isLastSlide: false,
    ),
    _OnboardingData(
      imagePath: 'assets/images/onboarding2.png',
      title: 'Prediksi Cerdas\nSetiap Bulan',
      titleBoldSecondLine: true,
      subtitle:
          'Berdasarkan data siklus kamu, LunaFlow\nmemprediksi kapan haid berikutnya!',
      isLastSlide: false,
    ),
    _OnboardingData(
      imagePath: 'assets/images/onboarding3.png',
      title: 'Sudah punya\nakun?',
      titleBoldSecondLine: false,
      subtitle:
          'Masuk atau daftar untuk mulai perjalanan\nmemahami siklus tubuhmu.',
      isLastSlide: true,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemCount: _slides.length,
        itemBuilder: (context, index) {
          final slide = _slides[index];
          return _OnboardingSlide(
            data: slide,
            currentPage: _currentPage,
            totalPages: _slides.length,
            onNext: _nextPage,
            onPrev: _prevPage,
            onSkip: _skip,
            onDaftar: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const RegisterPage()),
            ),
            onMasuk: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
          );
        },
      ),
    );
  }
}

class _OnboardingData {
  final String imagePath;
  final String title;
  final bool titleBoldSecondLine;
  final String subtitle;
  final bool isLastSlide;

  _OnboardingData({
    required this.imagePath,
    required this.title,
    required this.titleBoldSecondLine,
    required this.subtitle,
    required this.isLastSlide,
  });
}

class _OnboardingSlide extends StatelessWidget {
  final _OnboardingData data;
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback onSkip;
  final VoidCallback onDaftar;
  final VoidCallback onMasuk;

  const _OnboardingSlide({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onPrev,
    required this.onSkip,
    required this.onDaftar,
    required this.onMasuk,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            data.imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryLight.withOpacity(0.6),
                    AppTheme.primary,
                  ],
                ),
              ),
            ),
          ),
        ),
        // Pink overlay gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppTheme.primary.withOpacity(0.55),
                  AppTheme.primaryDark.withOpacity(0.85),
                ],
                stops: const [0.3, 0.65, 1.0],
              ),
            ),
          ),
        ),

        // Top bar: Kembali & Lewati
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentPage > 0)
                  GestureDetector(
                    onTap: onPrev,
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back_ios,
                            color: Colors.white, size: 16),
                        Text(
                          'Kembali',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox(),
                GestureDetector(
                  onTap: onSkip,
                  child: Row(
                    children: [
                      Text(
                        'Lewati',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom content
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                _buildTitle(data.title, data.titleBoldSecondLine),
                const SizedBox(height: 12),
                // Subtitle
                Text(
                  data.subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                // Buttons
                if (!data.isLastSlide)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Lanjut',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: onDaftar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Daftar',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: onMasuk,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Masuk',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Dots indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(totalPages, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == currentPage ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == currentPage
                            ? Colors.white
                            : Colors.white.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(String title, bool boldSecondLine) {
    final lines = title.split('\n');
    if (lines.length == 1 || !boldSecondLine) {
      return Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
      );
    }
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${lines[0]}\n',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: lines[1],
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
