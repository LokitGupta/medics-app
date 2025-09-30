import 'doctor.dart';

class Appointment {
  final String id;
  final String userId;
  final String doctorId;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final Doctor? doctor;

  Appointment({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.notes,
    required this.createdAt,
    this.doctor,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      userId: json['user_id'],
      doctorId: json['doctor_id'],
      appointmentDate: DateTime.parse(json['appointment_date']),
      appointmentTime: json['appointment_time'],
      status: json['status'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      doctor: json['doctors'] != null ? Doctor.fromJson(json['doctors']) : null,
    );
  }
}
