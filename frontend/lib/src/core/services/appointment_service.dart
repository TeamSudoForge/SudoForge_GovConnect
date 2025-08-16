import 'package:flutter/foundation.dart';
import '../models/appointment_models.dart';

class AppointmentService with ChangeNotifier {
  List<AppointmentListItem> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<AppointmentListItem> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get upcoming appointments only
  List<AppointmentListItem> get upcomingAppointments {
    return _appointments
        .where(
          (appointment) => appointment.status == AppointmentStatus.upcoming,
        )
        .toList()
      ..sort((a, b) => _parseDate(a.date).compareTo(_parseDate(b.date)));
  }

  // Get next two upcoming appointments for dashboard
  List<AppointmentListItem> get nextTwoAppointments {
    return upcomingAppointments.take(2).toList();
  }

  AppointmentService() {
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // For now, use sample data - replace with actual API call
      _appointments = sampleAppointmentsList;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load appointments: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAppointments() async {
    await loadAppointments();
  }

  AppointmentDetails? getAppointmentDetails(String appointmentId) {
    return sampleAppointmentsDetails[appointmentId];
  }

  // Helper method to parse date for sorting
  DateTime _parseDate(String dateString) {
    try {
      // Handle the format "05\nSept" or similar
      final parts = dateString.split('\n');
      if (parts.length == 2) {
        final day = int.parse(parts[0]);
        final month = _parseMonth(parts[1]);
        // Assume current year for simplicity
        final year = DateTime.now().year;
        return DateTime(year, month, day);
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  int _parseMonth(String monthStr) {
    switch (monthStr.toLowerCase()) {
      case 'jan':
        return 1;
      case 'feb':
        return 2;
      case 'mar':
        return 3;
      case 'apr':
        return 4;
      case 'may':
        return 5;
      case 'jun':
        return 6;
      case 'jul':
        return 7;
      case 'aug':
        return 8;
      case 'sept':
        return 9;
      case 'oct':
        return 10;
      case 'nov':
        return 11;
      case 'dec':
        return 12;
      default:
        return 1;
    }
  }

  // Helper method to get icon for appointment type
  static int getAppointmentIcon(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('nic') || lowerTitle.contains('identity')) {
      return 0xe801; // Remix.id_card_line
    } else if (lowerTitle.contains('driving') ||
        lowerTitle.contains('license')) {
      return 0xe82a; // Remix.car_line
    } else if (lowerTitle.contains('passport')) {
      return 0xe8a4; // Remix.passport_line
    } else if (lowerTitle.contains('character') ||
        lowerTitle.contains('certificate')) {
      return 0xe850; // Remix.file_line
    } else {
      return 0xe878; // Remix.calendar_line (default)
    }
  }

  // Helper method to get color for appointment type
  static int getAppointmentColor(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('nic') || lowerTitle.contains('identity')) {
      return 0xFF6CB7FF; // Blue
    } else if (lowerTitle.contains('driving') ||
        lowerTitle.contains('license')) {
      return 0xFFB57EFF; // Purple
    } else if (lowerTitle.contains('passport')) {
      return 0xFF4CAF50; // Green
    } else if (lowerTitle.contains('character') ||
        lowerTitle.contains('certificate')) {
      return 0xFFFF9800; // Orange
    } else {
      return 0xFF2196F3; // Default blue
    }
  }
}
