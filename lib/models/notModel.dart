class Deneme {
  String firstName;
  String lastName;
  String ogrNo;
  int sinif;
  List notlar = [];
  Deneme();
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'ogrNo': ogrNo,
      'sinif': sinif,
      'notlar': notlar
    };
  }
}

class NotModel {
  int not;
  int dersDegerlendirmeId;
  String dersDegerlendirmeName;
  NotModel();
  NotModel.fromMap(Map<String, dynamic> data) {
    not = data['not'];
    dersDegerlendirmeId = data['dersDegerlendirmeId'];
    dersDegerlendirmeName = data['dersDegerlendirmeName'];
  }
  Map<String, dynamic> toMap() {
    return {
      'not': not,
      'dersDegerlendirmeId': dersDegerlendirmeId,
      'dersDegerlendirmeName': dersDegerlendirmeName,
    };
  }
}
