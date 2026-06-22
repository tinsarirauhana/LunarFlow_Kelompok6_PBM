import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../services/cycle_service.dart';
import '../main_scaffold.dart';

class InputDataPage extends StatefulWidget {
  final String? name;
  const InputDataPage({super.key, this.name});

  @override
  State<InputDataPage> createState() => _InputDataPageState();
}

class _InputDataPageState extends State<InputDataPage> {
  late TextEditingController _nameController;
  final _cycleLengthController = TextEditingController(text: '28');
  final _periodDurationController = TextEditingController(text: '5');
  final _cycleService = CycleService();

  DateTime? _selectedDate;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name ?? '');
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
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 180)),
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Nama tidak boleh kosong.');
      return;
    }
    if (_selectedDate == null) {
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
        lastPeriodDate: _selectedDate!,
        cycleLength: int.tryParse(_cycleLengthController.text) ?? 28,
        periodDuration: int.tryParse(_periodDurationController.text) ?? 5,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Gagal menyimpan data. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding3.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE8A0B4), AppTheme.primary],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(color: AppTheme.primary.withOpacity(0.30)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  Text(
                    'LunarFlow',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pantau siklus haid kamu dengan mudah.',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Nama
                  _buildLabel('Nama kamu'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: const InputDecoration(hintText: 'Siti Rahayu'),
                  ),
                  const SizedBox(height: 16),

                  // Tanggal haid terakhir
                  _buildLabel('Tanggal pertama haid terakhir'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate != null
                                ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                                : 'dd/mm/yyyy',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: _selectedDate != null
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

                  // Panjang siklus
                  _buildLabel('Panjang siklus rata-rata (hari)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _cycleLengthController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: const InputDecoration(hintText: '28'),
                  ),
                  const SizedBox(height: 16),

                  // Durasi haid
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
                          color: Colors.red[200], fontSize: 13),
                    ),
                  ],

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)
                          : Text(
                              'Mulai Sekarang',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
