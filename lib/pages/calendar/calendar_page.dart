import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../services/cycle_service.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  final _cycleService = CycleService();
  CycleData? _cycleData;
  bool _isLoading = true;
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  // key: 'yyyy-MM-dd' -> log map
  Map<String, Map<String, dynamic>> _logsByDate = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  /// Dipanggil dari luar (mis. setelah kembali dari halaman Catat) untuk refresh data.
  Future<void> refresh() => _fetchData();

  Future<void> _fetchData() async {
    try {
      final data = await _cycleService.fetchUserCycle();
      final logs = await _cycleService.fetchLogs();

      final logMap = <String, Map<String, dynamic>>{};
      for (final log in logs) {
        final dateStr = log['log_date'] as String; // yyyy-MM-dd
        logMap[dateStr] = log;
      }

      if (!mounted) return;
      setState(() {
        _cycleData = data;
        _logsByDate = logMap;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String _dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  bool _hasLog(DateTime date) => _logsByDate.containsKey(_dateKey(date));

  bool _isPeriodDay(DateTime date) {
    if (_cycleData == null) return false;
    final start = _cycleData!.lastPeriodDate;
    final end = start.add(Duration(days: _cycleData!.periodDuration));
    return !date.isBefore(start) && date.isBefore(end);
  }

  bool _isNextPeriodDay(DateTime date) {
    if (_cycleData == null) return false;
    final start = _cycleData!.nextPeriodDate;
    final end = start.add(Duration(days: _cycleData!.periodDuration));
    return !date.isBefore(start) && date.isBefore(end);
  }

  bool _isFertileDay(DateTime date) {
    if (_cycleData == null) return false;
    return !date.isBefore(_cycleData!.fertileStart) &&
        !date.isAfter(_cycleData!.fertileEnd);
  }

  bool _isOvulationDay(DateTime date) {
    if (_cycleData == null) return false;
    final ov = _cycleData!.ovulationDate;
    return date.year == ov.year &&
        date.month == ov.month &&
        date.day == ov.day;
  }

  void _onDateTap(DateTime date) {
    final log = _logsByDate[_dateKey(date)];
    _showDayDetailSheet(date, log);
  }

  void _showDayDetailSheet(DateTime date, Map<String, dynamic>? log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Text(
              DateFormat('EEEE, d MMMM yyyy', 'id').format(date),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            if (log == null)
              _buildNoLogState()
            else
              _buildLogDetail(log),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildNoLogState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.event_note_outlined,
              size: 36, color: AppTheme.textLight),
          const SizedBox(height: 10),
          Text(
            'Belum ada catatan untuk\ntanggal ini.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogDetail(Map<String, dynamic> log) {
    final isMenstruating = log['is_menstruating'] as bool? ?? false;
    final flow = log['flow'] as String?;
    final symptoms = (log['symptoms'] as List?)?.cast<String>() ?? [];
    final note = log['note'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMenstruating) ...[
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.water_drop,
                        size: 14, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Text('Haid${flow != null ? ' • $flow' : ''}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        if (symptoms.isNotEmpty) ...[
          Text('Gejala',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              )),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: symptoms
                .map((s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Text(s,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textDark,
                          )),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
        if (note.isNotEmpty) ...[
          Text('Catatan',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              )),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(note,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppTheme.textMedium,
                  height: 1.4,
                )),
          ),
        ],
        if (!isMenstruating && symptoms.isEmpty && note.isEmpty)
          _buildNoLogState(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildCalendar(),
                    const SizedBox(height: 24),
                    _buildLegend(),
                    const SizedBox(height: 20),
                    _buildFertileCard(),
                    const SizedBox(height: 16),
                    _buildStatRow(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Kalender',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: AppTheme.textDark),
              onPressed: () => setState(() {
                _focusedMonth =
                    DateTime(_focusedMonth.year, _focusedMonth.month - 1);
              }),
            ),
            Text(
              DateFormat('MMMM yyyy', 'id').format(_focusedMonth),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: AppTheme.textDark),
              onPressed: () => setState(() {
                _focusedMonth =
                    DateTime(_focusedMonth.year, _focusedMonth.month + 1);
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    final today = DateTime.now();
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startOffset = (firstDay.weekday - 1) % 7;
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final headers = ['M', 'S', 'S', 'R', 'K', 'J', 'S'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: headers
                .map((d) => SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(d,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMedium,
                            )),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
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
              final date =
                  DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
              final isToday = date.day == today.day &&
                  date.month == today.month &&
                  date.year == today.year;
              final isPeriod = _isPeriodDay(date);
              final isNextPeriod = _isNextPeriodDay(date);
              final isFertile = _isFertileDay(date);
              final isOvulation = _isOvulationDay(date);
              final hasLog = _hasLog(date);

              Color? bgColor;
              Color textColor = AppTheme.textDark;
              bool hasBorder = false;

              if (isToday && isPeriod) {
                bgColor = AppTheme.primary;
                textColor = Colors.white;
              } else if (isToday) {
                bgColor = AppTheme.primary;
                textColor = Colors.white;
              } else if (isPeriod) {
                bgColor = AppTheme.primary;
                textColor = Colors.white;
              } else if (isNextPeriod) {
                bgColor = AppTheme.primary.withOpacity(0.25);
                textColor = AppTheme.primary;
              } else if (isOvulation) {
                bgColor = const Color(0xFF4CAF50).withOpacity(0.35);
                textColor = const Color(0xFF2E7D32);
              } else if (isFertile) {
                bgColor = const Color(0xFF4CAF50).withOpacity(0.18);
                textColor = const Color(0xFF2E7D32);
              }

              return GestureDetector(
                onTap: () => _onDateTap(date),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: bgColor,
                          shape: BoxShape.circle,
                          border: hasBorder
                              ? Border.all(color: AppTheme.primary, width: 1.5)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$dayNum',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (hasLog)
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Color(0xFF424242),
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(height: 5),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('KETERANGAN',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMedium,
              letterSpacing: 1,
            )),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _legendItem(AppTheme.primary, 'Haid')),
            Expanded(
                child: _legendItem(
                    AppTheme.primary.withOpacity(0.25), 'Prediksi Haid')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
                child: _legendItem(
                    const Color(0xFF4CAF50).withOpacity(0.18), 'Masa Subur')),
            Expanded(
                child: _legendItem(
                    const Color(0xFF4CAF50).withOpacity(0.35), 'Ovulasi')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _dotLegendItem('Ada Catatan')),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppTheme.textDark)),
        ],
      ),
    );
  }

  Widget _dotLegendItem(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF424242),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppTheme.textDark)),
        ],
      ),
    );
  }

  Widget _buildFertileCard() {
    if (_cycleData == null) return const SizedBox();
    final start = DateFormat('d', 'id').format(_cycleData!.fertileStart);
    final endFmt = DateFormat('d MMMM', 'id').format(_cycleData!.fertileEnd);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Masa Subur Berikutnya',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF2E7D32),
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 4),
                Text('$start – $endFmt',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B5E20),
                    )),
              ],
            ),
          ),
          const Icon(Icons.spa_outlined, color: Color(0xFF2E7D32), size: 32),
        ],
      ),
    );
  }

  Widget _buildStatRow() {
    if (_cycleData == null) return const SizedBox();
    return Row(
      children: [
        Expanded(
          child: _statCard(
            Icons.water_drop_outlined,
            'Lama Siklus',
            '${_cycleData!.cycleLength} Hari',
            const Color(0xFFFCE4EC),
            AppTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            Icons.auto_awesome,
            'Kesehatan',
            'Sangat Baik',
            const Color(0xFFE8F5E9),
            const Color(0xFF2E7D32),
          ),
        ),
      ],
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color bg,
      Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 24),
          const SizedBox(height: 8),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: accent, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: accent,
              )),
        ],
      ),
    );
  }
}