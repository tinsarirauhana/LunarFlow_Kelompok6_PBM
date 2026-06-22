import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../services/cycle_service.dart';

class EditProfilePage extends StatefulWidget {
  final CycleData? cycleData;
  const EditProfilePage({super.key, this.cycleData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _cycleService = CycleService();
  late TextEditingController _nameController;
  late TextEditingController _cycleLengthController;
  late TextEditingController _periodDurationController;
  DateTime? _lastPeriodDate;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.cycleData?.name ?? '');
    _cycleLengthController = TextEditingController(
        text: '${widget.cycleData?.cycleLength ?? 28}');
    _periodDurationController = TextEditingController(
        text: '${widget.cycleData?.periodDuration ?? 5}');
    _lastPeriodDate = widget.cycleData?.lastPeriodDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cycleLengthController.dispose();
    _periodDurationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _lastPeriodDate = picked);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Nama tidak boleh kosong.');
      return;
    }
    if (_lastPeriodDate == null) {
      setState(() => _errorMessage = 'Pilih tanggal haid terakhir.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _cycleService.saveInitialData(
        name: _nameController.text.trim(),
        lastPeriodDate: _lastPeriodDate!,
        cycleLength: int.tryParse(_cycleLengthController.text) ?? 28,
        periodDuration: int.tryParse(_periodDurationController.text) ?? 5,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Gagal menyimpan. Coba lagi.');
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
                'Edit Profil',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 28),

              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primary.withOpacity(0.1),
                      ),
                      child: const Icon(Icons.person,
                          color: AppTheme.primary, size: 44),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_outlined,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              _buildLabel('Nama'),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: const InputDecoration(hintText: 'Nama kamu'),
              ),
              const SizedBox(height: 16),

              _buildLabel('Tanggal pertama haid terakhir'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _lastPeriodDate != null
                            ? DateFormat('dd/MM/yyyy')
                                .format(_lastPeriodDate!)
                            : 'dd/mm/yyyy',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _lastPeriodDate != null
                              ? AppTheme.textDark
                              : AppTheme.textLight,
                        ),
                      ),
                      const Icon(Icons.calendar_today_outlined,
                          color: AppTheme.primary, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Panjang siklus rata-rata (hari)'),
              const SizedBox(height: 8),
              TextField(
                controller: _cycleLengthController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: const InputDecoration(hintText: '28'),
              ),
              const SizedBox(height: 16),

              _buildLabel('Durasi haid biasanya (hari)'),
              const SizedBox(height: 8),
              TextField(
                controller: _periodDurationController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: const InputDecoration(hintText: '5'),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: GoogleFonts.poppins(
                      color: Colors.red[400], fontSize: 13),
                ),
              ],

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : Text('Simpan Perubahan',
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: AppTheme.textDark,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
