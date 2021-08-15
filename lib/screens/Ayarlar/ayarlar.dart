import 'package:flutter/material.dart';

class AyarlarScreen extends StatefulWidget {
  @override
  _AyarlarScreenState createState() => _AyarlarScreenState();
}

class _AyarlarScreenState extends State<AyarlarScreen> {
  @override
  void initState() {
    print("Ayarlar page cagrildi");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text("Ayarlar PAGE"),
        ),
      ),
    );
  }
}
