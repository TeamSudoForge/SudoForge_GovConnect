import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/theme/theme_config.dart';
import '../../../core/utils/text_style_helper.dart';

class IndoorMapScreen extends StatefulWidget {
  final String destination;
  final String service;

  const IndoorMapScreen({
    Key? key,
    required this.destination,
    required this.service,
  }) : super(key: key);

  @override
  State<IndoorMapScreen> createState() => _IndoorMapScreenState();
}

class _IndoorMapScreenState extends State<IndoorMapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pathAnimation;
  bool _navigationStarted = false;
  int _currentStage = 0; // 0: start, 1: waiting, 2: counter1, 3: counter2, 4: done
  bool _showNotification = false;
  String _notificationMessage = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pathAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Listen to animation status
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleAnimationComplete();
      }
    });
  }
  
  void _handleAnimationComplete() {
    if (_currentStage == 1 && mounted) {
      // Arrived at waiting area, start waiting timer
      Future.delayed(Duration(seconds: 5), () {
        if (mounted && _currentStage == 1) {
          setState(() {
            _showNotification = true;
            _notificationMessage = 'Your token A-247 is now being served at Counter 1';
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startNavigation() {
    setState(() {
      _navigationStarted = true;
      _currentStage = 1;
    });
    // Small delay to show the path immediately after stage change
    Future.microtask(() {
      _animationController.forward();
    });
  }

  void _proceedToCounter(int counter) {
    setState(() {
      _showNotification = false;
      _currentStage = counter == 1 ? 2 : 3;
    });
    _animationController.reset();
    _animationController.forward().then((_) {
      if (counter == 1 && mounted) {
        // Show completion dialog after counter 1
        Future.delayed(Duration(seconds: 2), () {
          _showCounter1Complete();
        });
      }
    });
  }

  void _showCounter1Complete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Documents Verified'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your documents have been successfully verified.'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Receipt Number: ID2024-0247', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Processing Fee: Rs. 1,500'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _proceedToCounter(2);
            },
            child: Text('Proceed to Payment Counter'),
          ),
        ],
      ),
    );
  }

  void _showDocumentChecklist() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Required Documents'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChecklistItem('Birth Certificate', true),
            _buildChecklistItem('Proof of Address', true),
            _buildChecklistItem('Passport Photos (2x2)', true),
            _buildChecklistItem('Application Form', true),
            SizedBox(height: 16),
            Text(
              'Process:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('1. Submit documents at Counter 1'),
            Text('2. Receive verification receipt'),
            Text('3. Proceed to Counter 2 for payment'),
            Text('4. Collect your ID card receipt'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String item, bool checked) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_circle : Icons.circle_outlined,
            color: checked ? Colors.green : Colors.grey,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(item),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorFFF3F4,
      appBar: AppBar(
        backgroundColor: AppColors.colorFF007B,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Indoor Navigation',
          style: AppTextStyles.title20.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Navigation Guide'),
                  content: Text(
                    '1. Start at the entrance\n'
                    '2. Go to waiting area and wait for notification\n'
                    '3. Visit Counter 1 for document verification\n'
                    '4. Visit Counter 2 for payment\n'
                    '5. Collect your receipt',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Header
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildProgressStep('Waiting', 1, _currentStage >= 1),
                    Expanded(child: _buildProgressLine(_currentStage >= 2)),
                    _buildProgressStep('Counter 1', 2, _currentStage >= 2),
                    Expanded(child: _buildProgressLine(_currentStage >= 3)),
                    _buildProgressStep('Counter 2', 3, _currentStage >= 3),
                    Expanded(child: _buildProgressLine(_currentStage >= 4)),
                    _buildProgressStep('Done', 4, _currentStage >= 4),
                  ],
                ),
              ],
            ),
          ),
          // Map View
          Expanded(
            child: Stack(
              children: [
                // Floor Plan
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: FloorPlanPainter(
                        pathProgress: pathProgress,
                        currentStage: _currentStage,
                      ),
                    ),
                  ),
                ),
                // Notification overlay
                if (_showNotification)
                  Positioned(
                    top: 40,
                    left: 40,
                    right: 40,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.notifications_active, color: Colors.white),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _notificationMessage,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => _proceedToCounter(1),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.green,
                            ),
                            child: Text('Proceed to Counter 1'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Navigation Instructions
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _getStageColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getStageIcon(),
                        color: _getStageColor(),
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getStageTitle(),
                            style: AppTextStyles.title16Medium.copyWith(
                              color: AppColors.colorFF1717,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _getStageDescription(),
                            style: AppTextStyles.body14Regular.copyWith(
                              color: AppColors.colorFF7373,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_currentStage == 2)
                      TextButton(
                        onPressed: _showDocumentChecklist,
                        child: Text('Documents'),
                      ),
                  ],
                ),
                // Show document reminder while waiting
                if (_currentStage == 1 && _pathAnimation.value == 1)
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Required Documents:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[900],
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '• Birth Certificate\n• Proof of Address\n• 2 Passport Photos',
                                style: TextStyle(
                                  color: Colors.amber[800],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Action Button
          Container(
            padding: EdgeInsets.all(16),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _getButtonAction(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentStage == 4 ? Colors.green : AppColors.colorFF007B,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _getButtonText(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double get pathProgress {
    if (!_navigationStarted) return 0;
    if (_currentStage == 1 && _pathAnimation.value == 1) return 1;
    return _pathAnimation.value;
  }

  Widget _buildProgressStep(String label, int step, bool active) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: active ? AppColors.colorFF007B : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(
                color: active ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: active ? AppColors.colorFF007B : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool active) {
    return Container(
      height: 2,
      color: active ? AppColors.colorFF007B : Colors.grey[300],
      margin: EdgeInsets.only(bottom: 20),
    );
  }

  IconData _getStageIcon() {
    switch (_currentStage) {
      case 0: return Icons.play_arrow;
      case 1: return Icons.airline_seat_recline_normal;
      case 2: return Icons.assignment;
      case 3: return Icons.payment;
      case 4: return Icons.check_circle;
      default: return Icons.navigation;
    }
  }

  Color _getStageColor() {
    switch (_currentStage) {
      case 0: return AppColors.colorFF007B;
      case 1: return Colors.purple;
      case 2: return Colors.blue;
      case 3: return Colors.orange;
      case 4: return Colors.green;
      default: return AppColors.colorFF007B;
    }
  }

  String _getStageTitle() {
    switch (_currentStage) {
      case 0: return 'Ready to Start';
      case 1: return _pathAnimation.value == 1 ? 'Wait for Your Turn' : 'Go to Waiting Area';
      case 2: return 'Document Verification';
      case 3: return 'Payment Counter';
      case 4: return 'Process Complete!';
      default: return 'Navigation';
    }
  }

  String _getStageDescription() {
    switch (_currentStage) {
      case 0: return 'Begin your journey to get your National ID';
      case 1: 
        if (_pathAnimation.value < 1) {
          return 'Take a seat in the waiting area';
        } else {
          return 'You\'ll be notified when ready. Keep your documents ready.';
        }
      case 2: return 'Submit your documents for verification';
      case 3: return 'Pay the processing fee and get receipt';
      case 4: return 'Collect your ID card in 7 working days';
      default: return '';
    }
  }

  String _getButtonText() {
    switch (_currentStage) {
      case 0: return 'Start Navigation';
      case 1: return _pathAnimation.value == 1 ? 'Waiting...' : 'Navigating...';
      case 2: return 'At Counter 1';
      case 3: return 'Complete Payment';
      case 4: return 'Exit';
      default: return 'Continue';
    }
  }

  VoidCallback? _getButtonAction() {
    switch (_currentStage) {
      case 0: return _startNavigation;
      case 1: return null;
      case 2: return null;
      case 3: return () {
        setState(() {
          _currentStage = 4;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Payment Successful'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Your payment has been processed successfully.'),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text('Collection Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('January 22, 2025'),
                      SizedBox(height: 8),
                      Text('Reference: ID2024-0247-PAID'),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Done'),
              ),
            ],
          ),
        );
      };
      case 4: return () => Navigator.pop(context);
      default: return null;
    }
  }
}

// Custom painter for the floor plan
class FloorPlanPainter extends CustomPainter {
  final double pathProgress;
  final int currentStage;

  FloorPlanPainter({
    required this.pathProgress,
    required this.currentStage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Background
    paint.color = Colors.grey[100]!;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw floor
    paint.color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(20, 20, size.width - 40, size.height - 40), paint);

    // Room positions (non-overlapping)
    final waitingArea = Rect.fromLTWH(40, size.height / 2 - 60, 100, 100);
    final counter1 = Rect.fromLTWH(40, 40, 100, 60);
    final counter2 = Rect.fromLTWH(size.width - 140, 40, 100, 60);
    final infoDesk = Rect.fromLTWH(size.width / 2 - 50, 140, 100, 60);
    final entrance = Rect.fromLTWH(size.width / 2 - 40, size.height - 40, 80, 20);

    // Draw rooms
    _drawRoom(canvas, waitingArea, 'Waiting\nArea', Colors.purple[100]!, currentStage == 1);
    _drawRoom(canvas, counter1, 'Counter 1', Colors.blue[100]!, currentStage == 2);
    _drawRoom(canvas, counter2, 'Counter 2', Colors.orange[100]!, currentStage == 3);
    _drawRoom(canvas, infoDesk, 'Info Desk', Colors.grey[300]!, false);
    
    // Draw entrance
    paint.style = PaintingStyle.fill;
    paint.color = Colors.green[600]!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(entrance, Radius.circular(4)),
      paint,
    );
    
    // Draw entrance label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'ENTRANCE',
        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(entrance.center.dx - textPainter.width / 2, entrance.center.dy - textPainter.height / 2),
    );

    // Draw all previous paths as completed (solid)
    final completedPathPaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw completed paths
    if (currentStage >= 2) {
      // Path from entrance to waiting area (completed)
      Path completedPath1 = Path();
      completedPath1.moveTo(size.width / 2, size.height - 40);
      completedPath1.lineTo(size.width / 2, size.height / 2);
      completedPath1.lineTo(waitingArea.center.dx, size.height / 2);
      _drawDottedPath(canvas, completedPath1, completedPathPaint, 1.0);
    }

    if (currentStage >= 3) {
      // Path from waiting area to counter 1 (completed)
      Path completedPath2 = Path();
      completedPath2.moveTo(waitingArea.center.dx, waitingArea.center.dy);
      completedPath2.lineTo(waitingArea.center.dx, counter1.bottom + 20);
      completedPath2.lineTo(counter1.center.dx, counter1.bottom + 20);
      completedPath2.lineTo(counter1.center.dx, counter1.bottom);
      _drawDottedPath(canvas, completedPath2, completedPathPaint, 1.0);
    }

    if (currentStage >= 4) {
      // Path from counter 1 to counter 2 (completed)
      Path completedPath3 = Path();
      completedPath3.moveTo(counter1.center.dx, counter1.center.dy);
      completedPath3.lineTo(size.width / 2, counter1.center.dy);
      completedPath3.lineTo(size.width / 2, counter2.center.dy);
      completedPath3.lineTo(counter2.center.dx, counter2.center.dy);
      _drawDottedPath(canvas, completedPath3, completedPathPaint, 1.0);
    }

    // Draw current animated path (show immediately when stage changes)
    if (currentStage >= 1) {
      final pathPaint = Paint()
        ..color = AppColors.colorFF007B
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      Path path = Path();
      
      switch (currentStage) {
        case 1: // To waiting area
          path.moveTo(size.width / 2, size.height - 40);
          path.lineTo(size.width / 2, size.height / 2);
          path.lineTo(waitingArea.center.dx, size.height / 2);
          break;
        case 2: // To counter 1
          path.moveTo(waitingArea.center.dx, waitingArea.center.dy);
          path.lineTo(waitingArea.center.dx, counter1.bottom + 20);
          path.lineTo(counter1.center.dx, counter1.bottom + 20);
          path.lineTo(counter1.center.dx, counter1.bottom);
          break;
        case 3: // To counter 2
          path.moveTo(counter1.center.dx, counter1.center.dy);
          path.lineTo(size.width / 2, counter1.center.dy);
          path.lineTo(size.width / 2, counter2.center.dy);
          path.lineTo(counter2.center.dx, counter2.center.dy);
          break;
      }

      // Draw current dotted path
      // Show full path immediately as semi-transparent, then animate over it
      if (pathProgress == 0) {
        // Show full path in light blue immediately
        Paint previewPaint = Paint()
          ..color = AppColors.colorFF007B.withOpacity(0.3)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        _drawDottedPath(canvas, path, previewPaint, 1.0);
      } else {
        // Animate the path in full blue
        _drawDottedPath(canvas, path, pathPaint, pathProgress);
      }
    }

    // Draw "You are here" marker based on current stage
    paint.style = PaintingStyle.fill;
    paint.color = AppColors.colorFF007B;
    
    Offset currentLocation;
    switch (currentStage) {
      case 0:
        currentLocation = Offset(size.width / 2, size.height - 60);
        break;
      case 1:
        if (pathProgress == 1) {
          currentLocation = Offset(waitingArea.center.dx, waitingArea.center.dy);
        } else {
          currentLocation = Offset(size.width / 2, size.height - 60);
        }
        break;
      case 2:
        if (pathProgress == 1) {
          currentLocation = Offset(counter1.center.dx, counter1.center.dy);
        } else {
          currentLocation = Offset(waitingArea.center.dx, waitingArea.center.dy);
        }
        break;
      case 3:
        if (pathProgress == 1) {
          currentLocation = Offset(counter2.center.dx, counter2.center.dy);
        } else {
          currentLocation = Offset(counter1.center.dx, counter1.center.dy);
        }
        break;
      default:
        currentLocation = Offset(counter2.center.dx, counter2.center.dy);
    }
    
    // Draw pulsing effect for current location
    canvas.drawCircle(currentLocation, 12, paint..color = AppColors.colorFF007B.withOpacity(0.3));
    canvas.drawCircle(currentLocation, 8, paint..color = AppColors.colorFF007B);
    canvas.drawCircle(currentLocation, 4, paint..color = Colors.white);
  }

  void _drawRoom(Canvas canvas, Rect rect, String label, Color color, bool highlight) {
    final paint = Paint();
    
    // Fill
    paint.style = PaintingStyle.fill;
    paint.color = highlight ? color : color.withOpacity(0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(8)),
      paint,
    );
    
    // Border
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = highlight ? 3 : 2;
    paint.color = highlight ? color.withOpacity(0.8) : Colors.grey[400]!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(8)),
      paint,
    );
    
    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 11,
          fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.center.dx - textPainter.width / 2, rect.center.dy - textPainter.height / 2),
    );
  }

  void _drawDottedPath(Canvas canvas, Path path, Paint paint, double progress) {
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      final distance = metric.length * progress;
      for (double i = 0; i < distance; i += 8) {
        final tangent = metric.getTangentForOffset(i);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 2, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(FloorPlanPainter oldDelegate) {
    return oldDelegate.pathProgress != pathProgress ||
           oldDelegate.currentStage != currentStage;
  }
}