import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() async {
    try {
      // Try with network video first as a fallback
      final bool useNetworkVideo = false; // Set to true to test with network video
      
      if (useNetworkVideo) {
        // Use a sample video from the internet for testing
        _controller = VideoPlayerController.networkUrl(
          Uri.parse('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'),
        );
      } else {
        _controller = VideoPlayerController.asset('assets/qrflow_images/qr.mp4');
      }
      
      await _controller.initialize();
      
      if (!mounted) return;
      
      if (_controller.value.isInitialized) {
        print('Video initialized successfully');
        print('Video duration: ${_controller.value.duration}');
        print('Video size: ${_controller.value.size}');
        
        setState(() {
          _isInitialized = true;
        });
        
        _controller.setLooping(false);
        await _controller.play();
        
        // Add listener to navigate when video completes
        _controller.addListener(() {
          if (_controller.value.position >= _controller.value.duration && 
              !_hasNavigated && 
              _controller.value.duration > Duration.zero) {
            _hasNavigated = true;
            _navigateToScanner();
          }
        });
      } else {
        throw Exception('Video failed to initialize');
      }
    } catch (error) {
      print('Error initializing video: $error');
      print('Error type: ${error.runtimeType}');
      if (error is PlatformException) {
        print('Platform error code: ${error.code}');
        print('Platform error message: ${error.message}');
        print('Platform error details: ${error.details}');
      }
      
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _hasError = true;
          _errorMessage = error.toString();
        });
      }
    }
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
        actions: [
          TextButton(
            onPressed: _navigateToScanner,
            child: const Text(
              'Skip',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
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
                    : _hasError
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Unable to load video',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  'The instructional video could not be loaded. You can still continue to the scanner.',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _hasError = false;
                                  });
                                  _initializeVideoPlayer();
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: TextButton.styleFrom(
                                  foregroundColor: ThemeConfig.primaryColor,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Loading video...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
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