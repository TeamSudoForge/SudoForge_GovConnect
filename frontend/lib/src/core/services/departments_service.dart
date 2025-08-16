import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/department_utils.dart';

class DepartmentsService extends ChangeNotifier {
  static const String _pinnedDepartmentsKey = 'pinned_departments';

  List<String> _pinnedDepartmentIds = [];

  List<String> get pinnedDepartmentIds =>
      List.unmodifiable(_pinnedDepartmentIds);

  List<DepartmentItem> get pinnedDepartments {
    return _pinnedDepartmentIds
        .map((id) => DepartmentUtils.getDepartmentById(id))
        .where((dept) => dept != null)
        .cast<DepartmentItem>()
        .toList();
  }

  List<DepartmentItem> get popularDepartments {
    return DepartmentUtils.popularDepartments;
  }

  /// Initialize the service and load pinned departments from storage
  Future<void> initialize() async {
    await _loadPinnedDepartments();
  }

  /// Load pinned departments from SharedPreferences
  Future<void> _loadPinnedDepartments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pinnedJson = prefs.getString(_pinnedDepartmentsKey);

      if (pinnedJson != null) {
        final pinnedList = jsonDecode(pinnedJson) as List<dynamic>;
        _pinnedDepartmentIds = pinnedList.cast<String>();
      }

      notifyListeners();
    } catch (e) {
      print('Error loading pinned departments: $e');
      _pinnedDepartmentIds = [];
    }
  }

  /// Save pinned departments to SharedPreferences
  Future<void> _savePinnedDepartments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pinnedJson = jsonEncode(_pinnedDepartmentIds);
      await prefs.setString(_pinnedDepartmentsKey, pinnedJson);
    } catch (e) {
      print('Error saving pinned departments: $e');
    }
  }

  /// Check if a department is pinned
  bool isDepartmentPinned(String departmentId) {
    return _pinnedDepartmentIds.contains(departmentId);
  }

  /// Pin a department to the dashboard
  Future<void> pinDepartment(String departmentId) async {
    if (!_pinnedDepartmentIds.contains(departmentId)) {
      _pinnedDepartmentIds.add(departmentId);
      notifyListeners();
      await _savePinnedDepartments();
    }
  }

  /// Unpin a department from the dashboard
  Future<void> unpinDepartment(String departmentId) async {
    if (_pinnedDepartmentIds.remove(departmentId)) {
      notifyListeners();
      await _savePinnedDepartments();
    }
  }

  /// Toggle the pin status of a department
  Future<void> toggleDepartmentPin(String departmentId) async {
    if (isDepartmentPinned(departmentId)) {
      await unpinDepartment(departmentId);
    } else {
      await pinDepartment(departmentId);
    }
  }

  /// Clear all pinned departments
  Future<void> clearAllPinnedDepartments() async {
    _pinnedDepartmentIds.clear();
    notifyListeners();
    await _savePinnedDepartments();
  }

  /// Get the first few pinned departments for display on home screen
  /// If no departments are pinned, returns empty list (the UI will handle this)
  List<DepartmentItem> getHomeScreenDepartments({int limit = 2}) {
    final pinned = pinnedDepartments;

    if (pinned.isNotEmpty) {
      return pinned.take(limit).toList();
    }

    // Return empty list if no departments are pinned
    return [];
  }
}
