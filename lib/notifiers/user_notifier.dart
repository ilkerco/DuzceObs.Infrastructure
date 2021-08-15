import 'package:flutter/material.dart';
import 'package:obsProject/models/user.dart';

class UserNotifier with ChangeNotifier {
  User _currentUser;

  User get CurrentUser {
    return _currentUser;
  }

  set setPhotoUrl(String photoUrl) {
    _currentUser.photoUrl = photoUrl;
    notifyListeners();
  }

  set currentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}
