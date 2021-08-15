import 'package:flutter/material.dart';

class DuyurularScreen extends StatefulWidget {
  @override
  _DuyurularScreenState createState() => _DuyurularScreenState();
}

class _DuyurularScreenState extends State<DuyurularScreen> {
  @override
  void initState() {
    print("Duyurular page cagrildi");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text("Duyuru yayınla"),
        onPressed: () {
          //showOgrEkleDialog(context);
          print("Ders eklendi");
        },
      ),
      body: Container(
        child: Center(
          child: Text("Duyurular PAGE"),
        ),
      ),
    );
  }
}
