import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:obsProject/colors.dart';
import 'package:obsProject/main.dart';
import 'package:obsProject/services/api/DuzceObsApi.dart';
import 'package:obsProject/size_config.dart';
import 'package:obsProject/helpers/EmailValidator.dart';

//YEDEK
/*
class LoginSignupScreen extends StatefulWidget {
  @override
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  bool isSignupScreen = true;
  bool _obscureText = true;
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Palette.backgroundColor,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: Container(
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * .4,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(100)),
                          gradient: LinearGradient(
                              colors: [Colors.blue, Colors.blue[200]],
                              end: Alignment.bottomCenter,
                              begin: Alignment.topCenter)),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Image.asset(
                              "assets/unilogokucuk.png",
                              height: 32,
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/obsgirisRR.png",
                                  height: 128,
                                ),
                                Text(
                                  "Düzce Üniversitesi",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Öğrenci Bilgilendirme Sistemi",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          /* Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Text(
                                  "Düzce Üniversitesi Öğrenci Bilgilendirme Sistemi",
                                  
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                )),
                          )*/
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white),
                      margin: EdgeInsets.only(
                          top: 40, left: 20, right: 20, bottom: 20),
                      child: TextFormField(
                        controller: _emailTextController,
                        onEditingComplete: () {},
                        autovalidate: true,
                        validator: (value) {
                          if (value.isValidEmail() || value.length < 5) {
                            return null;
                          }
                          return "Geçerli bir mail adresi girin";
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.email),
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 15, bottom: 15, top: 15, right: 15),
                            hintStyle: TextStyle(color: Colors.grey),
                            hintText: 'Email'),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white),
                      margin: EdgeInsets.only(
                          top: 10, left: 20, right: 20, bottom: 20),
                      child: TextFormField(
                        controller: _passwordTextController,
                        obscureText: _obscureText,
                        validator: (value) {
                          if (value.length == 0) {
                            return "Şifrenizi girin";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.lock,
                            ),
                            suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                child: Icon(Icons.remove_red_eye_sharp)),
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 15, bottom: 15, top: 15, right: 15),
                            hintStyle: TextStyle(color: Colors.grey),
                            hintText: 'Şifre'),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          if (_formKey.currentState.validate()) {
                            print("calling login api");
                            login(_emailTextController.text,
                                _passwordTextController.text);
                          }
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Text(
                                "Giriş Yap",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            )),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
*/
