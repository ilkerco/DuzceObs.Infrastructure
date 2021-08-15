import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:obsProject/models/dersWithGrades.dart';
import 'package:obsProject/notifiers/user_notifier.dart';
import 'package:obsProject/services/api/DuzceObsApi.dart';
import 'package:provider/provider.dart';

import '../../size_config.dart';

class Derslerim extends StatefulWidget {
  @override
  _DerslerimState createState() => _DerslerimState();
}

class _DerslerimState extends State<Derslerim> {
  List<DersWithGrades> _sinavSonuclari;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  bool harfNotKontrol(dersKriters) {
    for (int i = 0; i < dersKriters.length; i++) {
      if (dersKriters[i]["not"] == null) {
        return false;
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getStudentsDersWithGrades(
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
              print(_sinavSonuclari[2].dersKriters[0]["not"]);
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
                          ],
                        ),
                        collapsed: Padding(
                          padding: const EdgeInsets.only(left: 18.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_sinavSonuclari[index].instructorName +
                                  " - " +
                                  _sinavSonuclari[index].dersGunu),
                              Divider()
                            ],
                          ),
                        ),
                        expanded: Container(
                          color: Colors.grey[200],
                          child: Padding(
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
                                            Icon(Icons.person_outline_outlined),
                                          ],
                                        ),
                                        Container(
                                          width:
                                              getProportionateScreenWidth(70),
                                          child: Text(
                                            Provider.of<UserNotifier>(context,
                                                        listen: false)
                                                    .CurrentUser
                                                    .firstName +
                                                " " +
                                                Provider.of<UserNotifier>(
                                                        context,
                                                        listen: false)
                                                    .CurrentUser
                                                    .lastName,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 2,
                                        ),
                                        Text(Provider.of<UserNotifier>(context,
                                                listen: false)
                                            .CurrentUser
                                            .tc),
                                        SizedBox(
                                          height: 2,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: getProportionateScreenWidth(150),
                                      child: ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          itemCount: _sinavSonuclari[index]
                                              .dersKriters
                                              .length,
                                          itemBuilder:
                                              (BuildContext context, index3) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Card(
                                                child: ListTile(
                                                    title: Text(_sinavSonuclari[index]
                                                                .dersKriters[index3][
                                                            "dersDegerlendirmeName"] +
                                                        "(%" +
                                                        _sinavSonuclari[index]
                                                            .dersKriters[index3]
                                                                ["yuzde"]
                                                            .toString() +
                                                        ")"),
                                                    subtitle: _sinavSonuclari[index]
                                                                    .dersKriters[index3]
                                                                ["not"] !=
                                                            null
                                                        ? Text(_sinavSonuclari[index]
                                                            .dersKriters[index3]
                                                                ["not"]
                                                            .toString())
                                                        : Text(" - ")),
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
                                          harfNotKontrol(_sinavSonuclari[index]
                                                  .dersKriters)
                                              ? Card(
                                                  child: ListTile(
                                                    title: Text("Harf Notu"),
                                                    subtitle: calculateHarfNot(
                                                        _sinavSonuclari[index]
                                                            .dersKriters),
                                                  ),
                                                )
                                              : Card(
                                                  child: ListTile(
                                                    title: Text("Harf Notu"),
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
                          ),
                        ),
                      );
                    }),
              );
            }
          }
        },
      ),
    );
  }
}
