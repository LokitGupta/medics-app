import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/supabase_config.dart';
import '../models/appointment.dart';

class AppointmentNotifier extends StateNotifier<AsyncValue<List<Appointment>>> {
  AppointmentNotifier() : super(const AsyncValue.loading());

  final _client = SupabaseConfig.client;

  Future<void> loadUserAppointments(String userId) async {
    try {
      final response = await _client
          .from('appointments')
          .select('*, doctors(*)')
          .eq('user_id', userId)
          .order('appointment_date', ascending: true);

      final appointments = (response as List)
          .map((json) => Appointment.fromJson(json))
          .toList();

      state = AsyncValue.data(appointments);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> bookAppointment({
    required String userId,
    required String doctorId,
    required DateTime appointmentDate,
    required String appointmentTime,
    String? notes,
  }) async {
    try {
      await _client.from('appointments').insert({
        'user_id': userId,
        'doctor_id': doctorId,
        'appointment_date': appointmentDate.toIso8601String().split('T')[0],
        'appointment_time': appointmentTime,
        'notes': notes,
        'status': 'scheduled',
      });

      // Reload appointments after booking
      loadUserAppointments(userId);
    } catch (e) {
      throw Exception('Failed to book appointment: $e');
    }
  }

  Future<void> cancelAppointment(String appointmentId, String userId) async {
    try {
      await _client
          .from('appointments')
          .update({'status': 'cancelled'})
          .eq('id', appointmentId);

      // Reload appointments after cancellation
      loadUserAppointments(userId);
    } catch (e) {
      throw Exception('Failed to cancel appointment: $e');
    }
  }
}

final appointmentProvider =
    StateNotifierProvider<AppointmentNotifier, AsyncValue<List<Appointment>>>((
      ref,
    ) {
      return AppointmentNotifier();
    });
