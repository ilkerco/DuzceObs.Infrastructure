import 'package:flutter/services.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text?.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class FirstUpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.capitalizeFirstofEach);
  }
}

extension CapExtension on String {
  String get capitalizeFirstofEach =>
      this.split(" ").map((str) => str.capitalize).join(" ");
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
