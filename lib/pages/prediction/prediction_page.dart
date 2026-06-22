import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../services/cycle_service.dart';

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  final _cycleService = CycleService();
  CycleData? _cycleData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _cycleService.fetchUserCycle();
      if (!mounted) return;
      setState(() {
        _cycleData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primary))
            : _cycleData == null
                ? _buildEmptyState()
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'Prediksi',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCountdownCard(),
                        const SizedBox(height: 24),
                        _buildPhaseHeader(),
                        const SizedBox(height: 12),
                        _buildPhaseDetail(),
                        const SizedBox(height: 24),
                        _buildHistorySection(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bar_chart_rounded,
                size: 56, color: AppTheme.textLight),
            const SizedBox(height: 16),
            Text(
              'Belum ada data siklus',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Catat data haid kamu dulu untuk melihat prediksi siklus.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownCard() {
    final days = _cycleData!.daysUntilNextPeriod;
    final estimate =
        DateFormat('d MMMM yyyy', 'id').format(_cycleData!.nextPeriodDate);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryDark],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PREDIKSI SIKLUS MENDATANG',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white.withOpacity(0.85),
              letterSpacing: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            days >= 0
                ? 'Haid Berikutnya:\n$days Hari Lagi'
                : 'Haid mungkin\nsudah dimulai',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Text('Estimasi: $estimate',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Detail Fase Siklus',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.info_outline,
              color: AppTheme.textLight, size: 20),
          onPressed: _showPhaseInfoSheet,
        ),
      ],
    );
  }

  void _showPhaseInfoSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Detail Fase Siklus',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F5F5),
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Kenali perubahan tubuh Anda setiap fase.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppTheme.textMedium,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _phaseInfoCard(
                      number: '1',
                      icon: Icons.water_drop,
                      iconBg: const Color(0xFFFCE4EC),
                      iconColor: AppTheme.primary,
                      title: 'Menstruasi',
                      description:
                          'Fase peluruhan dinding rahim (endometrium) karena sel telur tidak dibuahi. Biasanya berlangsung 3–7 hari, ditandai dengan perubahan hormon yang menyebabkan rasa lemas atau kram perut.',
                    ),
                    const SizedBox(height: 14),
                    _phaseInfoCard(
                      number: '2',
                      icon: Icons.eco,
                      iconBg: const Color(0xFFE0F2F1),
                      iconColor: const Color(0xFF00897B),
                      title: 'Fase Folikuler',
                      description:
                          'Masa persiapan sel telur di ovarium. Kadar estrogen mulai meningkat, membuat Anda merasa lebih berenergi, fokus, dan kulit tampak lebih cerah.',
                    ),
                    const SizedBox(height: 14),
                    _phaseInfoCard(
                      number: '3',
                      icon: Icons.bolt,
                      iconBg: const Color(0xFFE0F2F1),
                      iconColor: const Color(0xFF00897B),
                      title: 'Ovulasi',
                      description:
                          'Masa subur utama ketika sel telur matang dilepaskan dari ovarium. Ini adalah waktu terbaik untuk peluang kehamilan, biasanya berlangsung 1–2 hari di tengah siklus.',
                    ),
                    const SizedBox(height: 14),
                    _phaseInfoCard(
                      number: '4',
                      icon: Icons.nightlight_round,
                      iconBg: const Color(0xFFEDE7F6),
                      iconColor: const Color(0xFF7B1FA2),
                      title: 'Fase Luteal',
                      description:
                          'Periode setelah ovulasi hingga menstruasi berikutnya. Hormon progesteron meningkat, kadang memicu gejala PMS seperti perubahan mood, payudara sensitif, dan keinginan makan tertentu.',
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Mengerti',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _phaseInfoCard({
    required String number,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$number. $title',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    )),
                const SizedBox(height: 4),
                Text(description,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppTheme.textMedium,
                      height: 1.4,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseDetail() {
    final lastPeriod = _cycleData!.lastPeriodDate;
    final periodEnd =
        lastPeriod.add(Duration(days: _cycleData!.periodDuration));
    final follicularEnd = _cycleData!.ovulationDate
        .subtract(const Duration(days: 1));
    final ovulationStart =
        _cycleData!.ovulationDate.subtract(const Duration(days: 1));
    final ovulationEnd =
        _cycleData!.ovulationDate.add(const Duration(days: 1));
    final lutealStart = ovulationEnd.add(const Duration(days: 1));
    final lutealEnd = _cycleData!.nextPeriodDate
        .subtract(const Duration(days: 1));

    final fmt = DateFormat('d MMM', 'id');

    return Column(
      children: [
        _phaseCard(
          icon: Icons.water_drop,
          iconBg: const Color(0xFFFCE4EC),
          iconColor: AppTheme.primary,
          label: 'MENSTRUASI',
          range: '${fmt.format(lastPeriod)} – ${fmt.format(periodEnd)}',
          labelColor: AppTheme.primary,
        ),
        const SizedBox(height: 10),
        _phaseCard(
          icon: Icons.eco,
          iconBg: const Color(0xFFFFF3E0),
          iconColor: const Color(0xFFEF6C00),
          label: 'FOLIKULER',
          range: '${fmt.format(periodEnd)} – ${fmt.format(follicularEnd)}',
          labelColor: const Color(0xFFEF6C00),
        ),
        const SizedBox(height: 10),
        _phaseCard(
          icon: Icons.favorite,
          iconBg: const Color(0xFFE0F2F1),
          iconColor: const Color(0xFF00897B),
          label: 'OVULASI',
          range: '${fmt.format(ovulationStart)} – ${fmt.format(ovulationEnd)}',
          labelColor: const Color(0xFF00897B),
        ),
        const SizedBox(height: 10),
        _phaseCard(
          icon: Icons.nightlight_round,
          iconBg: const Color(0xFFEDE7F6),
          iconColor: const Color(0xFF7B1FA2),
          label: 'LUTEAL',
          range: '${fmt.format(lutealStart)} – ${fmt.format(lutealEnd)}',
          labelColor: const Color(0xFF7B1FA2),
        ),
      ],
    );
  }

  Widget _phaseCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String range,
    required Color labelColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: iconBg.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconBg, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                    letterSpacing: 0.5,
                  )),
              const SizedBox(height: 2),
              Text(range,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat Siklus Sebelumnya',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              'Riwayat akan muncul setelah kamu\nmencatat beberapa siklus.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textLight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}