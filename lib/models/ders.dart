class Ders {
  int id;
  int studentsCount;
  String dersKodu;
  String dersAdi;
  String startTime;
  String endTime;
  String startDay;
  List dersDegerlendirmes = [];
  List students = [];
  Ders();
  Ders.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    studentsCount = data['studentsCount'];
    dersKodu = data['dersKodu'];
    dersAdi = data['dersAdi'];
    startTime = data['startTime'];
    endTime = data['endTime'];
    startDay = data['startDay'];
    dersDegerlendirmes = data['dersDegerlendirmes'];
    students = data['students'];
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dersKodu': dersKodu,
      'dersAdi': dersAdi,
      'startTime': startTime,
      'endTime': endTime,
      'startDay': startDay,
      'dersDegerlendirmes': dersDegerlendirmes,
      'studentsCount': studentsCount,
      'students': students
    };
  }
}
