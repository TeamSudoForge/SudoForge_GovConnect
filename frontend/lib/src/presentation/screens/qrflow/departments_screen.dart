import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_remix/flutter_remix.dart';
import '../../../core/theme/theme_config.dart';
import '../../../core/utils/text_style_helper.dart';
import 'service_detail_screen.dart';

class DepartmentsScreen extends StatelessWidget {
  const DepartmentsScreen({Key? key}) : super(key: key);

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
          'Department of Registration of Persons',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with department image
            Container(
              height: MediaQuery.of(context).size.height * 0.45,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Image.asset(
                      'assets/qrflow_images/departmentimg.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  // Centered content
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Glassmorphism circle with ID card icon
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(40),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    FlutterRemix.bank_card_line,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Welcome to The Department\nfor Registration of Persons',
                            style: AppTextStyles.headline24.copyWith(
                              color: Colors.white,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Please select your service',
                            style: AppTextStyles.body14Regular.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Service selection section
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      _buildServiceCard(
                        context,
                        iconPath: 'assets/icons_imported/baby.png',
                        title: 'Birth Certificate',
                        subtitle: 'Register new birth',
                        color: const Color(0xFFFCE4EC),
                        iconColor: const Color(0xFFE91E63),
                        isImage: true,
                      ),
                      _buildServiceCard(
                        context,
                        icon: FlutterRemix.close_line,
                        title: 'Death Certificate',
                        subtitle: 'Register death',
                        color: const Color(0xFFE0E0E0),
                        iconColor: const Color(0xFF616161),
                      ),
                      _buildServiceCard(
                        context,
                        icon: FlutterRemix.heart_3_line,
                        title: 'Marriage Certificate',
                        subtitle: 'Register marriage',
                        color: const Color(0xFFFFF9C4),
                        iconColor: const Color(0xFFFBC02D),
                      ),
                      _buildServiceCard(
                        context,
                        icon: FlutterRemix.bank_card_2_line,
                        title: 'National ID',
                        subtitle: 'Apply for ID card',
                        color: const Color(0xFFE3F2FD),
                        iconColor: const Color(0xFF1976D2),
                      ),
                      _buildServiceCard(
                        context,
                        icon: FlutterRemix.passport_line,
                        title: 'Passport',
                        subtitle: 'Apply for passport',
                        color: const Color(0xFFE8F5E9),
                        iconColor: const Color(0xFF388E3C),
                      ),
                      _buildServiceCard(
                        context,
                        icon: FlutterRemix.edit_line,
                        title: 'Name Change',
                        subtitle: 'Change legal name',
                        color: const Color(0xFFE0F2F1),
                        iconColor: const Color(0xFF00796B),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    IconData? icon,
    String? iconPath,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
    bool isImage = false,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ServiceDetailScreen(
              title: title,
              subtitle: subtitle,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: isImage && iconPath != null
                  ? Image.asset(
                      iconPath,
                      width: 24,
                      height: 24,
                      color: iconColor,
                    )
                  : Icon(
                      icon ?? Icons.help_outline,
                      color: iconColor,
                      size: 24,
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.title16Medium.copyWith(
                color: AppColors.colorFF1717,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.body12Regular.copyWith(
                color: AppColors.colorFF7373,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}