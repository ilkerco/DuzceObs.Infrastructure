class StudentRegisterDto {
  String tc;
  String firstName;
  String lastName;
  String ogrNo;
  int sinif;
  StudentRegisterDto();
  Map<String, dynamic> toMap() {
    return {
      'tc': tc,
      'firstName': firstName,
      'lastName': lastName,
      'ogrNo': ogrNo,
      'sinif': sinif,
    };
  }
}
