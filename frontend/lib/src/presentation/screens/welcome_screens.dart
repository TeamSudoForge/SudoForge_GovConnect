import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreens extends StatefulWidget {
  const WelcomeScreens({super.key});

  @override
  State<WelcomeScreens> createState() => _WelcomeScreensState();
}

class _WelcomeScreensState extends State<WelcomeScreens> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    print('[WelcomeScreens] Welcome screens initialized');
  }

  final List<WelcomePageData> _pages = [
    WelcomePageData(
      image: 'assets/welcome_screen/1-img.png',
      title: 'Easy Government Services',
      subtitle: 'Access all government services from your phone',
      description:
          'Apply for certificates, book appointments, and track your applications all in one place. No more long queues or paperwork.',
    ),
    WelcomePageData(
      image: 'assets/welcome_screen/2-img.png',
      title: 'Quick & Secure',
      subtitle: 'Fast processing with secure authentication',
      description:
          'Your documents are processed quickly and securely. Use biometric authentication and digital signatures for enhanced security.',
    ),
    WelcomePageData(
      image: 'assets/welcome_screen/3-img.png',
      title: 'Stay Connected',
      subtitle: 'Get real-time updates and notifications',
      description:
          'Receive instant notifications about your application status, appointment reminders, and important government announcements.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Mark welcome screens as seen and navigate to login
      _completeOnboarding();
    }
  }

  void _skipToLogin() {
    _completeOnboarding();
  }

  void _completeOnboarding() async {
    // Navigate directly to login without marking welcome screens as seen
    // This ensures welcome screens will show again if user is not logged in
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Page content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return WelcomePage(data: _pages[index]);
            },
          ),

          // Skip button overlaid on top
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextButton(
                  onPressed: _skipToLogin,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Page indicators and navigation at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Page indicators on the left
                    Row(
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 32 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentPage == index
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),

                    // Navigation text on the right
                    GestureDetector(
                      onTap: _nextPage,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          if (_currentPage < _pages.length - 1) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class WelcomePage extends StatelessWidget {
  final WelcomePageData data;

  const WelcomePage({super.key, required this.data});

  IconData _getIconForPage(String title) {
    if (title.contains('Easy Government')) {
      return Icons.account_balance;
    } else if (title.contains('Quick & Secure')) {
      return Icons.security;
    } else if (title.contains('Stay Connected')) {
      return Icons.notifications_active;
    }
    return Icons.image_outlined;
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // Image fills top portion (increased height)
        Expanded(
          flex: 7,
          child: Container(
            width: double.infinity,
            child: Image.asset(
              data.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print(
                  '[WelcomeScreens] Error loading image ${data.image}: $error',
                );
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getIconForPage(data.title),
                        size: 100,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Image not found',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // Content section (reduced to give more space to image)
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Title
                  Text(
                    data.title,
                    style: TextStyle(
                      fontSize: screenWidth < 360 ? 22 : 26,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // Subtitle
                  Text(
                    data.subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Text(
                      data.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.75),
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),

        // Add some padding at the bottom for the navigation controls
        const SizedBox(height: 120),
      ],
    );
  }
}

class WelcomePageData {
  final String image;
  final String title;
  final String subtitle;
  final String description;

  WelcomePageData({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}
