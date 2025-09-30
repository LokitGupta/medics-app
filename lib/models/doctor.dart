class Doctor {
  final String id;
  final String fullName;
  final String specialization;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final int? experienceYears;
  final double rating;
  final double? consultationFee;
  final String? address;
  final String? bio;
  final List<String> availableDays;
  final String? availableHoursStart;
  final String? availableHoursEnd;
  final DateTime createdAt;

  Doctor({
    required this.id,
    required this.fullName,
    required this.specialization,
    this.email,
    this.phone,
    this.avatarUrl,
    this.experienceYears,
    required this.rating,
    this.consultationFee,
    this.address,
    this.bio,
    required this.availableDays,
    this.availableHoursStart,
    this.availableHoursEnd,
    required this.createdAt,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      fullName: json['full_name'],
      specialization: json['specialization'],
      email: json['email'],
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
      experienceYears: json['experience_years'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      consultationFee: json['consultation_fee']?.toDouble(),
      address: json['address'],
      bio: json['bio'],
      availableDays: List<String>.from(json['available_days'] ?? []),
      availableHoursStart: json['available_hours_start'],
      availableHoursEnd: json['available_hours_end'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
