import 'package:supabase_flutter/supabase_flutter.dart';

class CycleData {
  final String id;
  final String userId;
  final String name;
  final DateTime lastPeriodDate;
  final int cycleLength;
  final int periodDuration;
  final DateTime createdAt;

  CycleData({
    required this.id,
    required this.userId,
    required this.name,
    required this.lastPeriodDate,
    required this.cycleLength,
    required this.periodDuration,
    required this.createdAt,
  });

  factory CycleData.fromMap(Map<String, dynamic> map) {
    return CycleData(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      lastPeriodDate: DateTime.parse(map['last_period_date'] as String),
      cycleLength: map['cycle_length'] as int,
      periodDuration: map['period_duration'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // === Logika prediksi siklus ===
  DateTime get nextPeriodDate =>
      lastPeriodDate.add(Duration(days: cycleLength));

  DateTime get ovulationDate =>
      nextPeriodDate.subtract(const Duration(days: 14));

  DateTime get fertileStart =>
      ovulationDate.subtract(const Duration(days: 2));

  DateTime get fertileEnd =>
      ovulationDate.add(const Duration(days: 2));

  int get daysUntilNextPeriod {
    final today = DateTime.now();
    return nextPeriodDate.difference(DateTime(today.year, today.month, today.day)).inDays;
  }

  int get currentCycleDay {
    final today = DateTime.now();
    return DateTime(today.year, today.month, today.day)
        .difference(DateTime(
          lastPeriodDate.year,
          lastPeriodDate.month,
          lastPeriodDate.day,
        ))
        .inDays + 1;
  }

  String get cyclePhase {
    final day = currentCycleDay;
    if (day <= periodDuration) return 'FASE MENSTRUASI';
    if (day <= 13) return 'FASE FOLIKULER';
    if (day <= 15) return 'FASE OVULASI';
    return 'FASE LUTEAL';
  }
}

class CycleService {
  final _client = Supabase.instance.client;

  Future<void> saveInitialData({
    required String name,
    required DateTime lastPeriodDate,
    required int cycleLength,
    required int periodDuration,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User tidak ditemukan');

    await _client.from('user_cycles').upsert({
      'user_id': userId,
      'name': name,
      'last_period_date': lastPeriodDate.toIso8601String().split('T')[0],
      'cycle_length': cycleLength,
      'period_duration': periodDuration,
    });
  }

  Future<CycleData?> fetchUserCycle() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('user_cycles')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return CycleData.fromMap(response);
  }
}
