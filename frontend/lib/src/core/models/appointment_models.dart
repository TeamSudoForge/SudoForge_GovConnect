class AppointmentListItem {
  final String id;
  final String title;
  final String department;
  final String date;
  final String time;
  final AppointmentStatus status;
  final String? departmentId; // Add this field to link to department

  AppointmentListItem({
    required this.id,
    required this.title,
    required this.department,
    required this.date,
    required this.time,
    required this.status,
    this.departmentId, // Add this parameter
  });
}

enum AppointmentStatus { upcoming, past, cancelled }

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
    latitude: 6.822165,
    longitude: 79.875634,
  ),
);

// Sample appointment list data
final List<AppointmentListItem> sampleAppointmentsList = [
  AppointmentListItem(
    id: '1',
    title: 'New National Identity card',
    department: 'Department for Registration of Persons, Battaramulla',
    date: '05\nSept',
    time: '10:30 AM - 11:00 AM',
    status: AppointmentStatus.upcoming,
    departmentId: 'immigration', // Link to immigration department
  ),
  AppointmentListItem(
    id: '2',
    title: 'Character certificate',
    department: 'Grama Niladari, Kottawa',
    date: '15\nSept',
    time: '9:30 AM - 10:00 AM',
    status: AppointmentStatus.upcoming,
    departmentId: 'public-works', // Link to public works department
  ),
  AppointmentListItem(
    id: '3',
    title: 'Driving License Written Exam',
    department: 'Department for Motor Traffic, Werahera',
    date: '15\nSept',
    time: '10:30 AM - 11:00 AM',
    status: AppointmentStatus.upcoming,
    departmentId: 'transport', // Link to transport department
  ),
  AppointmentListItem(
    id: '4',
    title: 'Driving License Medical Exam',
    department: 'Department for Motor Traffic, Werahera',
    date: '15\nJuly',
    time: '10:30 AM - 11:00 AM',
    status: AppointmentStatus.past,
    departmentId: 'transport', // Link to transport department
  ),
  AppointmentListItem(
    id: '5',
    title: 'New Passport',
    department: 'Department for Immigration and Emigration, Battaramulla',
    date: '1\nJuly',
    time: '10:30 AM - 11:00 AM',
    status: AppointmentStatus.past,
    departmentId: 'immigration', // Link to immigration department
  ),
];

// Sample detailed appointments data
final Map<String, AppointmentDetails> sampleAppointmentsDetails = {
  '1': AppointmentDetails(
    serviceTitle: 'New National Identity card',
    department: 'Department for Registration of Persons',
    date: '05 September 2024',
    time: '10:30 AM - 11:00 AM',
    serviceDescription:
        'Apply for a new National Identity card. This service is for citizens who are applying for their first NIC or need to replace a lost/damaged card.',
    requiredDocuments: [
      'Birth Certificate (original and certified copy)',
      'Proof of citizenship',
      'Two recent passport-size photographs',
      'Completed application form',
    ],
    location: LocationDetails(
      name: 'Department for Registration of Persons',
      address:
          'Department for Registration of Persons\n10th Floor\nSuhurupaya\nSri Subhuthipura Road\nBattaramulla.',
      phone: '045 6016098',
      email: 'info@drp.lk',
      latitude: 6.822165,
      longitude: 79.875634,
    ),
  ),
  '2': AppointmentDetails(
    serviceTitle: 'Character certificate',
    department: 'Grama Niladari Office',
    date: '15 September 2024',
    time: '9:30 AM - 10:00 AM',
    serviceDescription:
        'Obtain a character certificate from your local Grama Niladari office. This certificate verifies your good character and conduct in the area.',
    requiredDocuments: [
      'National Identity Card (original and copy)',
      'Completed application form',
      'Two recent passport-size photographs',
      'Proof of residence',
    ],
    location: LocationDetails(
      name: 'Grama Niladari Office - Kottawa',
      address:
          'Grama Niladari Office\nKottawa Divisional Secretariat\nKottawa\nWestern Province.',
      phone: '011 2123456',
      email: 'gn.kottawa@gmail.com',
      latitude: 6.8468,
      longitude: 79.9712,
    ),
  ),
  '3': AppointmentDetails(
    serviceTitle: 'Driving License Written Exam',
    department: 'Department for Motor Traffic',
    date: '15 September 2024',
    time: '10:30 AM - 11:00 AM',
    serviceDescription:
        'Take the written examination for your driving license. This test evaluates your knowledge of traffic rules and road safety.',
    requiredDocuments: [
      'National Identity Card (original and copy)',
      'Medical certificate',
      'Learner\'s permit',
      'Completed application form',
      'Passport-size photographs (2)',
    ],
    location: LocationDetails(
      name: 'Department for Motor Traffic - Werahera',
      address:
          'Department for Motor Traffic\nWerahera\nBoralesgamuwa\nWestern Province.',
      phone: '011 2567890',
      email: 'info@dmt.lk',
      latitude: 6.8413,
      longitude: 79.9019,
    ),
  ),
  '4': AppointmentDetails(
    serviceTitle: 'Driving License Medical Exam',
    department: 'Department for Motor Traffic',
    date: '15 July 2024',
    time: '10:30 AM - 11:00 AM',
    serviceDescription:
        'Complete the medical examination required for your driving license application. This ensures you are medically fit to drive.',
    requiredDocuments: [
      'National Identity Card (original and copy)',
      'Completed medical form',
      'Recent passport-size photographs (2)',
      'Previous driving license (if renewal)',
    ],
    location: LocationDetails(
      name: 'Department for Motor Traffic - Werahera',
      address:
          'Department for Motor Traffic\nWerahera\nBoralesgamuwa\nWestern Province.',
      phone: '011 2567890',
      email: 'info@dmt.lk',
      latitude: 6.8413,
      longitude: 79.9019,
    ),
  ),
  '5': AppointmentDetails(
    serviceTitle: 'New Passport',
    department: 'Department for Immigration and Emigration',
    date: '1 July 2024',
    time: '10:30 AM - 11:00 AM',
    serviceDescription:
        'Apply for a new Sri Lankan passport. This service is for first-time applicants or those renewing their existing passport.',
    requiredDocuments: [
      'National Identity Card (original and certified copy)',
      'Birth Certificate (original and certified copy)',
      'Completed passport application form',
      'Recent passport-size photographs (2)',
      'Payment receipt for passport fee',
    ],
    location: LocationDetails(
      name: 'Department for Immigration and Emigration',
      address:
          'Department for Immigration and Emigration\n41 Ananda Rajakaruna Mawatha\nColombo 10\nWestern Province.',
      phone: '011 5329000',
      email: 'info@immigration.gov.lk',
      latitude: 6.9147,
      longitude: 79.8612,
    ),
  ),
};
