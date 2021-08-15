import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:obsProject/models/StudentRegisterDto.dart';
import 'package:obsProject/models/addDersDto.dart';
import 'package:obsProject/models/ders.dart';
import 'package:obsProject/models/dersWithGrades.dart';
import 'package:obsProject/models/loginResponse.dart';
import 'package:obsProject/models/student.dart';
import 'package:obsProject/models/user.dart';
import 'package:obsProject/notifiers/ders_notifier.dart';
import 'package:obsProject/notifiers/student_notifier.dart';
import 'package:obsProject/notifiers/user_notifier.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';

Future<LoginResponse> login(
    String email, String password, UserNotifier userNotifier) async {
  try {
    var loginResponse = LoginResponse();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var dio = Dio();
    Response response =
        await dio.post(localConnectionString + "/api/auth/login",
            data: {"email": email, "password": password},
            options: Options(headers: {
              'content-type': 'application/JSON',
            }));
    if (response.data["success"]) {
      User currentUser = new User.fromMap(response.data["user"]);
      currentUser.accessToken = response.data["token"];
      userNotifier.currentUser = new User.fromMap(currentUser.toMap());
      preferences.setString("accessToken", currentUser.accessToken);
      loginResponse.success = true;
      loginResponse.message = "Giris basarili";
      return Future<LoginResponse>.value(loginResponse);
    } else {
      loginResponse.success = false;
      loginResponse.message = response.data['message'];

      return Future<LoginResponse>.value(loginResponse);
    }
  } catch (e) {
    if (e is DioError) {
      print("Dio eRROR");
    }
    var loginResponse = LoginResponse();
    loginResponse.success = false;
    loginResponse.message = e.toString();
    return Future<LoginResponse>.value(loginResponse);
  }
}

Future<bool> getCurrentUser(
    UserNotifier userNotifier, String accessToken) async {
  try {
    var dio = Dio();
    Response response = await dio.get(
        localConnectionString + "/api/home/getCurrentUser",
        options: Options(headers: {
          'content-type': 'application/JSON',
          'Authorization': 'Bearer ' + accessToken
        }));
    User currentUser = new User.fromMap(response.data["user"]);
    currentUser.accessToken = response.data["token"];
    userNotifier.currentUser = new User.fromMap(currentUser.toMap());
    return Future<bool>.value(true);
  } catch (e) {
    print(e.toString() + "catche düştü");
    return Future<bool>.value(false);
  }
}

Future<bool> registerStudent(
    StudentRegisterDto studentRegisterDto, String accessToken) async {
  try {
    var dio = Dio();
    Response response =
        await dio.post(localConnectionString + "/api/auth/register/student",
            data: studentRegisterDto.toMap(),
            options: Options(headers: {
              'content-type': 'application/JSON',
            }));
    return Future<bool>.value(true);
  } catch (e) {
    print(e.toString() + "catche düştü");
    return Future<bool>.value(false);
  }
}

Future<bool> getAllStudents(
    UserNotifier userNotifier, StudentNotifier studentNotifier) async {
  try {
    var dio = Dio();
    Response response =
        await dio.get(localConnectionString + "/api/home/getALlStudents",
            options: Options(headers: {
              'content-type': 'application/JSON',
              'Authorization': 'Bearer ' + userNotifier.CurrentUser.accessToken
            }));
    final List rawData = jsonDecode(jsonEncode(response.data));
    List<Student> allStudents = rawData.map((e) => Student.fromMap(e)).toList();

    studentNotifier.studentList = allStudents;
    return Future<bool>.value(true);
  } catch (e) {
    print(e.toString() + "catche düştü");
    return Future<bool>.value(false);
  }
}

Future<bool> addDers(AddDersDto dersDto, UserNotifier userNotifier) async {
  try {
    print(dersDto.toMap());
    var dio = Dio();
    Response response =
        await dio.post(localConnectionString + "/api/home/addDers",
            data: dersDto.toMap(),
            options: Options(headers: {
              'content-type': 'application/JSON',
              'Authorization': 'Bearer ' + userNotifier.CurrentUser.accessToken
            }));
    return Future<bool>.value(true);
  } catch (e) {
    print(e.toString() + "catche düştü");
    return Future<bool>.value(false);
  }
}

Future<bool> addDersToOgrenci(
    String ogrId, int dersId, UserNotifier userNotifier) async {
  try {
    var dio = Dio();
    Response response = await dio.get(
        localConnectionString +
            "/api/home/addDersToOgrenci/" +
            dersId.toString() +
            "/" +
            ogrId,
        options: Options(headers: {
          'content-type': 'application/JSON',
          'Authorization': 'Bearer ' + userNotifier.CurrentUser.accessToken
        }));
    return Future<bool>.value(true);
  } catch (e) {
    print(e.toString() + "catche düştü");
    return Future<bool>.value(false);
  }
}

Future<bool> deleteDersFromOgrenci(
    String ogrId, int dersId, UserNotifier userNotifier) async {
  try {
    var dio = Dio();
    Response response = await dio.get(
        localConnectionString +
            "/api/home/deleteDersFromOgrenci/" +
            dersId.toString() +
            "/" +
            ogrId,
        options: Options(headers: {
          'content-type': 'application/JSON',
          'Authorization': 'Bearer ' + userNotifier.CurrentUser.accessToken
        }));
    return Future<bool>.value(true);
  } catch (e) {
    print(e.toString() + "catche düştü");
    return Future<bool>.value(false);
  }
}

Future<bool> getAllDersByInstructor(
    UserNotifier userNotifier, DersNotifier dersNotifier) async {
  try {
    var dio = Dio();
    Response response = await dio.get(
        localConnectionString + "/api/home/getAllDersByInstructor",
        options: Options(headers: {
          'content-type': 'application/JSON',
          'Authorization': 'Bearer ' + userNotifier.CurrentUser.accessToken
        }));
    final List rawData = jsonDecode(jsonEncode(response.data));
    List<Ders> allDers = rawData.map((e) => Ders.fromMap(e)).toList();

    dersNotifier.dersList = allDers;
    return Future<bool>.value(true);
  } catch (e) {
    print(e.toString() + "catche düştü");
    return Future<bool>.value(false);
  }
}

Future<bool> getAllDersByStudent(
    UserNotifier userNotifier, DersNotifier dersNotifier) async {
  try {
    var dio = Dio();
    Response response =
        await dio.get(localConnectionString + "/api/home/getAllDersByStudent",
            options: Options(headers: {
              'content-type': 'application/JSON',
              'Authorization': 'Bearer ' + userNotifier.CurrentUser.accessToken
            }));
    final List rawData = jsonDecode(jsonEncode(response.data));
    List<Ders> allDers = rawData.map((e) => Ders.fromMap(e)).toList();

    dersNotifier.dersList = allDers;
    return Future<bool>.value(true);
  } catch (e) {
    print(e.toString() + "catche düştü");
    return Future<bool>.value(false);
  }
}

Future<List<DersWithGrades>> getAllStudentsWithGrades(
    UserNotifier userNotifier) async {
  try {
    var dio = Dio();
    Response response = await dio.get(
        localConnectionString + "/api/home/getAllStudentsWithGrades",
        options: Options(headers: {
          'content-type': 'application/JSON',
          'Authorization': 'Bearer ' + userNotifier.CurrentUser.accessToken
        }));
    final List rawData = jsonDecode(jsonEncode(response.data));
    List<DersWithGrades> allDers =
        rawData.map((e) => DersWithGrades.fromMap(e)).toList();

    return Future<List<DersWithGrades>>.value(allDers);
  } catch (e) {
    print(e.toString() + "catche düştü");
    return Future<List<DersWithGrades>>.value(null);
  }
}

Future<List<DersWithGrades>> getStudentsDersWithGrades(
    UserNotifier userNotifier) async {
  try {
    var dio = Dio();
    Response response =
        await dio.get(localConnectionString + "/api/home/getStudentsDers",
            options: Options(headers: {
              'content-type': 'application/JSON',
              'Authorization': 'Bearer ' + userNotifier.CurrentUser.accessToken
            }));
    final List rawData = jsonDecode(jsonEncode(response.data));
    List<DersWithGrades> allDers =
        rawData.map((e) => DersWithGrades.fromMap(e)).toList();

    return Future<List<DersWithGrades>>.value(allDers);
  } catch (e) {
    print(e.toString() + "catche düştü");
    return Future<List<DersWithGrades>>.value(null);
  }
}

Future<bool> uploadExcelTemplate(File excelFile) async {
  try {
    var dio = Dio();
    String fileName = excelFile.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(excelFile.path, filename: fileName),
    });
    Response response =
        await dio.post(localConnectionString + "/api/home/uploadExcelTemplate",
            data: formData, //dersDto.toMap(),
            options: Options(headers: {
              'content-type': 'application/JSON',
            }));
    return Future<bool>.value(true);
  } catch (e) {
    print(e.toString() + "catche düştü");
    return Future<bool>.value(false);
  }
}

Future<bool> getExcelTemplate(
    UserNotifier userNotifier, String savePath, int dersId) async {
  try {
    await getExcelTemplateWNotification(savePath, dersId);
    /*var dio = Dio();
    Response response = await dio.get(
      localConnectionString + "/api/home/getExcelTemplate/" + dersId.toString(),
      onReceiveProgress: showDownloadProgress,
      //Received data with List<int>
      options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status < 500;
          }),
    );
    print(response.headers);
    File file = File(savePath);
    var raf = file.openSync(mode: FileMode.write);
    // response.data is List<int> type
    raf.writeFromSync(response.data);
    await raf.close();*/
    return Future<bool>.value(true);
  } catch (e) {
    print(e);
    return Future<bool>.value(false);
  }
}

Future<bool> getExcelTemplateWNotification(String savePath, int dersId) async {
  try {
    print("deneme");
    File file = File(savePath);
    String path = await _prepareSaveDir();
    final taskId = await FlutterDownloader.enqueue(
      url: localConnectionString +
          "/api/home/getExcelTemplate/" +
          dersId.toString(),
      savedDir: path,
      fileName: "deneme",
      showNotification:
          false, // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
    );
    /*var dio = Dio();
    Response response = await dio.get(
      localConnectionString + "/api/home/getExcelTemplate/" + dersId.toString(),
      onReceiveProgress: showDownloadProgress,
      //Received data with List<int>
      options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status < 500;
          }),
    );
    print(response.headers);
    File file = File(savePath);
    var raf = file.openSync(mode: FileMode.write);
    // response.data is List<int> type
    raf.writeFromSync(response.data);
    await raf.close();*/
    return Future<bool>.value(true);
  } catch (e) {
    print(e);
    return Future<bool>.value(false);
  }
}

void showDownloadProgress(received, total) {
  if (total != -1) {
    print((received / total * 100).toStringAsFixed(0) + "%");
  }
}

Future<String> _prepareSaveDir() async {
  final _localPath =
      (await _findLocalPath()) + Platform.pathSeparator + 'Download';

  final savedDir = Directory(_localPath);
  bool hasExisted = await savedDir.exists();
  if (!hasExisted) {
    savedDir.create();
  }
  return _localPath;
}

Future<String> _findLocalPath() async {
  final directory = await getExternalStorageDirectory();
  return directory?.path;
}
