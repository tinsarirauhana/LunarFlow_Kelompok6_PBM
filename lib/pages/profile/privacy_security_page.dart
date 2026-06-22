import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../auth/login_page.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  bool _appLock = false;
  bool _hideData = false;
  bool _isLoading = false;

  Future<void> _confirmDeleteData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Semua Data?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          'Semua catatan siklus dan riwayat kamu akan dihapus permanen. Tindakan ini tidak bisa dibatalkan.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Batal',
                style: GoogleFonts.poppins(color: AppTheme.textMedium)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Hapus',
                style: GoogleFonts.poppins(
                    color: Colors.red[400], fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final userId = AuthService().currentUser?.id;
        if (userId != null) {
          final client = AuthService();
          await client.deleteAllUserData();
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Semua data berhasil dihapus.',
                style: GoogleFonts.poppins(fontSize: 13)),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus data. Coba lagi.',
                style: GoogleFonts.poppins(fontSize: 13)),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
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
                'Privasi & Keamanan',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 28),

              _sectionLabel('KONTROL KEAMANAN'),
              const SizedBox(height: 12),
              _switchTile(
                title: 'Kunci Aplikasi',
                subtitle: 'FaceID atau PIN untuk akses aplikasi.',
                value: _appLock,
                onChanged: (v) => setState(() => _appLock = v),
              ),
              const SizedBox(height: 16),
              _switchTile(
                title: 'Sembunyikan Data',
                subtitle: 'Sembunyikan info pada notifikasi.',
                value: _hideData,
                onChanged: (v) => setState(() => _hideData = v),
              ),

              const SizedBox(height: 28),
              _sectionLabel('PENGELOLAAN DATA'),
              const SizedBox(height: 12),
              _actionTile(
                icon: Icons.file_download_outlined,
                title: 'Ekspor Data',
                subtitle: 'Unduh riwayat kesehatan Anda.',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fitur ekspor segera hadir.',
                          style: GoogleFonts.poppins(fontSize: 13)),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              _actionTile(
                icon: Icons.shield_outlined,
                title: 'Kebijakan Privasi',
                subtitle: 'Bagaimana kami melindungi data Anda.',
                onTap: () {},
              ),
              const SizedBox(height: 14),
              _actionTile(
                icon: Icons.delete_outline_rounded,
                title: 'Hapus Data',
                subtitle: 'Hapus semua catatan permanen.',
                onTap: _isLoading ? null : _confirmDeleteData,
                isDestructive: true,
                trailing: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.red),
                      )
                    : null,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppTheme.primary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  )),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textMedium,
                  )),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged, activeColor: AppTheme.primary),
      ],
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool isDestructive = false,
    Widget? trailing,
  }) {
    final color = isDestructive ? Colors.red[600] : AppTheme.textDark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: isDestructive ? Colors.red[600] : AppTheme.textDark),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: color,
                    )),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textMedium,
                    )),
              ],
            ),
          ),
          trailing ??
              const Icon(Icons.chevron_right, size: 20, color: AppTheme.textLight),
        ],
      ),
    );
  }
}
