import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/custom_button.dart';
import '../../services/storage_service.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _maxParticipantsCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  String _selectedCategory = AppConstants.eventCategories.first;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _venueCtrl.dispose();
    _timeCtrl.dispose();
    _maxParticipantsCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickImage() async {
    final file = await StorageService().pickImage();
    if (file != null) setState(() => _imageFile = file);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = context.read<AuthProvider>().user;
    final event = EventModel(
      id: '',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      venue: _venueCtrl.text.trim(),
      date: _selectedDate,
      time: _timeCtrl.text.trim(),
      category: _selectedCategory,
      latitude: _latCtrl.text.isEmpty
          ? null
          : double.tryParse(_latCtrl.text),
      longitude: _lngCtrl.text.isEmpty
          ? null
          : double.tryParse(_lngCtrl.text),
      maxParticipants: _maxParticipantsCtrl.text.isEmpty
          ? null
          : int.tryParse(_maxParticipantsCtrl.text),
      createdBy: user?.uid ?? '',
      createdAt: DateTime.now(),
    );

    final success = await context.read<EventProvider>().addEvent(
          event: event,
          imageFile: _imageFile,
        );

    setState(() => _isLoading = false);
    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create event.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Event',
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
                            Text('Tap to add event image',
                                style: TextStyle(
                                    color: Colors.grey.shade400)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              _buildCard([
                _field(_titleCtrl, 'Event Title', 'e.g. Sports Week 2026',
                    required: true),
                const SizedBox(height: 14),
                _field(_descCtrl, 'Description', 'Describe the event...',
                    maxLines: 3, required: true),
                const SizedBox(height: 14),
                _field(_venueCtrl, 'Venue', 'e.g. COMSATS Sports Ground',
                    required: true),
                const SizedBox(height: 14),
                _dropdownField(),
                const SizedBox(height: 14),
                _dateField(),
                const SizedBox(height: 14),
                _field(_timeCtrl, 'Time', 'e.g. 10:00 AM - 2:00 PM',
                    required: true),
                const SizedBox(height: 14),
                _field(_maxParticipantsCtrl, 'Max Participants (optional)',
                    'Leave empty for unlimited',
                    keyboardType: TextInputType.number),
              ]),
              const SizedBox(height: 16),
              _buildCard([
                const Text(
                  'Map Location (optional)',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Add GPS coordinates to show event location on map',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _field(_latCtrl, 'Latitude', '33.6844',
                          keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(_lngCtrl, 'Longitude', '73.0479',
                          keyboardType: TextInputType.number),
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Create Event',
                isLoading: _isLoading,
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

  Widget _dropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          onChanged: (v) => setState(() => _selectedCategory = v!),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
          items: AppConstants.eventCategories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
        ),
      ],
    );
  }

  Widget _dateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Event Date',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
