class DersWithGrades {
  String dersKodu;
  String dersAdi;
  int dersId;
  List dersKriters;
  List students;
  String instructorName;
  String dersGunu;

  DersWithGrades();
  DersWithGrades.fromMap(Map<String, dynamic> data) {
    dersId = data['dersId'];
    dersKodu = data['dersKodu'];
    dersAdi = data['dersAdi'];
    dersKriters = data['dersKriters'];
    students = data['students'];
    instructorName = data['instructorName'];
    dersGunu = data['dersGunu'];
  }
  Map<String, dynamic> toMap() {
    return {
      'dersId': dersId,
      'dersKodu': dersKodu,
      'dersAdi': dersAdi,
      'dersKriters': dersKriters,
      'students': students,
    };
  }

  Map<String, dynamic> toMapWithNoKriter() {
    return {
      'students': students,
    };
  }
}
