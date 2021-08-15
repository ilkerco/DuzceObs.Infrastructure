import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:obsProject/models/ders.dart';

class DersNotifier with ChangeNotifier {
  List<Ders> _dersList = [];

  Ders _currentDers;

  UnmodifiableListView<Ders> get dersList => UnmodifiableListView(_dersList);

  Ders get currentDers => _currentDers;

  set dersList(List<Ders> dersList) {
    _dersList = dersList;
    notifyListeners();
  }

  set currentDers(Ders ders) {
    _currentDers = ders;
    notifyListeners();
  }
}
