import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../models/trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../services/storage_service.dart';

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _seatsCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _itineraryCtrl = TextEditingController();

  DateTime _departureDate = DateTime.now().add(const Duration(days: 14));
  DateTime _returnDate = DateTime.now().add(const Duration(days: 17));
  DateTime _deadline = DateTime.now().add(const Duration(days: 10));
  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _destinationCtrl.dispose();
    _priceCtrl.dispose();
    _seatsCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _itineraryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
      DateTime initial, void Function(DateTime) onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => onPicked(picked));
  }

  Future<void> _pickImage() async {
    final file = await StorageService().pickImage();
    if (file != null) setState(() => _imageFile = file);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = context.read<AuthProvider>().user;
    final itinerary = _itineraryCtrl.text
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    final trip = TripModel(
      id: '',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      destination: _destinationCtrl.text.trim(),
      departureDate: _departureDate,
      returnDate: _returnDate,
      price: double.parse(_priceCtrl.text),
      totalSeats: int.parse(_seatsCtrl.text),
      registrationDeadline: _deadline,
      latitude: _latCtrl.text.isEmpty
          ? null
          : double.tryParse(_latCtrl.text),
      longitude: _lngCtrl.text.isEmpty
          ? null
          : double.tryParse(_lngCtrl.text),
      itinerary: itinerary,
      createdBy: user?.uid ?? '',
      createdAt: DateTime.now(),
    );

    final success = await context.read<TripProvider>().addTrip(
          trip: trip,
          imageFile: _imageFile,
        );

    setState(() => _isLoading = false);
    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Trip created successfully!'),
              backgroundColor: AppColors.success),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to create trip.'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(child: Text('Admin access required.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Trip',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.grey.shade200, width: 1.5),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 40, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text('Tap to add trip image',
                                style: TextStyle(
                                    color: Colors.grey.shade400)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              _buildCard([
                _field(_titleCtrl, 'Trip Title', 'e.g. Murree Winter Trip',
                    required: true),
                const SizedBox(height: 14),
                _field(_descCtrl, 'Description', 'Describe the trip...',
                    maxLines: 3, required: true),
                const SizedBox(height: 14),
                _field(_destinationCtrl, 'Destination',
                    'e.g. Murree, Punjab', required: true),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _field(_priceCtrl, 'Price (PKR)', '2500',
                          required: true,
                          keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                          _seatsCtrl, 'Total Seats', '40',
                          required: true,
                          keyboardType: TextInputType.number),
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 16),
              _buildCard([
                const Text('Dates',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                _dateRow('Departure Date', _departureDate,
                    (d) => _departureDate = d),
                const SizedBox(height: 10),
                _dateRow(
                    'Return Date', _returnDate, (d) => _returnDate = d),
                const SizedBox(height: 10),
                _dateRow('Registration Deadline', _deadline,
                    (d) => _deadline = d),
              ]),
              const SizedBox(height: 16),
              _buildCard([
                const Text('Itinerary (optional)',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                const Text('Enter each item on a new line',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 10),
                _field(_itineraryCtrl, 'Itinerary',
                    'Day 1: Departure from COMSATS\nDay 2: Sightseeing\nDay 3: Return',
                    maxLines: 4),
              ]),
              const SizedBox(height: 16),
              _buildCard([
                const Text('Map Location (optional)',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _field(_latCtrl, 'Latitude', '33.9',
                          keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(_lngCtrl, 'Longitude', '73.4',
                          keyboardType: TextInputType.number),
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Create Trip',
                isLoading: _isLoading,
                color: AppColors.accent,
                onPressed: _submit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    String hint, {
    int maxLines = 1,
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: required
              ? (v) =>
                  v == null || v.isEmpty ? '$label is required' : null
              : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _dateRow(
      String label, DateTime date, void Function(DateTime) onPicked) {
    return GestureDetector(
      onTap: () => _pickDate(date, onPicked),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined,
              size: 18, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
          Text(
            '${date.day}/${date.month}/${date.year}',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.edit_outlined, size: 14, color: AppColors.textHint),
        ],
      ),
    );
  }
}
