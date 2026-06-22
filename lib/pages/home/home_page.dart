import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../services/cycle_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _cycleService = CycleService();
  CycleData? _cycleData;
  bool _isLoading = true;
  bool _isWeeklyView = true;
  DateTime _focusedDate = DateTime.now();
  late Future<void> _fetchFuture;

  @override
  void initState() {
    super.initState();
    _fetchFuture = _fetchData();
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildCalendarSection(),
                    const SizedBox(height: 20),
                    _buildCountdownSection(),
                    const SizedBox(height: 16),
                    _buildPhaseSection(),
                    const SizedBox(height: 20),
                    _buildStatCards(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  // ─── Header ───────────────────────────────────────────────
  Widget _buildHeader() {
    final name = _cycleData?.name.split(' ').first ?? 'Teman';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, $name',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          Text(
            'Semoga harimu menyenangkan!',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Calendar Section ────────────────────────────────────
  Widget _buildCalendarSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          // Month header + toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    DateFormat('MMMM', 'id').format(_focusedDate),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _focusedDate.year.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              _buildViewToggle(),
            ],
          ),
          const SizedBox(height: 12),
          _isWeeklyView ? _buildWeeklyCalendar() : _buildMonthlyCalendar(),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleButton('Mingguan', true),
          _toggleButton('Bulanan', false),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool isWeekly) {
    final isSelected = _isWeeklyView == isWeekly;
    return GestureDetector(
      onTap: () => setState(() => _isWeeklyView = isWeekly),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textMedium,
          ),
        ),
      ),
    );
  }

  // Weekly: 7 hari dari Senin minggu ini
  Widget _buildWeeklyCalendar() {
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final days = List.generate(7, (i) => monday.add(Duration(days: i)));
    final idDayLabels = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = days[i];
        final isToday = day.day == today.day &&
            day.month == today.month &&
            day.year == today.year;
        final isPeriodDay = _cycleData != null &&
            day.isAfter(_cycleData!.lastPeriodDate
                .subtract(const Duration(days: 1))) &&
            day.isBefore(_cycleData!.lastPeriodDate
                .add(Duration(days: _cycleData!.periodDuration)));

        return Column(
          children: [
            Text(
              idDayLabels[i],
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppTheme.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isToday ? AppTheme.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: isPeriodDay && !isToday
                    ? Border.all(color: AppTheme.primary, width: 1.5)
                    : null,
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight:
                        isToday ? FontWeight.bold : FontWeight.w500,
                    color: isToday ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // Monthly: full calendar grid
  Widget _buildMonthlyCalendar() {
    final today = DateTime.now();
    final firstDay = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final startOffset = (firstDay.weekday - 1) % 7;
    final daysInMonth =
        DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;

    final idDayHeaders = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];

    return Column(
      children: [
        // Day headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: idDayHeaders
              .map((d) => SizedBox(
                    width: 36,
                    child: Center(
                      child: Text(
                        d,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: startOffset + daysInMonth,
          itemBuilder: (context, index) {
            if (index < startOffset) return const SizedBox();
            final dayNum = index - startOffset + 1;
            final date = DateTime(_focusedDate.year, _focusedDate.month, dayNum);
            final isToday = date.day == today.day &&
                date.month == today.month &&
                date.year == today.year;
            final isPeriodDay = _cycleData != null &&
                !date.isBefore(_cycleData!.lastPeriodDate) &&
                date.isBefore(_cycleData!.lastPeriodDate
                    .add(Duration(days: _cycleData!.periodDuration)));
            final isNextPeriod = _cycleData != null &&
                !date.isBefore(_cycleData!.nextPeriodDate) &&
                date.isBefore(_cycleData!.nextPeriodDate
                    .add(Duration(days: _cycleData!.periodDuration)));

            Color? bgColor;
            Color textColor = AppTheme.textDark;
            if (isToday) {
              bgColor = AppTheme.primary;
              textColor = Colors.white;
            } else if (isPeriodDay || isNextPeriod) {
              bgColor = AppTheme.primary.withOpacity(0.15);
              textColor = AppTheme.primary;
            }

            return Center(
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$dayNum',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight:
                          isToday ? FontWeight.bold : FontWeight.normal,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ─── Countdown ────────────────────────────────────────────
  Widget _buildCountdownSection() {
    if (_isWeeklyView) return _buildWeeklyCountdown();
    return _buildMonthlyCountdown();
  }

  Widget _buildWeeklyCountdown() {
    final days = _cycleData?.daysUntilNextPeriod ?? 0;
    return Center(
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primary, width: 2.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$days Hari',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            Text(
              'Lagi',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'MENUJU HAID',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppTheme.textMedium,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyCountdown() {
    final days = _cycleData?.daysUntilNextPeriod ?? 0;
    final cycleDay = _cycleData?.currentCycleDay ?? 0;
    final cycleLength = _cycleData?.cycleLength ?? 28;
    final progress = cycleLength > 0 ? cycleDay / cycleLength : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ESTIMASI\nKEDATANGAN',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textMedium,
                    letterSpacing: 0.5,
                  ),
                ),
                const Icon(Icons.water_drop_outlined,
                    color: AppTheme.primary, size: 22),
              ],
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$days ',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  TextSpan(
                    text: 'Hari Lagi',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Menuju periode berikutnya',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textMedium,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: const Color(0xFFEED5DC),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _cycleData?.cyclePhase ?? 'FASE FOLIKULER',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: AppTheme.textMedium),
                    const SizedBox(width: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Hari $cycleDay',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                          TextSpan(
                            text: '/$cycleLength',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Phase badge (weekly view only) ──────────────────────
  Widget _buildPhaseSection() {
    if (!_isWeeklyView) return const SizedBox();
    return Center(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              _cycleData?.cyclePhase ?? 'FASE FOLIKULER',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Stat Cards ───────────────────────────────────────────
  Widget _buildStatCards() {
    final cycleLength = _cycleData?.cycleLength ?? 28;
    final duration = _cycleData?.periodDuration ?? 7;
    final cycleDay = _cycleData?.currentCycleDay ?? 12;
    final totalCycle = _cycleData?.cycleLength ?? 28;

    final stats = [
      _StatItem(
        icon: Icons.loop_rounded,
        label: 'SIKLUS',
        value: '$cycleLength',
        unit: 'hr',
      ),
      _StatItem(
        icon: Icons.timer_outlined,
        label: 'DURASI',
        value: '$duration',
        unit: 'hr',
      ),
      _StatItem(
        icon: Icons.calendar_month_outlined,
        label: 'HARI KE',
        value: '$cycleDay',
        unit: '/$totalCycle',
        unitSmall: true,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: stats
            .map((s) => Expanded(child: _buildStatCard(s)))
            .toList(),
      ),
    );
  }

  Widget _buildStatCard(_StatItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(item.icon, color: AppTheme.primary, size: 22),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppTheme.textLight,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: item.value,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                TextSpan(
                  text: item.unit,
                  style: GoogleFonts.poppins(
                    fontSize: item.unitSmall ? 11 : 13,
                    color: AppTheme.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final bool unitSmall;

  _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    this.unitSmall = false,
  });
}