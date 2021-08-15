class AddDersDto {
  String dersKodu;
  String dersAdi;
  String startTime;
  String endTime;
  String startDay;
  List dersDegerlendirmes = [];
  AddDersDto();
  AddDersDto.fromMap(Map<String, dynamic> data) {
    dersKodu = data['dersKodu'];
    dersAdi = data['dersAdi'];
    startTime = data['startTime'];
    endTime = data['endTime'];
    startDay = data['startDay'];
    dersDegerlendirmes = data['dersDegerlendirmes'];
  }
  Map<String, dynamic> toMap() {
    return {
      'dersKodu': dersKodu,
      'dersAdi': dersAdi,
      'startTime': startTime,
      'endTime': endTime,
      'startDay': startDay,
      'dersDegerlendirmes': dersDegerlendirmes,
    };
  }
}

class DersDegerlendirme {
  String name;
  String yuzde;
  DersDegerlendirme();
}
