import 'package:flutter/material.dart';
import 'package:gov_connect/src/core/theme/theme_config.dart';
import 'package:gov_connect/src/core/utils/text_style_helper.dart';
import 'package:video_player/video_player.dart';
import 'qr_scanner_screen.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({Key? key}) : super(key: key);

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.asset('assets/qr.mp4')
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.setLooping(false); // Don't loop, play once
        _controller.play();
        
        // Listen for video completion
        _controller.addListener(() {
          if (_controller.value.position >= _controller.value.duration && 
              !_hasNavigated && _controller.value.duration.inSeconds > 0) {
            _hasNavigated = true;
            _navigateToScanner();
          }
        });
      }).catchError((error) {
        print('Error initializing video: $error');
        // Navigate to scanner even if video fails
        Future.delayed(Duration(seconds: 2), _navigateToScanner);
      });
  }
  
  void _navigateToScanner() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const QrScannerScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: ThemeConfig.primaryColor,
      ),
      body: Column(
        children: [
          // Video Player Section with Grey Background
          Expanded(
            child: Container(
              color: const Color(0xFFE5E5E5), // Grey background like in the design
              child: Center(
                child: _isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : const CircularProgressIndicator(
                        color: Colors.white,
                      ),
              ),
            ),
          ),
          
          // Bottom Text Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              children: [
                Text(
                  'Position QR code in the frame',
                  style: AppTextStyles.title20RegularRoboto.copyWith(
                    color: ThemeConfig.textPrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Hold your device steady and ensure the QR code is clearly visible within the scanning area',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: ThemeConfig.textBlack3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}