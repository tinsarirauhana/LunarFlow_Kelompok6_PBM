import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = Supabase.instance.client;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Hapus semua data siklus & catatan harian milik user (tidak menghapus akun).
  Future<void> deleteAllUserData() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User tidak ditemukan');

    await _client.from('cycle_logs').delete().eq('user_id', userId);
    await _client.from('user_cycles').delete().eq('user_id', userId);
  }

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
}