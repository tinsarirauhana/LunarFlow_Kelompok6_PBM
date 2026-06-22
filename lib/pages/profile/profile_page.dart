import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/cycle_service.dart';
import '../auth/login_page.dart';
import 'privacy_security_page.dart';
import 'health_condition_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();
  final _cycleService = CycleService();
  CycleData? _cycleData;
  bool _isLoading = true;
  bool _reminderEnabled = true;

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

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Keluar',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Apakah kamu yakin ingin keluar?',
            style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Batal',
                style: GoogleFonts.poppins(color: AppTheme.textMedium)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Keluar',
                style: GoogleFonts.poppins(
                    color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  Future<void> _editCycleLength() async {
    await _showNumberEditor(
      title: 'Panjang Siklus',
      suffix: 'Hari',
      initialValue: _cycleData?.cycleLength ?? 28,
      onSave: (value) async {
        await _cycleService.saveInitialData(
          name: _cycleData!.name,
          lastPeriodDate: _cycleData!.lastPeriodDate,
          cycleLength: value,
          periodDuration: _cycleData!.periodDuration,
        );
        _fetchData();
      },
    );
  }

  Future<void> _editPeriodDuration() async {
    await _showNumberEditor(
      title: 'Durasi Haid',
      suffix: 'Hari',
      initialValue: _cycleData?.periodDuration ?? 5,
      onSave: (value) async {
        await _cycleService.saveInitialData(
          name: _cycleData!.name,
          lastPeriodDate: _cycleData!.lastPeriodDate,
          cycleLength: _cycleData!.cycleLength,
          periodDuration: value,
        );
        _fetchData();
      },
    );
  }

  Future<void> _editHealthCondition() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) =>
            HealthConditionPage(initialCondition: _cycleData?.healthCondition),
      ),
    );
    if (result != null) _fetchData();
  }

  Future<void> _openEditProfile() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditProfilePage(cycleData: _cycleData),
      ),
    );
    if (result == true) _fetchData();
  }

  void _openPrivacySecurity() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PrivacySecurityPage()),
    );
  }

  Future<void> _showNumberEditor({
    required String title,
    required String suffix,
    required int initialValue,
    required Future<void> Function(int) onSave,
  }) async {
    if (_cycleData == null) return;
    final controller = TextEditingController(text: '$initialValue');
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(suffixText: suffix),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Batal',
                style: GoogleFonts.poppins(color: AppTheme.textMedium)),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.of(context).pop(value);
              }
            },
            child: Text('Simpan',
                style: GoogleFonts.poppins(
                    color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (result != null) {
      await onSave(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final name = _cycleData?.name ?? user?.email?.split('@').first ?? 'Pengguna';
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(name, email),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionCard(
                          title: 'PENGATURAN SIKLUS',
                          children: [
                            _settingTile(
                              icon: Icons.sync_alt_rounded,
                              label: 'Panjang Siklus',
                              value: '${_cycleData?.cycleLength ?? 28} Hari',
                              onTap: _editCycleLength,
                            ),
                            _settingTile(
                              icon: Icons.water_drop_outlined,
                              label: 'Durasi Haid',
                              value: '${_cycleData?.periodDuration ?? 5} Hari',
                              onTap: _editPeriodDuration,
                            ),
                            _settingTile(
                              icon: Icons.monitor_heart_outlined,
                              label: 'Kondisi Kesehatan',
                              value: _cycleData?.healthCondition ?? 'Normal',
                              onTap: _editHealthCondition,
                              isLast: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSectionCard(
                          title: 'NOTIFIKASI',
                          children: [
                            _switchTile(
                              icon: Icons.notifications_outlined,
                              label: 'Pengingat Haid',
                              value: _reminderEnabled,
                              onChanged: (v) =>
                                  setState(() => _reminderEnabled = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSectionCard(
                          title: 'LAINNYA',
                          children: [
                            _settingTile(
                              icon: Icons.shield_outlined,
                              label: 'Privasi & Keamanan',
                              value: '',
                              onTap: _openPrivacySecurity,
                            ),
                            _settingTile(
                              icon: Icons.logout_rounded,
                              label: 'Keluar',
                              value: '',
                              onTap: _logout,
                              isLast: true,
                              isDestructive: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return GestureDetector(
      onTap: _openEditProfile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 50, bottom: 30),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primary, AppTheme.primaryDark],
          ),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 44),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary, width: 1.5),
                    ),
                    child: const Icon(Icons.edit, size: 13, color: AppTheme.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0F0F0)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    bool isLast = false,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: Color(0xFFF5F5F5)),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.08)
                    : AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isDestructive ? Colors.red[400] : AppTheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red[400] : AppTheme.textDark,
                ),
              ),
            ),
            if (value.isNotEmpty)
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppTheme.textMedium,
                ),
              ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: AppTheme.textLight),
          ],
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications_outlined,
                size: 18, color: Color(0xFF00897B)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textDark,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}