import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../services/cycle_service.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final _cycleService = CycleService();
  bool _isMenstruating = true;
  String _selectedFlow = 'Flek';
  final Set<String> _selectedSymptoms = {};
  final _noteController = TextEditingController();
  bool _isLoading = false;

  final List<String> _flowOptions = ['Flek', 'Ringan', 'Sedang', 'Deras'];
  final List<Map<String, dynamic>> _symptoms = [
    {'label': 'Kram', 'icon': Icons.accessibility_new_rounded},
    {'label': 'Sakit Kepala', 'icon': Icons.psychology_outlined},
    {'label': 'Kelelahan', 'icon': Icons.bedtime_outlined},
    {'label': 'Mood Swing', 'icon': Icons.sentiment_dissatisfied_outlined},
    {'label': 'Mual', 'icon': Icons.sick_outlined},
    {'label': 'Kembung', 'icon': Icons.add_circle_outline},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      await _cycleService.saveLog(
        date: DateTime.now(),
        isMenstruating: _isMenstruating,
        flow: _isMenstruating ? _selectedFlow : null,
        symptoms: _selectedSymptoms.toList(),
        note: _noteController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan tersimpan!',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan. Coba lagi.',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, d MMMM yyyy', 'id').format(DateTime.now());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFF5F8),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18, color: AppTheme.textDark),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Catat Haid',
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            )),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 14, color: AppTheme.textMedium),
                            const SizedBox(width: 6),
                            Text(today,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppTheme.textMedium,
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Toggle haid hari ini
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sedang haid hari ini?',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            )),
                        Switch(
                          value: _isMenstruating,
                          onChanged: (v) =>
                              setState(() => _isMenstruating = v),
                          activeColor: AppTheme.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Flow
                  if (_isMenstruating) ...[
                    Text('Tingkat Aliran',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        )),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _flowOptions.map((flow) {
                        final isSelected = _selectedFlow == flow;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedFlow = flow),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primary
                                    : const Color(0xFFEEEEEE),
                              ),
                            ),
                            child: Text(flow,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textDark,
                                )),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Gejala
                  Text('Gejala',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      )),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 3.2,
                    children: _symptoms.map((s) {
                      final label = s['label'] as String;
                      final isSelected = _selectedSymptoms.contains(label);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (isSelected) {
                            _selectedSymptoms.remove(label);
                          } else {
                            _selectedSymptoms.add(label);
                          }
                        }),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary.withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primary
                                  : const Color(0xFFEEEEEE),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(s['icon'] as IconData,
                                  size: 18,
                                  color: isSelected
                                      ? AppTheme.primary
                                      : AppTheme.textMedium),
                              const SizedBox(width: 8),
                              Text(label,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: isSelected
                                        ? AppTheme.primary
                                        : AppTheme.textDark,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  )),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Catatan
                  Text('Catatan Tambahan',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      )),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    maxLines: 4,
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Tuliskan apa yang kamu rasakan...',
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 13, color: AppTheme.textLight),
                      filled: true,
                      fillColor: const Color(0xFFFAFAFA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: Color(0xFFEEEEEE)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: Color(0xFFEEEEEE)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AppTheme.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)
                          : Text('Simpan Catatan',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              )),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}