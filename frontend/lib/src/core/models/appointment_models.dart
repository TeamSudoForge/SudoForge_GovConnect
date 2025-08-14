class AppointmentDetails {
  final String serviceTitle;
  final String department;
  final String date;
  final String time;
  final String serviceDescription;
  final List<String> requiredDocuments;
  final LocationDetails location;

  AppointmentDetails({
    required this.serviceTitle,
    required this.department,
    required this.date,
    required this.time,
    required this.serviceDescription,
    required this.requiredDocuments,
    required this.location,
  });
}

class LocationDetails {
  final String name;
  final String address;
  final String phone;
  final String email;
  final double latitude;
  final double longitude;

  LocationDetails({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.latitude,
    required this.longitude,
  });
}

// Sample data
final sampleAppointment = AppointmentDetails(
  serviceTitle: 'ID Card renewal\nAppointment',
  department: 'Department for Registrations of Persons',
  date: '25, Aug Tomorrow',
  time: '10:00 AM - 11:00 AM',
  serviceDescription:
      'Visit the registration office at your scheduled time to complete identity verification, new photograph, and fee payment.',
  requiredDocuments: [
    'Current ID card',
    'Proof of identity - passport or birth certificate',
  ],
  location: LocationDetails(
    name: 'Department for Registrations of Persons',
    address:
        'Department for Registrations of Persons\n10th Floor\nSuhurupaya\nSri Subhuthipura Road\nBattaramulla.',
    phone: '045 6016098',
    email: 'info@drp.lk',
    latitude: 33.5186,
    longitude: -86.8104,
  ),
);
