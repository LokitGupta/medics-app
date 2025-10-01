import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/doctor.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../core/constants.dart';

class DoctorDetailScreen extends ConsumerWidget {
  final Doctor doctor;

  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Details'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDoctorInfo(),
            _buildAboutSection(),
            _buildAvailabilitySection(),
            _buildActionButtons(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.05),
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 60,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            doctor.fullName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            doctor.specialization,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoCard(
                icon: Icons.star,
                value: doctor.rating.toString(),
                label: 'Rating',
              ),
              const SizedBox(width: 24),
              _InfoCard(
                icon: Icons.work,
                value: '${doctor.experienceYears ?? 0}+',
                label: 'Years Exp.',
              ),
              const SizedBox(width: 24),
              _InfoCard(
                icon: Icons.attach_money,
                value:
                    '\$${doctor.consultationFee?.toStringAsFixed(0) ?? 'N/A'}',
                label: 'Consultation',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            doctor.bio ?? 'No additional information available.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          if (doctor.address != null) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    doctor.address!,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ],
          if (doctor.email != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.email,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  doctor.email!,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
          if (doctor.phone != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.phone,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  doctor.phone!,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Availability',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (doctor.availableDays.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              children: doctor.availableDays.map((day) {
                return Chip(
                  label: Text(day),
                  backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          if (doctor.availableHoursStart != null &&
              doctor.availableHoursEnd != null)
            Text(
              'Hours: ${doctor.availableHoursStart} - ${doctor.availableHoursEnd}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () =>
                  context.push('/home/book-appointment', extra: doctor),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                ),
              ),
              child: const Text(
                'Book Appointment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => _startChat(context, ref),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppConstants.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                ),
              ),
              child: const Text(
                'Start Chat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startChat(BuildContext context, WidgetRef ref) async {
    final authState = ref.read(authProvider);
    if (authState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to start chat')),
      );
      return;
    }

    try {
      final chatRoomId = await ref
          .read(chatProvider.notifier)
          .getOrCreateChatRoom(authState.user!.id, doctor.id);

      context.push(
        '/home/chat',
        extra: {'doctorId': doctor.id, 'doctorName': doctor.fullName},
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error starting chat: $e')));
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _InfoCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppConstants.primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
