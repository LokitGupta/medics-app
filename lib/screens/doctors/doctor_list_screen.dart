import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/doctor_provider.dart';
import '../../core/constants.dart';
import '../../models/doctor.dart';

class DoctorListScreen extends ConsumerStatefulWidget {
  const DoctorListScreen({super.key});

  @override
  _DoctorListScreenState createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends ConsumerState<DoctorListScreen> {
  final _searchController = TextEditingController();
  String? _selectedSpecialization;

  final List<String> _specializations = [
    'All',
    'Cardiology',
    'Dermatology',
    'Pediatrics',
    'Orthopedics',
    'Neurology',
  ];

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(doctorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Doctors'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          Expanded(
            child: doctorsAsync.when(
              data: (doctors) => _buildDoctorsList(doctors),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      color: Colors.grey[50],
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search doctors...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) => _performSearch(),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _specializations.map((spec) {
                final isSelected =
                    _selectedSpecialization == spec ||
                    (spec == 'All' && _selectedSpecialization == null);
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(spec),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSpecialization = spec == 'All' ? null : spec;
                      });
                      _performSearch();
                    },
                    selectedColor: AppConstants.primaryColor.withOpacity(0.2),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList(List<Doctor> doctors) {
    var filteredDoctors = doctors;

    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filteredDoctors = filteredDoctors
          .where(
            (doctor) =>
                doctor.fullName.toLowerCase().contains(query) ||
                doctor.specialization.toLowerCase().contains(query),
          )
          .toList();
    }

    if (_selectedSpecialization != null) {
      filteredDoctors = filteredDoctors
          .where((doctor) => doctor.specialization == _selectedSpecialization)
          .toList();
    }

    if (filteredDoctors.isEmpty) {
      return const Center(child: Text('No doctors found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: filteredDoctors.length,
      itemBuilder: (context, index) {
        return _DoctorCard(
          doctor: filteredDoctors[index],
          onTap: () =>
              context.go('/doctor-detail', extra: filteredDoctors[index]),
        );
      },
    );
  }

  void _performSearch() {
    setState(() {});
  }
}

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  const _DoctorCard({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialization,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          doctor.rating.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (doctor.experienceYears != null) ...[
                          const Icon(Icons.work, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${doctor.experienceYears} years',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (doctor.consultationFee != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '\$${doctor.consultationFee!.toStringAsFixed(0)} consultation',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
