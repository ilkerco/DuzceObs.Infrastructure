import 'package:flutter/material.dart';

class DersMateryalleriScreen extends StatefulWidget {
  @override
  _DersMateryalleriScreenState createState() => _DersMateryalleriScreenState();
}

class _DersMateryalleriScreenState extends State<DersMateryalleriScreen> {
  @override
  void initState() {
    print("DersMateryalleri page cagrildi");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text("Ders Materyalleri"),
        ),
      ),
    );
  }
}
