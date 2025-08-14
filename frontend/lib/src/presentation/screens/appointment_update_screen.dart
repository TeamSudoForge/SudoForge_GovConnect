import 'package:flutter/material.dart';
import 'package:gov_connect/src/presentation/widgets/common_app_bar.dart';
import '../../core/theme/theme_config.dart';
import '../../core/theme/text_style_helper.dart';

class AppointmentUpdateScreen extends StatefulWidget {
  static const String routeName = '/appointment-update';

  const AppointmentUpdateScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentUpdateScreen> createState() =>
      _AppointmentUpdateScreenState();
}

class _AppointmentUpdateScreenState extends State<AppointmentUpdateScreen> {
  String selectedLocation = 'Battaramulla Office';
  DateTime selectedDate = DateTime.now();
  String selectedTimeSlot = '10:30 A.M - 11:00 A.M';

  final List<String> locations = [
    'Battaramulla Office',
    'Colombo Office',
    'Kandy Office',
  ];

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
        title: 'ID card renewal',
        showNotifications: true,
        showProfile: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New ID Card renewal appointment',
              style: styles.headline20Regular.copyWith(
                color: AppColors.colorFF0062,
              ),
            ),
            const SizedBox(height: 20),
            Text('Service Description', style: styles.title18Medium),
            const SizedBox(height: 8),
            Text(
              'Visit the registration office at your scheduled time to complete identity verification, new photograph, and fee payment.',
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
            Row(
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
                    'Proof of identity - passport or birth certificate',
                    style: styles.body14.copyWith(height: 1.5),
                  ),
                ),
              ],
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
              value: selectedLocation,
              items: locations
                  .map(
                    (location) => DropdownMenuItem(
                      value: location,
                      child: Text(location, style: styles.body14Regular),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedLocation = value!;
                });
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
