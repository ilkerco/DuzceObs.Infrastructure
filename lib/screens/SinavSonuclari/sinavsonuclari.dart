import 'dart:core';
import 'dart:io';

import 'package:editable/editable.dart';
import 'package:expandable/expandable.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:obsProject/constants.dart';
import 'package:obsProject/size_config.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:obsProject/models/dersWithGrades.dart';
import 'package:obsProject/models/notModel.dart';
import 'package:obsProject/models/student.dart';
import 'package:obsProject/notifiers/student_notifier.dart';
import 'package:obsProject/notifiers/user_notifier.dart';
import 'package:obsProject/services/api/DuzceObsApi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SinavSonuclariScreen extends StatefulWidget {
  @override
  _SinavSonuclariScreenState createState() => _SinavSonuclariScreenState();
}

class _SinavSonuclariScreenState extends State<SinavSonuclariScreen> {
  static downloadingCallback(id, status, progress) {}

  List<DersWithGrades> _sinavSonuclari;
  List<NotModel> notlar = [];
  List headers = [];
  List rows = [];
  List denemeRows = [];
  List subRows = [];
  @override
  void initState() {
    print("SinavSonuclari page cagrildi");
    /*getAllStudentsWithGrades(Provider.of<UserNotifier>(context, listen: false))
        .then((value) {
      print(value);
      if (value == null) {
      } else {
        setState(() {
          _sinavSonuclari = value;
        });
      }
    });*/
    super.initState();
    FlutterDownloader.registerCallback(downloadingCallback);
  }

  refreshPage() {
    getAllStudentsWithGrades(Provider.of<UserNotifier>(context, listen: false))
        .then((value) {
      setState(() {});
    });
  }

  bool harfNotKontrol(dersKriters, notSayisi) {
    if (dersKriters.length == notSayisi.length) {
      return true;
    }
    return false;
  }

  Text calculateHarfNot(notlar) {
    double ortalama_d = 0;
    String harf = "";
    for (int i = 0; i < notlar.length; i++) {
      ortalama_d += notlar[i]["not"] * notlar[i]["yuzde"] / 100;
    }
    int ortalama = ortalama_d.round();
    if (ortalama <= 100 && ortalama >= 90) {
      harf = "AA";
    } else if (ortalama <= 89 && ortalama >= 85) {
      harf = "BA";
    } else if (ortalama <= 84 && ortalama >= 80) {
      harf = "BB";
    } else if (ortalama <= 79 && ortalama >= 70) {
      harf = "CB";
    } else if (ortalama <= 69 && ortalama >= 60) {
      harf = "CC";
    } else if (ortalama <= 59 && ortalama >= 55) {
      harf = "DC";
    } else if (ortalama <= 54 && ortalama >= 50) {
      harf = "DD";
    } else if (ortalama <= 49 && ortalama >= 40) {
      harf = "FD";
    } else {
      harf = "FF";
    }
    return Text(harf);
  }

  showMyDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            content: Text(
              'Message Here',
            ),
            actions: <Widget>[
              FlatButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: getAllStudentsWithGrades(
          Provider.of<UserNotifier>(context, listen: false)),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text('Yükleniyor...'));
        } else {
          if (snapshot.hasError)
            return Center(child: Text('Sistem hatası.'));
          else {
            if (snapshot.data.length == 0) {
              return Center(child: new Text('Henüz ders eklemediniz.'));
            }
            _sinavSonuclari = snapshot.data;
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _sinavSonuclari.length,
                  itemBuilder: (BuildContext context, index) {
                    return ExpandablePanel(
                      header: Column(
                        children: [
                          Text(
                            _sinavSonuclari[index].dersKodu +
                                " - " +
                                _sinavSonuclari[index].dersAdi,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 22),
                            textAlign: TextAlign.center,
                          ),
                          Divider()
                        ],
                      ),
                      collapsed: Column(
                        children: [
                          Center(
                            child: TextButton(
                              child: Text("Not dosyası indir"),
                              onPressed: () async {
                                final status =
                                    await Permission.storage.request();
                                if (status.isGranted) {
                                  var path = await ExtStorage
                                      .getExternalStoragePublicDirectory(
                                          ExtStorage.DIRECTORY_DOWNLOADS);
                                  String pathHeader = _sinavSonuclari[index]
                                          .dersKodu
                                          .toString() +
                                      "_" +
                                      _sinavSonuclari[index].dersAdi;
                                  String fullPath =
                                      "$path/" + pathHeader + ".xlsx";
                                  final externalDir =
                                      await getExternalStorageDirectory();

                                  final id = await FlutterDownloader.enqueue(
                                      url: localConnectionString +
                                          "/api/home/getExcelTemplate/" +
                                          _sinavSonuclari[index]
                                              .dersId
                                              .toString(),
                                      savedDir: path,
                                      fileName: pathHeader.trim() + ".xlsx",
                                      showNotification: true,
                                      openFileFromNotification: true);
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Uygulama izni gerekli.",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.grey[200],
                                      textColor: Colors.black,
                                      fontSize: 14.0);
                                }
                                /*Map<Permission, PermissionStatus> statuses =
                                    await [
                                  Permission.storage,
                                ].request();
                                print(statuses[Permission.storage]);
                                if (!await Permission.storage.isGranted) {
                                  Fluttertoast.showToast(
                                      msg: "Dosya izni vermelisiniz.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.grey[200],
                                      textColor: Colors.black,
                                      fontSize: 14.0);
                                }
                                //await PermissionHandler().requestPermissions([PermissionGroup.storage]);
                                var path = await ExtStorage
                                    .getExternalStoragePublicDirectory(
                                        ExtStorage.DIRECTORY_DOWNLOADS);
                                String pathHeader =
                                    _sinavSonuclari[index].dersKodu.toString() +
                                        "_" +
                                        _sinavSonuclari[index].dersAdi;
                                String fullPath =
                                    "$path/" + pathHeader + ".xlsx";
                                bool isSuccess = await getExcelTemplate(
                                    Provider.of<UserNotifier>(context,
                                        listen: false),
                                    fullPath,
                                    _sinavSonuclari[index].dersId);

                                if (isSuccess) {
                                  Fluttertoast.showToast(
                                      msg:
                                          "Dosya Downloads klasörüne başarıyla kaydedildi.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.grey[200],
                                      textColor: Colors.black,
                                      fontSize: 14.0);
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Dosya indirilirken hata.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.grey[200],
                                      textColor: Colors.black,
                                      fontSize: 14.0);
                                }*/
                              },
                            ),
                          ),
                          TextButton(
                            child: Text("Not dosyası yükle"),
                            onPressed: () async {
                              File file = await FilePicker.getFile(
                                  type: FileType.custom,
                                  allowedExtensions: ['xlsx']);
                              EasyLoading.show(
                                  status: "Dosya yükleniyor...",
                                  dismissOnTap: false,
                                  maskType: EasyLoadingMaskType.black);
                              await uploadExcelTemplate(file).then((value) {
                                if (value) {
                                  if (EasyLoading.isShow) {
                                    refreshPage();
                                    EasyLoading.dismiss();
                                  }
                                  Fluttertoast.showToast(
                                      msg: "Notlar başarıyla yüklendi.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.grey[200],
                                      textColor: Colors.black,
                                      fontSize: 14.0);
                                } else {
                                  if (EasyLoading.isShow) {
                                    EasyLoading.dismiss();
                                  }
                                  Fluttertoast.showToast(
                                      msg: "Notlar yüklenirken hata.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.grey[200],
                                      textColor: Colors.black,
                                      fontSize: 14.0);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      expanded: Container(
                        color: Colors.grey[200],
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _sinavSonuclari[index].students.length,
                            itemBuilder: (BuildContext context, index2) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.white),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: 15, bottom: 15, left: 8, right: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons
                                                    .person_outline_outlined),
                                              ],
                                            ),
                                            Container(
                                              width:
                                                  getProportionateScreenWidth(
                                                      70),
                                              child: Text(
                                                _sinavSonuclari[index]
                                                            .students[index2]
                                                        ['firstName'] +
                                                    " " +
                                                    _sinavSonuclari[index]
                                                            .students[index2]
                                                        ['lastName'],
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Text(_sinavSonuclari[index]
                                                .students[index2]['ogrNo']),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                _sinavSonuclari[index]
                                                        .students[0]['sinif']
                                                        .toString() +
                                                    ".sinif ",
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width:
                                              getProportionateScreenWidth(150),
                                          child: ListView.builder(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                              itemCount: _sinavSonuclari[index]
                                                  .dersKriters
                                                  .length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      index3) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Card(
                                                    child: ListTile(
                                                      title: Text(_sinavSonuclari[
                                                                          index]
                                                                      .dersKriters[
                                                                  index3][
                                                              "dersDegerlendirmeName"] +
                                                          "(%" +
                                                          _sinavSonuclari[index]
                                                              .dersKriters[
                                                                  index3]
                                                                  ["yuzde"]
                                                              .toString() +
                                                          ")"),
                                                      subtitle: _getOgrNot(
                                                          _sinavSonuclari[index]
                                                              .students[index2],
                                                          _sinavSonuclari[index]
                                                                      .dersKriters[
                                                                  index3][
                                                              "dersDegerlendirmeName"]),
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                        Expanded(
                                          child: Wrap(
                                            alignment: WrapAlignment.end,
                                            direction: Axis.horizontal,
                                            runSpacing: 0,
                                            spacing: 0,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              harfNotKontrol(
                                                      _sinavSonuclari[index]
                                                          .dersKriters,
                                                      _sinavSonuclari[index]
                                                              .students[index2]
                                                          ["notlar"])
                                                  ? Card(
                                                      child: ListTile(
                                                        title:
                                                            Text("Harf Notu"),
                                                        subtitle: calculateHarfNot(
                                                            _sinavSonuclari[
                                                                        index]
                                                                    .students[
                                                                index2]["notlar"]),
                                                      ),
                                                    )
                                                  : Card(
                                                      child: ListTile(
                                                        title:
                                                            Text("Harf Notu"),
                                                        subtitle: Text(" - "),
                                                      ),
                                                    )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    );
                  }),
            );
            /*return ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: _sinavSonuclari.length,
              itemBuilder: (BuildContext context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey[200]),
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 15, bottom: 15, left: 8, right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _sinavSonuclari[index].dersKodu +
                                " - " +
                                _sinavSonuclari[index].dersAdi,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 22),
                          ),
                          Divider(),
                          ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount:
                                  10, //_sinavSonuclari[index].students.length,
                              itemBuilder: (BuildContext context, index2) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.white),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 15,
                                          bottom: 15,
                                          left: 8,
                                          right: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _sinavSonuclari[index]
                                                            .students[0]
                                                        ['firstName'] +
                                                    " " +
                                                    _sinavSonuclari[0]
                                                            .students[index]
                                                        ['lastName'],
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(
                                                height: 2,
                                              ),
                                              Text(_sinavSonuclari[index]
                                                  .students[0]['ogrNo'])
                                            ],
                                          ),
                                          Row(
                                            children: [],
                                          ),
                                          Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              Text(_sinavSonuclari[index]
                                                      .students[0]['sinif']
                                                      .toString() +
                                                  ".sinif "),
                                              Icon(FontAwesome.graduation_cap),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                          TextButton(
                            child: Text("Not dosyası indir"),
                            onPressed: () async {
                              Map<Permission, PermissionStatus> statuses =
                                  await [
                                Permission.storage,
                              ].request();
                              print(statuses[Permission.storage]);
                              if (!await Permission.storage.isGranted) {
                                Fluttertoast.showToast(
                                    msg: "Dosya izni vermelisiniz.",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.grey[200],
                                    textColor: Colors.black,
                                    fontSize: 14.0);
                              }
                              //await PermissionHandler().requestPermissions([PermissionGroup.storage]);
                              var path = await ExtStorage
                                  .getExternalStoragePublicDirectory(
                                      ExtStorage.DIRECTORY_DOWNLOADS);
                              String pathHeader =
                                  _sinavSonuclari[index].dersKodu.toString() +
                                      "_" +
                                      _sinavSonuclari[index].dersAdi;
                              String fullPath = "$path/" + pathHeader + ".xlsx";
                              bool isSuccess = await getExcelTemplate(
                                  Provider.of<UserNotifier>(context,
                                      listen: false),
                                  fullPath,
                                  _sinavSonuclari[index].dersId);

                              if (isSuccess) {
                                Fluttertoast.showToast(
                                    msg:
                                        "Dosya Downloads klasörüne başarıyla kaydedildi.",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.grey[200],
                                    textColor: Colors.black,
                                    fontSize: 14.0);
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Dosya indirilirken hata.",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.grey[200],
                                    textColor: Colors.black,
                                    fontSize: 14.0);
                              }
                            },
                          ),
                          TextButton(
                            child: Text("Not dosyası yükle"),
                            onPressed: () async {
                              File file = await FilePicker.getFile(
                                  type: FileType.custom,
                                  allowedExtensions: ['xlsx']);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );*/
          }
        }
      },
    ) /*_sinavSonuclari != null
          ? Editable(
              columns: headers,
              rows: rows,
              showCreateButton: false,
              tdStyle: TextStyle(fontSize: 20),
              showSaveIcon: true,
              borderColor: Colors.grey.shade300,
            )
          : Container(
              child: Text("ANANA"),
            ),*/
        );
  }

  ListView buildOgrListView() {
    return ListView.builder(
      itemCount: _sinavSonuclari[0].students.length,
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
                        _sinavSonuclari[0].students[index]['firstName'] +
                            " " +
                            _sinavSonuclari[0].students[index]['lastName'],
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(_sinavSonuclari[0].students[index]['ogrNo'])
                    ],
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: () {},
                    child: Text('Not gir'),
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(_sinavSonuclari[0]
                              .students[index]['sinif']
                              .toString() +
                          ".sinif "),
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

  Text _getOgrNot(student, dersKriter) {
    for (int i = 0; i < student["notlar"].length; i++) {
      if (student["notlar"][i]["dersDegerlendirmeName"]
              .toString()
              .compareTo(dersKriter) ==
          0) {
        return Text(student["notlar"][i]["not"].toString());
      }
    }
    return Text("-");
  }
}
