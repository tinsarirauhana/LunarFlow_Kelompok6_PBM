import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../services/cycle_service.dart';

class HealthConditionPage extends StatefulWidget {
  final String? initialCondition;
  const HealthConditionPage({super.key, this.initialCondition});

  @override
  State<HealthConditionPage> createState() => _HealthConditionPageState();
}

class _HealthConditionPageState extends State<HealthConditionPage> {
  final _cycleService = CycleService();
  late String _selectedCondition;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _conditions = [
    {
      'label': 'Normal',
      'icon': Icons.check_circle_outline_rounded,
    },
    {
      'label': 'PCOS',
      'icon': Icons.water_drop_outlined,
    },
    {
      'label': 'Endometriosis',
      'icon': Icons.healing_outlined,
    },
    {
      'label': 'Menopause',
      'icon': Icons.wb_sunny_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedCondition = widget.initialCondition ?? 'Normal';
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      await _cycleService.saveHealthCondition(_selectedCondition);
      if (!mounted) return;
      Navigator.of(context).pop(_selectedCondition);
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: AppTheme.primary,
                ),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                label: Text('Kembali',
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 16),
              Text(
                'Kondisi Kesehatan',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pilih kondisi Anda saat ini.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textMedium,
                ),
              ),
              const SizedBox(height: 24),

              ..._conditions.map((c) {
                final label = c['label'] as String;
                final isSelected = _selectedCondition == label;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCondition = label),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primary
                              : const Color(0xFFEEEEEE),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(c['icon'] as IconData,
                                color: AppTheme.primary, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(label,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                )),
                          ),
                          Radio<String>(
                            value: label,
                            groupValue: _selectedCondition,
                            onChanged: (v) =>
                                setState(() => _selectedCondition = v!),
                            activeColor: AppTheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : Text('Simpan',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
