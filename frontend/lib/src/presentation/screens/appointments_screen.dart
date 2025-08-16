import 'package:flutter/material.dart';
import '../widgets/appointment_card.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../../core/models/appointment_models.dart';

class AppointmentsScreen extends StatefulWidget {
  static const String routeName = '/appointments';

  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  int selectedTab = 0; // 0 = All, 1 = Upcoming, 2 = Past

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const CommonAppBar(title: 'Appointments', showBackButton: false),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                _buildTabButton('All', 0),
                _buildTabButton('Upcoming', 1),
                _buildTabButton('Past', 2),
              ],
            ),
          ),

          // Appointments List
          Expanded(child: _buildAppointmentsList()),
        ],
      ),
      bottomNavigationBar: const BottomNavigationWidget(
        currentItem: BottomNavItem.appointments,
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = selectedTab == index;
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    List<AppointmentListItem> filteredAppointments;

    switch (selectedTab) {
      case 1: // Upcoming
        filteredAppointments = sampleAppointmentsList
            .where(
              (appointment) => appointment.status == AppointmentStatus.upcoming,
            )
            .toList();
        break;
      case 2: // Past
        filteredAppointments = sampleAppointmentsList
            .where(
              (appointment) => appointment.status == AppointmentStatus.past,
            )
            .toList();
        break;
      default: // All
        filteredAppointments = sampleAppointmentsList;
        break;
    }

    if (filteredAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No appointments found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your appointments will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredAppointments.length,
      itemBuilder: (context, index) {
        final appointment = filteredAppointments[index];
        return AppointmentCard(appointment: appointment);
      },
    );
  }
}
