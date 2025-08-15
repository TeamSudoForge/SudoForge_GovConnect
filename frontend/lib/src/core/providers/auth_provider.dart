import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  String? _email;

  String? get email => _email;

  void setEmail(String? email) {
    _email = email;
    notifyListeners();
  }

  void clearEmail() {
    _email = null;
    notifyListeners();
  }
}
