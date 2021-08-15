import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:obsProject/models/student.dart';

class StudentNotifier with ChangeNotifier {
  List<Student> _studentList = [];

  Student _currentStudent;

  UnmodifiableListView<Student> get studentList =>
      UnmodifiableListView(_studentList);

  List<Student> get allStudents => _studentList;

  Student get currentStudent => _currentStudent;

  set studentList(List<Student> studentList) {
    _studentList = studentList;
    notifyListeners();
  }

  set currentProduct(Student student) {
    _currentStudent = student;
    notifyListeners();
  }
}
