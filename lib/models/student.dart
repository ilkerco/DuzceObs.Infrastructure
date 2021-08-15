class Student {
  String id;
  String email;
  String firstName;
  String lastName;
  String tc;
  String photoUrl;
  int sinif;
  String ogrNo;
  List dersler;
  Student();
  Student.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    photoUrl = data['photoUrl'];
    firstName = data['firstName'];
    lastName = data['lastName'];
    email = data['email'];
    tc = data['tc'];
    sinif = data['sinif'];
    ogrNo = data['ogrNo'];
    dersler = data['dersler'];
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'photoUrl': photoUrl,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'tc': tc,
      'sinif': sinif,
      'ogrNo': ogrNo,
      'dersler': dersler,
    };
  }
}
