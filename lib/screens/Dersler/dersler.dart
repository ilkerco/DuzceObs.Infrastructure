import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:obsProject/helpers/UpperCaseTextFormatter.dart';
import 'package:obsProject/models/addDersDto.dart';
import 'package:obsProject/models/ders.dart';
import 'package:obsProject/models/dersler.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:obsProject/notifiers/ders_notifier.dart';
import 'package:obsProject/notifiers/student_notifier.dart';
import 'package:obsProject/notifiers/user_notifier.dart';
import 'package:obsProject/services/api/DuzceObsApi.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../size_config.dart';

class DerslerPage extends StatefulWidget {
  /// Creates the home page.

  @override
  _DerslerPageState createState() => _DerslerPageState();
}

class _DerslerPageState extends State<DerslerPage> {
  final _dersKoduController = TextEditingController();
  final _dersAdiController = TextEditingController();
  final _dersTarihiController = TextEditingController();
  final _vizeYuzde = TextEditingController();
  final _finalYuzde = TextEditingController();

  List<DynamicWidget> listDynamic = [];
  seeDynamicData() {
    listDynamic.forEach((element) {
      print(element.controller.text);
      print(element.name);
    });
  }

  Future<String> createKriterEkleDialog(BuildContext context) {
    TextEditingController _kriterAdi = new TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Kriter Adı"),
            content: TextField(
              controller: _kriterAdi,
            ),
            actions: [
              MaterialButton(
                elevation: 5,
                child: Text("Kaydet"),
                onPressed: () {
                  if (_kriterAdi.text.length == 0) {
                    Fluttertoast.showToast(
                        msg: "Boş bırakılamaz!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey[200],
                        textColor: Colors.black,
                        fontSize: 14.0);
                  } else {
                    Navigator.of(context).pop(_kriterAdi.text.toString());
                  }
                },
              )
            ],
          );
        });
  }

  String dersGunu = gunler[0];
  int dersSaat = saatler[0];
  int dersBitisSaat = saatler[1];
  int dersDakika = dakikalar[0];
  int dersBitisDakika = dakikalar[0];
  @override
  void initState() {
    super.initState();
    configEasyLoading();
    clearTextFields();
  }

  void clearTextFields() {
    _dersKoduController.clear();
    _dersAdiController.clear();
    _dersTarihiController.clear();
    _vizeYuzde.clear();
    _finalYuzde.clear();
    listDynamic.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await getAllDersByInstructor(
              Provider.of<UserNotifier>(context, listen: false),
              Provider.of<DersNotifier>(context, listen: false));
        },
        child: Consumer<DersNotifier>(
          builder: (context, dersNotifier, _) => DersWaiter(),
        ),
      ), //DersWaiter(),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text("Ders ekle"),
        onPressed: () {
          showDersEkleDialog(context);
          print("Ders eklendi");
        },
      ),
    );
  }

  void showDersEkleDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return showDersEkleCustomDialog(context);
        });
  }

  Widget showDersEkleCustomDialog(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        listDynamic.clear();
        _dersKoduController.clear();
        _dersAdiController.clear();
        _dersTarihiController.clear();
        _vizeYuzde.clear();
        _finalYuzde.clear();
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
                              Navigator.of(context).pop();
                              listDynamic.clear();
                              _dersKoduController.clear();
                              _dersAdiController.clear();
                              _dersTarihiController.clear();
                              _vizeYuzde.clear();
                              _finalYuzde.clear();
                            }),
                        RaisedButton(
                          onPressed: () async {
                            bool dynmaicHata = false;
                            listDynamic.forEach((element) {
                              dynmaicHata = element.controller.text.isEmpty;
                            });
                            if (_dersKoduController.text.isEmpty ||
                                _dersAdiController.text.isEmpty ||
                                _dersTarihiController.text.isEmpty ||
                                _vizeYuzde.text.isEmpty ||
                                _finalYuzde.text.isEmpty ||
                                dynmaicHata) {
                              Fluttertoast.showToast(
                                  msg: "Boş alanları doldurun!",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.grey[200],
                                  textColor: Colors.black,
                                  fontSize: 14.0);
                            } else {
                              print("dogru yer");
                              int vizeYuzdesi =
                                  int.parse(_vizeYuzde.text.toString());
                              int finalYuzdesi =
                                  int.parse(_finalYuzde.text.toString());
                              int dynamicYuzde = 0;
                              listDynamic.forEach((element) {
                                dynamicYuzde += int.parse(
                                    element.controller.text.toString());
                              });
                              if (dynamicYuzde + finalYuzdesi + vizeYuzdesi !=
                                  100) {
                                Fluttertoast.showToast(
                                    msg: "Not yüzdelerinde hata var!",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.grey[200],
                                    textColor: Colors.black,
                                    fontSize: 14.0);
                              } else {
                                AddDersDto dersDto = new AddDersDto();
                                dersDto.dersAdi = _dersAdiController.text;
                                dersDto.dersKodu = _dersKoduController.text;
                                dersDto.startDay = dersGunu;
                                dersDto.startTime =
                                    dersSaat.toString() + dersDakika.toString();
                                dersDto.endTime = dersBitisSaat.toString() +
                                    dersBitisDakika.toString();
                                dersDto.dersDegerlendirmes.add({
                                  'name': "Vize",
                                  'yuzde': int.parse(_vizeYuzde.text)
                                });
                                dersDto.dersDegerlendirmes.add({
                                  'name': "Final",
                                  'yuzde': int.parse(_finalYuzde.text)
                                });
                                listDynamic.forEach((element) {
                                  dersDto.dersDegerlendirmes.add({
                                    'name': element.name,
                                    'yuzde': int.parse(element.controller.text)
                                  });
                                });
                                UserNotifier userNotifier =
                                    Provider.of<UserNotifier>(context,
                                        listen: false);
                                EasyLoading.show(
                                  status: "Kaydediliyor...",
                                  dismissOnTap: false,
                                );
                                //call api to save ders
                                await addDers(dersDto, userNotifier)
                                    .then((value) {
                                  if (value) {
                                    EasyLoading.dismiss();
                                    Navigator.of(context).pop();
                                    Fluttertoast.showToast(
                                        msg: "Ders başarıyla kaydedildi.",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.grey[200],
                                        textColor: Colors.black,
                                        fontSize: 14.0);
                                    clearTextFields();
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
                                    clearTextFields();
                                  }
                                });
                              }
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
                    "Yeni Ders",
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
                          controller: _dersKoduController,
                          inputFormatters: [
                            UpperCaseTextFormatter(),
                            FilteringTextInputFormatter.allow(
                                RegExp("[0-9a-zA-Z]")),
                          ],
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
                              hintText: 'Ders Kodu'),
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
                          controller: _dersAdiController,
                          textCapitalization: TextCapitalization.words,
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
                              hintText: 'Ders Adı'),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                              isDismissible: false,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(20),
                                      topLeft: Radius.circular(20))),
                              context: context,
                              builder: (builder) {
                                return StatefulBuilder(builder:
                                    (BuildContext context,
                                        StateSetter setState) {
                                  return Container(
                                      height: getProportionateScreenWidth(200),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20))),
                                      //height: MediaQuery.of(context).size.height * .45,
                                      padding: EdgeInsets.only(
                                          top: 20,
                                          left: 30,
                                          bottom: 5,
                                          right: 30),
                                      child: Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text("Ders günü"),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  DropdownButton(
                                                    value: dersGunu,
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        dersGunu = newValue;
                                                        print(dersGunu);
                                                      });
                                                    },
                                                    items:
                                                        gunler.map((gunItem) {
                                                      return DropdownMenuItem(
                                                        child: Text(gunItem),
                                                        value: gunItem,
                                                      );
                                                    }).toList(),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text("Ders baş. saati"),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  DropdownButton(
                                                    //menuMaxHeight: 500,
                                                    value: dersSaat,
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        dersSaat = newValue;
                                                      });
                                                    },
                                                    items:
                                                        saatler.map((saatItem) {
                                                      return DropdownMenuItem(
                                                        child: Text(saatItem
                                                            .toString()),
                                                        value: saatItem,
                                                      );
                                                    }).toList(),
                                                  ),
                                                  DropdownButton(
                                                    //menuMaxHeight: 500,
                                                    value: dersDakika,
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        dersDakika = newValue;
                                                      });
                                                    },
                                                    items: dakikalar
                                                        .map((dakikaItem) {
                                                      return DropdownMenuItem(
                                                        child: Text(dakikaItem
                                                            .toString()),
                                                        value: dakikaItem,
                                                      );
                                                    }).toList(),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text("Ders bitiş saati"),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  DropdownButton(
                                                    //menuMaxHeight: 500,
                                                    value: dersBitisSaat,
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        dersBitisSaat =
                                                            newValue;
                                                      });
                                                    },
                                                    items:
                                                        saatler.map((saatItem) {
                                                      return DropdownMenuItem(
                                                        child: Text(saatItem
                                                            .toString()),
                                                        value: saatItem,
                                                      );
                                                    }).toList(),
                                                  ),
                                                  DropdownButton(
                                                    //menuMaxHeight: 500,
                                                    value: dersBitisDakika,
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        dersBitisDakika =
                                                            newValue;
                                                      });
                                                    },
                                                    items: dakikalar
                                                        .map((dakikaItem) {
                                                      return DropdownMenuItem(
                                                        child: Text(dakikaItem
                                                            .toString()),
                                                        value: dakikaItem,
                                                      );
                                                    }).toList(),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          RaisedButton(
                                            onPressed: () {
                                              if (dersBitisSaat < dersSaat) {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Ders saatlerini kontrol edin!",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                    textColor: Colors.black,
                                                    fontSize: 14.0);
                                              } else if (dersBitisSaat ==
                                                      dersSaat &&
                                                  dersDakika >=
                                                      dersBitisDakika) {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Ders saatlerini kontrol edin!",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                    textColor: Colors.black,
                                                    fontSize: 14.0);
                                              } else {
                                                String _dersBitisDakika =
                                                    dersBitisDakika.toString();
                                                String _dersBaslangicDakika =
                                                    dersDakika.toString();
                                                if (dersBitisDakika == 0) {
                                                  _dersBitisDakika = "00";
                                                }
                                                if (dersDakika == 0) {
                                                  _dersBaslangicDakika = "00";
                                                }
                                                _dersTarihiController.text =
                                                    dersGunu +
                                                        " - " +
                                                        "Başlangıç " +
                                                        dersSaat.toString() +
                                                        ":" +
                                                        _dersBaslangicDakika +
                                                        "  Bitiş " +
                                                        dersBitisSaat
                                                            .toString() +
                                                        ":" +
                                                        _dersBitisDakika;
                                                Navigator.of(context).pop();
                                              }
                                            },
                                            //disabledColor: kPrimaryColor.withOpacity(0.5),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Text(
                                              "Kaydet",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14),
                                            ),
                                          )
                                        ],
                                      ));
                                });
                              });
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                              top: getProportionateScreenWidth(15)),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                top: BorderSide(
                                    width: 1, color: Colors.grey[300]),
                                bottom: BorderSide(
                                    width: 1, color: Colors.grey[300])),
                          ),
                          child: TextField(
                            textCapitalization: TextCapitalization.characters,
                            enabled: false,
                            controller: _dersTarihiController,
                            onChanged: (text) {},
                            cursorColor: Colors.black.withOpacity(.6),
                            keyboardType: TextInputType.text,
                            maxLines: null,
                            autofocus: false,
                            autocorrect: false,
                            cursorWidth: 1.1,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                    left: 15, bottom: 15, top: 15, right: 15),
                                hintStyle: TextStyle(color: Colors.grey),
                                hintText: 'Ders Tarihi'),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                                top: getProportionateScreenWidth(15)),
                            width: getProportionateScreenWidth(90),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                  top: BorderSide(
                                      width: 1, color: Colors.grey[300]),
                                  bottom: BorderSide(
                                      width: 1, color: Colors.grey[300])),
                            ),
                            child: TextField(
                              controller: _vizeYuzde,
                              cursorColor: Colors.black.withOpacity(.6),
                              keyboardType: TextInputType.number,
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
                                  hintText: 'Vize(%)'),
                            ),
                          ),
                          SizedBox(
                            height: 36,
                            width: getProportionateScreenWidth(100),
                            child: FloatingActionButton.extended(
                              icon: Icon(
                                Icons.add,
                                size: 14,
                              ),
                              label: Text(
                                "Kriter ekle",
                                style: TextStyle(fontSize: 10),
                              ),
                              onPressed: () {
                                createKriterEkleDialog(context).then((value) {
                                  if (value != null) {
                                    listDynamic.add(new DynamicWidget(
                                      name: value,
                                    ));
                                  }

                                  setState(() {});
                                });
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: getProportionateScreenWidth(15)),
                            width: getProportionateScreenWidth(90),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                  top: BorderSide(
                                      width: 1, color: Colors.grey[300]),
                                  bottom: BorderSide(
                                      width: 1, color: Colors.grey[300])),
                            ),
                            child: TextField(
                              controller: _finalYuzde,
                              onChanged: (text) {},
                              cursorColor: Colors.black.withOpacity(.6),
                              keyboardType: TextInputType.number,
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
                                  hintText: 'Final(%)'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    width: double.infinity,
                    height: 150,
                    child: Column(
                      children: [
                        Flexible(
                            child: new ListView.builder(
                                itemCount: listDynamic.length,
                                itemBuilder: (_, index) => listDynamic[index])),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class DersCard extends StatelessWidget {
  const DersCard({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DersNotifier _dersNotifier =
        Provider.of<DersNotifier>(context, listen: false);
    StudentNotifier _studentNotifier =
        Provider.of<StudentNotifier>(context, listen: false);
    return ListView.builder(
        itemCount: _dersNotifier.dersList.length,
        itemBuilder: (BuildContext context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                print("object");
                //showDersEklePopUp(context, _dersNotifier.dersList[index]);
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey[200]),
                child: Padding(
                  padding:
                      EdgeInsets.only(top: 15, bottom: 15, left: 8, right: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _dersNotifier.dersList[index].dersKodu +
                                " - " +
                                _dersNotifier.dersList[index].dersAdi,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(_dersNotifier.dersList[index].startDay +
                              "  " +
                              _dersNotifier.dersList[index].startTime +
                              " - " +
                              _dersNotifier.dersList[index].endTime)
                        ],
                      ),
                      TextButton(
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                        ),
                        onPressed: () {
                          SmartDialog.show(
                              alignmentTemp: Alignment.centerRight,
                              clickBgDismissTemp: true,
                              widget: _contentWidget(
                                  dersId: _dersNotifier.dersList[index].id,
                                  maxWidth: 260,
                                  userNotifier: Provider.of<UserNotifier>(
                                      context,
                                      listen: false),
                                  studentNotifier: _studentNotifier));
                        },
                        child: Text('Öğrenci Ekle'),
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(_dersNotifier.dersList[index].studentsCount
                                  .toString() +
                              "  "),
                          InkWell(
                              onTap: () {
                                SmartDialog.show(
                                    alignmentTemp: Alignment.centerRight,
                                    clickBgDismissTemp: true,
                                    widget: _dersiAlanlar(
                                        dersId:
                                            _dersNotifier.dersList[index].id,
                                        dersAdi: _dersNotifier
                                                .dersList[index].dersKodu +
                                            " - " +
                                            _dersNotifier
                                                .dersList[index].dersAdi,
                                        maxWidth: 260,
                                        ders: _dersNotifier.dersList[index],
                                        userNotifier: Provider.of<UserNotifier>(
                                            context,
                                            listen: false),
                                        studentNotifier: _studentNotifier));
                              },
                              child: Icon(FontAwesome.users)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _dersiAlanlar({
    double maxWidth = double.infinity,
    double maxHeight = double.infinity,
    StudentNotifier studentNotifier,
    UserNotifier userNotifier,
    Ders ders,
    int dersId,
    String dersAdi,
  }) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 10)
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: dersAdi,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                  children: const <TextSpan>[
                    TextSpan(
                        text: ' dersini alan öğrenciler',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: ders.studentsCount,
                itemBuilder: (BuildContext context, int index) {
                  return Material(
                    child: Column(children: [
                      //内容
                      InkWell(
                        onTap: () async {
                          SmartDialog.dismiss();
                          EasyLoading.show(
                            status: "Kaydediliyor...",
                            dismissOnTap: false,
                          );
                          await addDersToOgrenci(
                                  studentNotifier.studentList[index].id,
                                  dersId,
                                  userNotifier)
                              .then((value) {
                            if (value) {
                              EasyLoading.dismiss();
                              //Navigator.of(context).pop();
                              Fluttertoast.showToast(
                                  msg: "Öğrenci derse kaydedildi.",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.grey[200],
                                  textColor: Colors.black,
                                  fontSize: 14.0);
                            } else {
                              EasyLoading.dismiss();
                              //Navigator.of(context).pop();
                              Fluttertoast.showToast(
                                  msg: "Öğrenci zaten bu derse kayıtlı.",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.grey[200],
                                  textColor: Colors.black,
                                  fontSize: 14.0);
                            }
                          });
                        },
                        child: ListTile(
                          leading: Icon(Icons.person),
                          trailing: Wrap(
                            spacing: 12, // space between two icons
                            children: <Widget>[
                              IconButton(
                                onPressed: () async {
                                  SmartDialog.dismiss();
                                  EasyLoading.show(
                                    status: "Siliniyor...",
                                    dismissOnTap: false,
                                  );
                                  await deleteDersFromOgrenci(
                                          studentNotifier.studentList[index].id,
                                          dersId,
                                          userNotifier)
                                      .then((value) {
                                    if (value) {
                                      EasyLoading.dismiss();
                                      //Navigator.of(context).pop();
                                      Fluttertoast.showToast(
                                          msg: "Öğrenci dersi bıraktı.",
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.grey[200],
                                          textColor: Colors.black,
                                          fontSize: 14.0);
                                    } else {
                                      EasyLoading.dismiss();
                                      //Navigator.of(context).pop();
                                      Fluttertoast.showToast(
                                          msg:
                                              "Öğrenci bu dersi zaten almıyor.",
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.grey[200],
                                          textColor: Colors.black,
                                          fontSize: 14.0);
                                    }
                                  });
                                },
                                icon: Icon(FontAwesome5.minus_square),
                                color: Colors.red,
                              ), // // icon-2
                            ],
                          ),
                          title: Text(ders.students[index]["firstName"] +
                              " " +
                              ders.students[index]["lastName"]),
                        ),
                      ),

                      //分割线
                      Container(
                          height: 1, color: Colors.black.withOpacity(0.1)),
                    ]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contentWidget({
    double maxWidth = double.infinity,
    double maxHeight = double.infinity,
    StudentNotifier studentNotifier,
    UserNotifier userNotifier,
    int dersId,
  }) {
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: maxWidth),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 10)
        ],
      ),
      child: ListView.builder(
        itemCount: studentNotifier.studentList.length,
        itemBuilder: (BuildContext context, int index) {
          return Material(
            child: Column(children: [
              //内容
              InkWell(
                onTap: () async {
                  SmartDialog.dismiss();
                  EasyLoading.show(
                    status: "Kaydediliyor...",
                    dismissOnTap: false,
                  );
                  await addDersToOgrenci(studentNotifier.studentList[index].id,
                          dersId, userNotifier)
                      .then((value) {
                    if (value) {
                      EasyLoading.dismiss();
                      //Navigator.of(context).pop();
                      Fluttertoast.showToast(
                          msg: "Öğrenci derse kaydedildi.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.grey[200],
                          textColor: Colors.black,
                          fontSize: 14.0);
                    } else {
                      EasyLoading.dismiss();
                      //Navigator.of(context).pop();
                      Fluttertoast.showToast(
                          msg: "Öğrenci zaten bu derse kayıtlı.",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.grey[200],
                          textColor: Colors.black,
                          fontSize: 14.0);
                    }
                  });
                },
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text(studentNotifier.studentList[index].firstName +
                      " " +
                      studentNotifier.studentList[index].lastName),
                ),
              ),

              //分割线
              Container(height: 1, color: Colors.black.withOpacity(0.1)),
            ]),
          );
        },
      ),
    );
  }
}

void showDersDuzenleDialog(BuildContext context, ders) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return showDersDuzenleCustomDialog(context, ders);
      });
}

Widget showDersDuzenleCustomDialog(BuildContext context, ders) {
  print(ders.toMap());
  final _dersKoduController = TextEditingController();
  final _dersAdiController = TextEditingController();
  final _dersTarihiController = TextEditingController();
  final _vizeYuzde = TextEditingController();
  final _finalYuzde = TextEditingController();
  return WillPopScope(
    onWillPop: () async {
      /*listDynamic.clear();
        _dersKoduController.clear();
        _dersAdiController.clear();
        _dersTarihiController.clear();
        _vizeYuzde.clear();
        _finalYuzde.clear();*/
      Navigator.of(context).pop();
      return false;
    },
    child: Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: Colors.grey[200], //this right here

      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 8.0, right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.cancel)),
                      RaisedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
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
                )
              ],
            ),
          ),
        );
      }),
    ),
  );
}

void showDersEklePopUp(BuildContext context, ders) {
  showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), topLeft: Radius.circular(20))),
      context: context,
      builder: (builder) {
        return Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            height: MediaQuery.of(context).size.height * .15,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    showDersDuzenleDialog(context, ders);
                  },
                  child: Container(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        "Düzenle",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(),
                InkWell(
                  onTap: () {},
                  child: Text(
                    "Sil",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ),
              ],
            ));
      });
}

class DynamicWidget extends StatelessWidget {
  final name;
  TextEditingController controller = new TextEditingController();

  DynamicWidget({Key key, this.name}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: getProportionateScreenWidth(15)),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(width: 1, color: Colors.grey[300]),
            bottom: BorderSide(width: 1, color: Colors.grey[300])),
      ),
      child: TextField(
        controller: controller,
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
            contentPadding:
                EdgeInsets.only(left: 15, bottom: 15, top: 15, right: 15),
            hintStyle: TextStyle(color: Colors.grey),
            hintText: name.toString() + "(%)"),
      ),
    );
  }
}

class DersWaiter extends StatefulWidget {
  @override
  _DersWaiterState createState() => _DersWaiterState();
}

class _DersWaiterState extends State<DersWaiter> {
  bool isLoading = true;
  UserNotifier userNotifier;
  DersNotifier dersNotifier;
  @override
  void initState() {
    dersNotifier = Provider.of<DersNotifier>(context, listen: false);
    userNotifier = Provider.of<UserNotifier>(context, listen: false);
    if (dersNotifier.dersList.isEmpty) {
      getAllDersByInstructor(userNotifier, dersNotifier).then((value) {
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
    return !isLoading ? DersCard() : ShimmerDers();
  }
}

class ShimmerDers extends StatelessWidget {
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
