import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/doctor.dart';
import '../../models/appointment.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../core/constants.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  final Doctor doctor;

  const BookAppointmentScreen({super.key, required this.doctor});

  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  DateTime? _selectedDate;
  String? _selectedTime;
  final _notesController = TextEditingController();
  bool _isBooking = false;

  final List<String> _availableTimes = [
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              GoRouter.of(context).go('/home');
            }
          },
        ),
        title: const Text('Book Appointment'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDoctorInfo(),
            const SizedBox(height: 24),
            _buildDateSelection(),
            const SizedBox(height: 24),
            _buildTimeSelection(),
            const SizedBox(height: 24),
            _buildNotesSection(),
            const SizedBox(height: 32),
            _buildBookButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: const Icon(
              Icons.person,
              color: AppConstants.primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctor.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.doctor.specialization,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                if (widget.doctor.consultationFee != null)
                  Text(
                    '${widget.doctor.consultationFee!.toStringAsFixed(0)} consultation fee',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Date',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate != null
                      ? DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate!)
                      : 'Choose appointment date',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedDate != null
                        ? Colors.black
                        : Colors.grey[600],
                  ),
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _selectDate() async {
    final now = DateTime.now();

    // Find the first available date starting from today
    DateTime firstAvailable = now;
    while (!widget.doctor.availableDays.contains(
      DateFormat('EEEE').format(firstAvailable),
    )) {
      firstAvailable = firstAvailable.add(const Duration(days: 1));
    }

    final lastDate = now.add(const Duration(days: 90));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? firstAvailable,
      firstDate: firstAvailable,
      lastDate: lastDate,
      selectableDayPredicate: (DateTime day) {
        final dayName = DateFormat('EEEE').format(day);
        return widget.doctor.availableDays.contains(dayName);
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _selectedTime = null; // reset selected time
      });
    }
  }

  Widget _buildTimeSelection() {
    final appointmentsAsync = ref.watch(appointmentProvider);

    final bookedTimes = <String>[];
    final appointments = appointmentsAsync.asData?.value ?? [];

    if (_selectedDate != null) {
      for (final a in appointments) {
        final doctorId = a.doctorId;
        final status = a.status;
        final appointmentTime = a.appointmentTime;
        final appointmentDate = a.appointmentDate;

        if (doctorId != null &&
            doctorId == widget.doctor.id &&
            status != null &&
            status == 'scheduled' &&
            appointmentDate != null &&
            DateFormat('yyyy-MM-dd').format(appointmentDate) ==
                DateFormat('yyyy-MM-dd').format(_selectedDate!) &&
            appointmentTime != null) {
          bookedTimes.add(appointmentTime);
        }
      }
    }

    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Time',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _availableTimes.length,
          itemBuilder: (context, index) {
            final time = _availableTimes[index];

            bool isPastTime = false;
            if (_selectedDate != null) {
              final selectedDateTime = DateTime(
                _selectedDate!.year,
                _selectedDate!.month,
                _selectedDate!.day,
                int.parse(time.split(':')[0]),
                int.parse(time.split(':')[1]),
              );
              isPastTime = selectedDateTime.isBefore(now);
            }

            final isBooked = bookedTimes.contains(time);
            final isDisabled = isPastTime || isBooked;
            final isSelected = _selectedTime == time;

            return InkWell(
              onTap: isDisabled
                  ? null
                  : () {
                      setState(() {
                        _selectedTime = time;
                      });
                    },
              child: Container(
                decoration: BoxDecoration(
                  color: isDisabled
                      ? Colors.grey[300]
                      : (isSelected ? AppConstants.primaryColor : Colors.white),
                  border: Border.all(
                    color: isDisabled
                        ? Colors.grey
                        : (isSelected
                              ? AppConstants.primaryColor
                              : Colors.grey[300]!),
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Center(
                  child: Text(
                    time,
                    style: TextStyle(
                      color: isDisabled
                          ? Colors.grey[600]
                          : (isSelected ? Colors.white : Colors.black),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Notes (Optional)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Describe your symptoms or reason for visit...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookButton() {
    final authState = ref.watch(authProvider);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed:
            (_selectedDate != null &&
                _selectedTime != null &&
                authState.user != null &&
                !_isBooking)
            ? _bookAppointment
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
        ),
        child: _isBooking
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Book Appointment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  void _bookAppointment() async {
    final authState = ref.read(authProvider);
    if (authState.user == null) return;

    setState(() => _isBooking = true);

    try {
      await ref
          .read(appointmentProvider.notifier)
          .bookAppointment(
            userId: authState.user!.id,
            doctorId: widget.doctor.id,
            appointmentDate: _selectedDate!,
            appointmentTime: _selectedTime!,
            notes: _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully!')),
      );

      context.push('/home/appointments');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error booking appointment: $e')));
    } finally {
      setState(() => _isBooking = false);
    }
  }
}
