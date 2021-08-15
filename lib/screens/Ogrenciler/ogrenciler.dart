import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:obsProject/helpers/UpperCaseTextFormatter.dart';
import 'package:obsProject/models/StudentRegisterDto.dart';
import 'package:obsProject/models/student.dart';
import 'package:obsProject/notifiers/student_notifier.dart';
import 'package:obsProject/notifiers/user_notifier.dart';
import 'package:obsProject/services/api/DuzceObsApi.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shimmer/shimmer.dart';

import '../../size_config.dart';

class OgrencilerScreen extends StatefulWidget {
  @override
  _OgrencilerScreenState createState() => _OgrencilerScreenState();
}

class _OgrencilerScreenState extends State<OgrencilerScreen> {
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _tcController = TextEditingController();
  final _sinifController = TextEditingController();
  final _ogrNoController = TextEditingController();
  UserNotifier _userNotifier;
  StudentNotifier _studentNotifier;
  @override
  void initState() {
    print("ogrenciler page cagrildi");
    configEasyLoading();
    _clearTextFields();
    _userNotifier = Provider.of<UserNotifier>(context, listen: false);
    _studentNotifier = Provider.of<StudentNotifier>(context, listen: false);
    super.initState();
  }

  void configEasyLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.yellow
      ..backgroundColor = Colors.green
      ..indicatorColor = Colors.yellow
      ..textColor = Colors.yellow
      ..maskColor = Colors.blue.withOpacity(0.5)
      ..userInteractions = false
      ..dismissOnTap = false;
  }

  void _clearTextFields() {
    _adController.clear();
    _soyadController.clear();
    _tcController.clear();
    _sinifController.clear();
    _ogrNoController.clear();
  }

  void showOgrEkleDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return showOgrEkleCustomDialog(context);
        });
  }

  Widget showOgrEkleCustomDialog(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _adController.clear();
        _soyadController.clear();
        _tcController.clear();
        _sinifController.clear();
        _ogrNoController.clear();
        Navigator.of(context).pop();
        return false;
      },
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        backgroundColor: Colors.grey[200], //this right here

        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            icon: Icon(Icons.cancel),
                            onPressed: () {
                              _adController.clear();
                              _soyadController.clear();
                              _tcController.clear();
                              _sinifController.clear();
                              _ogrNoController.clear();
                              Navigator.of(context).pop();
                            }),
                        RaisedButton(
                          onPressed: () async {
                            if (_adController.text.isEmpty ||
                                _soyadController.text.isEmpty ||
                                _tcController.text.isEmpty ||
                                _sinifController.text.isEmpty ||
                                _ogrNoController.text.isEmpty) {
                              Fluttertoast.showToast(
                                  msg: "Boş alanları doldurun!",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.grey[200],
                                  textColor: Colors.black,
                                  fontSize: 14.0);
                            } else if (_tcController.text.length != 11) {
                              Fluttertoast.showToast(
                                  msg: "TC no 11 haneli olmalı!",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.grey[200],
                                  textColor: Colors.black,
                                  fontSize: 14.0);
                            } else {
                              //call save ogr api
                              StudentRegisterDto studentToRegister =
                                  new StudentRegisterDto();
                              studentToRegister.firstName = _adController.text;
                              studentToRegister.lastName =
                                  _soyadController.text;
                              studentToRegister.ogrNo =
                                  _ogrNoController.text.toString();
                              studentToRegister.tc =
                                  _tcController.text.toString();
                              studentToRegister.sinif =
                                  int.parse(_sinifController.text.toString());
                              EasyLoading.show(
                                status: "Kaydediliyor...",
                                dismissOnTap: false,
                              );
                              await registerStudent(studentToRegister,
                                      _userNotifier.CurrentUser.accessToken)
                                  .then((value) {
                                if (value) {
                                  EasyLoading.dismiss();
                                  Navigator.of(context).pop();
                                  Fluttertoast.showToast(
                                      msg: "Öğrenci başarıyla kaydedildi.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.grey[200],
                                      textColor: Colors.black,
                                      fontSize: 14.0);
                                  _clearTextFields();
                                } else {
                                  EasyLoading.dismiss();
                                  Navigator.of(context).pop();
                                  Fluttertoast.showToast(
                                      msg: "Öğrenci kaydedilirken hata.",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.grey[200],
                                      textColor: Colors.black,
                                      fontSize: 14.0);
                                  _clearTextFields();
                                }
                              });
                            }
                          },
                          //disabledColor: kPrimaryColor.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            "Kaydet",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Yeni Öğrenci",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: getProportionateScreenWidth(20),
                        fontWeight: FontWeight.bold),
                  ),
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            top: getProportionateScreenWidth(15)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              top:
                                  BorderSide(width: 1, color: Colors.grey[300]),
                              bottom: BorderSide(
                                  width: 1, color: Colors.grey[300])),
                        ),
                        child: TextField(
                          controller: _adController,
                          textCapitalization: TextCapitalization.words,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r"[a-zA-Z\s]+$"))
                          ],
                          autocorrect: true,
                          onChanged: (text) {},
                          cursorColor: Colors.black.withOpacity(.6),
                          keyboardType: TextInputType.text,
                          maxLines: null,
                          autofocus: false,
                          cursorWidth: 1.1,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 15, bottom: 15, top: 15, right: 15),
                              hintStyle: TextStyle(color: Colors.grey),
                              hintText: 'Ad'),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: getProportionateScreenWidth(15)),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              top:
                                  BorderSide(width: 1, color: Colors.grey[300]),
                              bottom: BorderSide(
                                  width: 1, color: Colors.grey[300])),
                        ),
                        child: TextField(
                          controller: _soyadController,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r"[a-zA-Z]"))
                          ],
                          onChanged: (text) {},
                          cursorColor: Colors.black.withOpacity(.6),
                          keyboardType: TextInputType.text,
                          maxLines: null,
                          autocorrect: true,
                          autofocus: false,
                          cursorWidth: 1.1,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 15, bottom: 15, top: 15, right: 15),
                              hintStyle: TextStyle(color: Colors.grey),
                              hintText: 'Soyad'),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: getProportionateScreenWidth(15)),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              top:
                                  BorderSide(width: 1, color: Colors.grey[300]),
                              bottom: BorderSide(
                                  width: 1, color: Colors.grey[300])),
                        ),
                        child: TextField(
                          controller: _ogrNoController,
                          textCapitalization: TextCapitalization.words,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r"[0-9]")),
                          ],
                          onChanged: (text) {},
                          cursorColor: Colors.black.withOpacity(.6),
                          keyboardType: TextInputType.number,
                          maxLines: null,
                          maxLength: 9,
                          autocorrect: true,
                          autofocus: false,
                          cursorWidth: 1.1,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 15, bottom: 15, top: 15, right: 15),
                              hintStyle: TextStyle(color: Colors.grey),
                              hintText: 'Ogr No'),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: getProportionateScreenWidth(15)),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              top:
                                  BorderSide(width: 1, color: Colors.grey[300]),
                              bottom: BorderSide(
                                  width: 1, color: Colors.grey[300])),
                        ),
                        child: TextField(
                          controller: _tcController,
                          textCapitalization: TextCapitalization.words,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r"[0-9]")),
                          ],
                          onChanged: (text) {},
                          cursorColor: Colors.black.withOpacity(.6),
                          keyboardType: TextInputType.number,
                          maxLines: null,
                          maxLength: 11,
                          autocorrect: true,
                          autofocus: false,
                          cursorWidth: 1.1,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 15, bottom: 15, top: 15, right: 15),
                              hintStyle: TextStyle(color: Colors.grey),
                              hintText: 'TC'),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: getProportionateScreenWidth(15)),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              top:
                                  BorderSide(width: 1, color: Colors.grey[300]),
                              bottom: BorderSide(
                                  width: 1, color: Colors.grey[300])),
                        ),
                        child: TextField(
                          controller: _sinifController,
                          textCapitalization: TextCapitalization.words,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r"[1-4]"))
                          ],
                          onChanged: (text) {},
                          cursorColor: Colors.black.withOpacity(.6),
                          keyboardType: TextInputType.number,
                          maxLines: null,
                          maxLength: 1,
                          autocorrect: true,
                          autofocus: false,
                          cursorWidth: 1.1,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 15, bottom: 15, top: 15, right: 15),
                              hintStyle: TextStyle(color: Colors.grey),
                              hintText: 'Sınıf'),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.add),
          label: Text("Öğrenci ekle"),
          onPressed: () {
            showOgrEkleDialog(context);
            print("Ders eklendi");
          },
        ),
        body:
            StudentWaiter() /*ListView.builder(
          itemCount: 5,
          itemBuilder: (BuildContext context, index) {
            return StudentCard();
          }),*/
        );
  }
}

class StudentCard extends StatelessWidget {
  const StudentCard({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    StudentNotifier _studentNotifier =
        Provider.of<StudentNotifier>(context, listen: false);
    return ListView.builder(
      itemCount: _studentNotifier.studentList.length,
      itemBuilder: (BuildContext context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey[200]),
            child: Padding(
              padding: EdgeInsets.only(top: 15, bottom: 15, left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _studentNotifier.studentList[index].firstName +
                            " " +
                            _studentNotifier.studentList[index].lastName,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(_studentNotifier.studentList[index].ogrNo)
                    ],
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: () {},
                    child: Text('Mesaj Gönder'),
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                          _studentNotifier.studentList[index].sinif.toString() +
                              "   "),
                      Icon(FontAwesome.graduation_cap),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class StudentWaiter extends StatefulWidget {
  @override
  _StudentWaiterState createState() => _StudentWaiterState();
}

class _StudentWaiterState extends State<StudentWaiter> {
  bool isLoading = true;
  UserNotifier userNotifier;
  StudentNotifier studentNotifier;
  @override
  void initState() {
    studentNotifier = Provider.of<StudentNotifier>(context, listen: false);
    userNotifier = Provider.of<UserNotifier>(context, listen: false);
    if (studentNotifier.studentList.isEmpty) {
      getAllStudents(userNotifier, studentNotifier).then((value) {
        setState(() {
          isLoading = false;
        });
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading ? StudentCard() : ShimmerStudents();
  }
}

class ShimmerStudents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int offset = 0;
    int time = 800;
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 4,
        ),
        itemCount: 12,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          offset += 5;
          time = 800 + offset;
          return Shimmer.fromColors(
              highlightColor: Colors.white,
              baseColor: Colors.grey[300],
              period: Duration(milliseconds: time),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 8, left: 8, right: 8),
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 7,
                              offset: Offset(0, 3))
                        ],
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey),
                  ),
                ],
              ));
        });
  }
}
