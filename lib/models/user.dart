class User {
  String accessToken;
  String id;
  String email;
  String tc;
  String firstName;
  String lastName;
  String userType;
  String photoUrl;
  User();
  User.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    photoUrl = data['photoUrl'];
    firstName = data['firstName'];
    lastName = data['lastName'];
    email = data['email'];
    userType = data['userType'];
    tc = data['tc'];
    accessToken = data['accessToken'];
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'photoUrl': photoUrl,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'userType': userType,
      'tc': tc,
      'accessToken': accessToken,
    };
  }
}
