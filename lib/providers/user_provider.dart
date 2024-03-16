import 'package:flutter/widgets.dart';
import 'package:modernsocialapp/models/user.dart';
import 'package:modernsocialapp/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthMethods _authMethods = AuthMethods();

  User? get getUser => _user;

  Future<void> refreshUser() async {
    User user = (await _authMethods.getUserDetails());
    _user = user;
    notifyListeners();
  }
}