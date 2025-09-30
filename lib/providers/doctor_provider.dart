import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/supabase_config.dart';
import '../models/doctor.dart';

class DoctorNotifier extends StateNotifier<AsyncValue<List<Doctor>>> {
  DoctorNotifier() : super(const AsyncValue.loading()) {
    loadDoctors();
  }

  final _client = SupabaseConfig.client;

  Future<void> loadDoctors() async {
    try {
      final response = await _client
          .from('doctors')
          .select()
          .order('created_at', ascending: false);

      final doctors = (response as List)
          .map((json) => Doctor.fromJson(json))
          .toList();

      state = AsyncValue.data(doctors);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<List<Doctor>> searchDoctors({
    String? query,
    String? specialization,
  }) async {
    try {
      var queryBuilder = _client.from('doctors').select();

      if (query != null && query.isNotEmpty) {
        queryBuilder = queryBuilder.or(
          'full_name.ilike.%$query%,specialization.ilike.%$query%',
        );
      }

      if (specialization != null && specialization.isNotEmpty) {
        queryBuilder = queryBuilder.eq('specialization', specialization);
      }

      final response = await queryBuilder.order('rating', ascending: false);

      return (response as List).map((json) => Doctor.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search doctors: $e');
    }
  }
}

final doctorProvider =
    StateNotifierProvider<DoctorNotifier, AsyncValue<List<Doctor>>>((ref) {
      return DoctorNotifier();
    });

final doctorSearchProvider =
    FutureProvider.family<List<Doctor>, Map<String, String?>>((ref, params) {
      final doctorNotifier = ref.read(doctorProvider.notifier);
      return doctorNotifier.searchDoctors(
        query: params['query'],
        specialization: params['specialization'],
      );
    });
