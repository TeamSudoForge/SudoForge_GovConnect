import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/theme_config.dart';
import '../../../core/utils/text_style_helper.dart';
import '../../widgets/action_button.dart';
import 'departments_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({Key? key}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  late MobileScannerController cameraController;
  final ImagePicker _picker = ImagePicker();
  bool _hasDetected = false;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleScannedData(String? code) {
    if (code != null && !_hasDetected) {
      _hasDetected = true;
      // Navigate directly to departments screen
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const DepartmentsScreen()),
      );
    }
  }

  void _showResultDialog(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('QR Code Scanned', style: AppTextStyles.title20),
        content: Text('Code: $code', style: AppTextStyles.body14Regular),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _hasDetected = false;
              });
            },
            child: Text('Scan Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const DepartmentsScreen()),
              );
            },
            child: Text('Proceed'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // For now, navigate directly to departments screen
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const DepartmentsScreen()),
        );
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
    }
  }

  void _enterCodeManually() {
    showDialog(
      context: context,
      builder: (context) {
        String manualCode = '';
        return AlertDialog(
          title: Text('Enter Code Manually', style: AppTextStyles.title20),
          content: TextField(
            onChanged: (value) => manualCode = value,
            decoration: InputDecoration(
              hintText: 'Enter QR code',
              border: OutlineInputBorder(),
            ),
            style: AppTextStyles.body14Regular,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (manualCode == '1234') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const DepartmentsScreen()),
                  );
                } else if (manualCode.isNotEmpty) {
                  _showSnackBar('Invalid code. Please enter 1234');
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteCustom,
      appBar: AppBar(
        backgroundColor: AppColors.colorFF007B,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Scan QR Code',
          style: AppTextStyles.title20.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppColors.colorFF007B, size: 20),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Camera Scanner Section
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                // QR Scanner View
                MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      _handleScannedData(barcode.rawValue);
                    }
                  },
                ),
                // Custom overlay
                CustomPaint(
                  painter: ScannerOverlayPainter(),
                  child: Container(),
                ),
              ],
            ),
          ),
          // Bottom section
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Position QR code in the frame',
                    style: AppTextStyles.title20RegularRoboto.copyWith(
                      color: AppColors.colorFF1717,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Hold your device steady and ensure the QR code is clearly visible within the scanning area',
                      style: AppTextStyles.body14Regular.copyWith(
                        color: AppColors.colorFF7373,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ActionButton(
                    text: 'Choose from Gallery',
                    icon: Icons.photo_library_outlined,
                    onPressed: _pickFromGallery,
                    isPrimary: true,
                  ),
                  const SizedBox(height: 16),
                  ActionButton(
                    text: 'Enter Code Manually',
                    icon: Icons.keyboard_outlined,
                    onPressed: _enterCodeManually,
                    isPrimary: false,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = 280;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final double right = left + scanAreaSize;
    final double bottom = top + scanAreaSize;

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTRB(left, top, right, bottom),
        Radius.circular(10),
      ));

    final path = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(
      path,
      Paint()..color = Colors.black.withOpacity(0.5),
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final borderPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTRB(left, top, right, bottom),
        Radius.circular(10),
      ));

    canvas.drawPath(borderPath, borderPaint);

    // Draw corner accents
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    final cornerLength = 30.0;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top + cornerLength),
      Offset(left, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(right - cornerLength, top),
      Offset(right, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(right, top),
      Offset(right, top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, bottom - cornerLength),
      Offset(left, bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, bottom),
      Offset(left + cornerLength, bottom),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(right - cornerLength, bottom),
      Offset(right, bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right, bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}