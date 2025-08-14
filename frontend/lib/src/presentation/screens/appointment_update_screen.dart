import 'package:flutter/material.dart';
import 'package:gov_connect/src/presentation/widgets/common_app_bar.dart';
import '../../core/theme/theme_config.dart';
import '../../core/theme/text_style_helper.dart';
import '../../core/models/appointment_models.dart';

class AppointmentUpdateScreen extends StatefulWidget {
  static const String routeName = '/appointment-update';
  final AppointmentDetails appointment;

  const AppointmentUpdateScreen({super.key, required this.appointment});

  @override
  State<AppointmentUpdateScreen> createState() =>
      _AppointmentUpdateScreenState();
}

class _AppointmentUpdateScreenState extends State<AppointmentUpdateScreen> {
  String selectedLocation = 'Battaramulla Office';
  DateTime selectedDate = DateTime.now();
  String selectedTimeSlot = '10:30 A.M - 11:00 A.M';
  late List<String> locations;

  @override
  void initState() {
    super.initState();

    // Initialize locations list
    locations = ['Battaramulla Office', 'Colombo Office', 'Kandy Office'];

    // Initialize with current appointment data
    // Check if the appointment location exists in our locations list
    String appointmentLocation = widget.appointment.location.name;
    if (!locations.contains(appointmentLocation)) {
      // If the appointment location doesn't exist in our list, add it
      locations.add(appointmentLocation);
    }
    selectedLocation = appointmentLocation;

    // Parse the current appointment date if needed
    // For now, keeping the current implementation
  }

  final List<String> timeSlots = [
    '8:30 A.M - 9:00 A.M',
    '9:00 A.M - 9:30 A.M',
    '9:30 A.M - 10:00 A.M',
    '10:00 A.M - 10:30 A.M',
    '10:30 A.M - 11:00 A.M',
    '11:00 A.M - 11:30 A.M',
  ];

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;
    return Scaffold(
      backgroundColor: AppColors.whiteCustom,
      appBar: CommonAppBar(
        title: widget.appointment.serviceTitle.replaceAll('\n', ' '),
        showNotifications: true,
        showProfile: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "New ${widget.appointment.serviceTitle.replaceAll('\n', ' ')} appointment",
              style: styles.headline20Regular.copyWith(
                color: AppColors.colorFF0062,
              ),
            ),
            const SizedBox(height: 20),
            Text('Service Description', style: styles.title18Medium),
            const SizedBox(height: 8),
            Text(
              widget.appointment.serviceDescription,
              style: styles.body14.copyWith(height: 1.5),
            ),
            const SizedBox(height: 20),
            Text('Requirements', style: styles.title18Medium),
            const SizedBox(height: 8),
            Text(
              'Original documents needed',
              style: styles.body14.copyWith(height: 1.5),
            ),
            const SizedBox(height: 12),
            ...widget.appointment.requiredDocuments.map(
              (document) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.colorFF0062,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        document,
                        style: styles.body14.copyWith(height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {},
              child: Text(
                'More info',
                style: styles.body14Medium.copyWith(
                  color: AppColors.colorFF007B,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text('Service Locations', style: styles.title18Medium),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: locations.contains(selectedLocation)
                  ? selectedLocation
                  : locations.first,
              items: locations
                  .map(
                    (location) => DropdownMenuItem(
                      value: location,
                      child: Text(location, style: styles.body14Regular),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedLocation = value;
                  });
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.colorFFD4D4),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select location to book appointments',
              style: styles.body12.copyWith(color: AppColors.colorFF7373),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {},
              child: Text(
                'View location details',
                style: styles.body14Medium.copyWith(
                  color: AppColors.colorFF007B,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text('Book a Time Slot', style: styles.title18Medium),
            const SizedBox(height: 12),
            Text('Select a date', style: styles.body14Medium),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.colorFFD4D4),
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.whiteCustom,
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
                      style: styles.body14Medium,
                    ),
                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: AppColors.colorFF007B,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Select a time slot', style: styles.body14Medium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: timeSlots.map((slot) {
                final bool isSelected = selectedTimeSlot == slot;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTimeSlot = slot;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 18,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? AppColors.colorFF007B
                            : AppColors.colorFFD4D4,
                      ),
                      color: isSelected
                          ? AppColors.colorFF007B.withOpacity(0.08)
                          : AppColors.whiteCustom,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      slot,
                      style: styles.body14Medium.copyWith(
                        color: isSelected
                            ? AppColors.colorFF007B
                            : AppColors.colorFF0062,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 36),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.colorFF007B,
                  foregroundColor: AppColors.whiteCustom,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Continue',
                  style: styles.title16Medium.copyWith(
                    color: AppColors.whiteCustom,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
