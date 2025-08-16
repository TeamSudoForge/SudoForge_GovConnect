import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class DepartmentItem {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int serviceCount;

  const DepartmentItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.serviceCount,
  });
}

class DepartmentUtils {
  // Popular Departments Data
  static final List<DepartmentItem> popularDepartments = [
    DepartmentItem(
      id: 'immigration',
      name: 'Immigration',
      description: 'Identity documents, passports, and recovery services',
      icon: Remix.passport_line,
      color: const Color(0xFF3B82F6), // Blue
      serviceCount: 5,
    ),
    DepartmentItem(
      id: 'business',
      name: 'Business Services',
      description: 'Licensing, permits, and business registration',
      icon: Remix.briefcase_line,
      color: const Color(0xFF8B5CF6), // Purple
      serviceCount: 8,
    ),
    DepartmentItem(
      id: 'health',
      name: 'Health Services',
      description: 'Public health, permits, and safety services',
      icon: Remix.health_book_line,
      color: const Color(0xFFEF4444), // Red
      serviceCount: 6,
    ),
    DepartmentItem(
      id: 'planning',
      name: 'Planning & Development',
      description: 'Building permits, zoning, and development',
      icon: Remix.building_line,
      color: const Color(0xFFF97316), // Orange
      serviceCount: 4,
    ),
  ];

  // All Departments Data
  static final List<DepartmentItem> allDepartments = [
    // Popular departments
    ...popularDepartments,
    // Additional departments
    DepartmentItem(
      id: 'public-works',
      name: 'Public Works',
      description: 'Infrastructure, utilities, and maintenance',
      icon: Remix.tools_line,
      color: const Color(0xFF06B6D4), // Cyan
      serviceCount: 7,
    ),
    DepartmentItem(
      id: 'revenue',
      name: 'Revenue',
      description: 'Tax collection, assessments, and payments',
      icon: Remix.money_dollar_circle_line,
      color: const Color(0xFF10B981), // Green
      serviceCount: 5,
    ),
    DepartmentItem(
      id: 'education',
      name: 'Education',
      description: 'Schools, certifications, and educational services',
      icon: Remix.graduation_cap_line,
      color: const Color(0xFFF59E0B), // Amber
      serviceCount: 3,
    ),
    DepartmentItem(
      id: 'agriculture',
      name: 'Agriculture',
      description: 'Farming permits, subsidies, and agricultural support',
      icon: Remix.plant_line,
      color: const Color(0xFF84CC16), // Lime
      serviceCount: 4,
    ),
    DepartmentItem(
      id: 'transport',
      name: 'Transport',
      description: 'Vehicle registration, licenses, and permits',
      icon: Remix.car_line,
      color: const Color(0xFF8B5CF6), // Purple
      serviceCount: 6,
    ),
    DepartmentItem(
      id: 'housing',
      name: 'Housing',
      description: 'Housing applications, subsidies, and permits',
      icon: Remix.home_line,
      color: const Color(0xFFEC4899), // Pink
      serviceCount: 4,
    ),
  ];

  // Create a map for quick lookup
  static final Map<String, DepartmentItem> _departmentMap = {
    for (final dept in allDepartments) dept.id: dept,
  };

  /// Get department info by ID
  static DepartmentItem? getDepartmentById(String? departmentId) {
    if (departmentId == null) return null;
    return _departmentMap[departmentId];
  }

  /// Get department icon by ID
  static IconData getDepartmentIcon(String? departmentId) {
    final department = getDepartmentById(departmentId);
    return department?.icon ?? Remix.service_line; // Default fallback icon
  }

  /// Get department color by ID
  static Color getDepartmentColor(String? departmentId) {
    final department = getDepartmentById(departmentId);
    return department?.color ?? const Color(0xFF6B7280); // Default gray color
  }

  /// Get department info as a map (for convenience)
  static Map<String, dynamic> getDepartmentInfo(String? departmentId) {
    final department = getDepartmentById(departmentId);

    if (department != null) {
      return {
        'icon': department.icon,
        'color': department.color,
        'name': department.name,
        'description': department.description,
      };
    }

    // Default fallback
    return {
      'icon': Remix.service_line,
      'color': const Color(0xFF6B7280),
      'name': 'General Service',
      'description': 'Government service',
    };
  }
}
