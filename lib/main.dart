import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:obsProject/models/AppPropertiesBloc.dart';
import 'package:obsProject/notifiers/ders_notifier.dart';
import 'package:obsProject/notifiers/student_notifier.dart';
import 'package:obsProject/notifiers/user_notifier.dart';
import 'package:obsProject/screens/Ayarlar/ayarlar.dart';
import 'package:obsProject/screens/DersMateryalleri/dersmateryalleri.dart';
import 'package:obsProject/screens/DersProgram%C4%B1/dersprogrami.dart';
import 'package:obsProject/screens/Dersler/dersler.dart';
import 'package:obsProject/screens/Derslerim/derslerim.dart';
import 'package:obsProject/screens/Duyurular/duyurular.dart';
import 'package:obsProject/screens/Ogrenciler/ogrenciler.dart';
import 'package:obsProject/screens/SinavSonuclari/sinavsonuclari.dart';
import 'package:obsProject/services/api/DuzceObsApi.dart';
import 'package:obsProject/size_config.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';

import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
  runApp(LoginPageUI());
}

enum Section {
  DERSPROGRAMI,
  DERSPROGRAMIM,
  DERSLER,
  DERSLERIM,
  DERSMATERYALLERI,
  OGRENCILER,
  SINAVSONUCLARI,
  SINAVSONUCLARIM,
  DUYURULAR,
  AYARLAR,
  CIKIS
}

class LoginPageUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          SfGlobalLocalizations.delegate
        ],
        supportedLocales: [const Locale('tr')],
        locale: const Locale('tr'),
        debugShowCheckedModeBanner: false,
        title: "Login Signup UI",
        home: LoginScreen(),
        builder:
            EasyLoading.init(builder: (BuildContext context, Widget child) {
          return FlutterSmartDialog(child: child);
        }),
      ),
      providers: [
        ChangeNotifierProvider(create: (_) => UserNotifier()),
        ChangeNotifierProvider(create: (_) => StudentNotifier()),
        ChangeNotifierProvider(create: (_) => DersNotifier()),
      ],
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String accessToken;
  UserNotifier _userNotifier;
  bool isLoggedBefore = false;
  Future<String> _authUser(LoginData data) async {
    print('Name: ${data.name}, Password: ${data.password}');
    return await login(data.name, data.password, _userNotifier)
        .then((value) async {
      if (value.success) {
        return null;
      } else {
        print("false döndü");
        return value.message;
      }
    });
  }

  @override
  void didChangeDependencies() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String accessToken = preferences.getString("accessToken");

    if (accessToken != null) {
      setState(() {
        isLoggedBefore = true;
      });
      await Future.delayed(Duration(seconds: 2));
      UserNotifier userNotifier =
          Provider.of<UserNotifier>(context, listen: false);
      await getCurrentUser(userNotifier, accessToken).then((value) {
        if (!value) {
          print("error while logging");
        } else {
          EasyLoading.showToast(
              userNotifier.CurrentUser.firstName +
                  " " +
                  userNotifier.CurrentUser.lastName +
                  " olarak giriş yapıldı.",
              toastPosition: EasyLoadingToastPosition.bottom);
          //EasyLoading.dismiss();
          EasyLoading.dismiss();
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (BuildContext context) {
            return MyHomePage();
          }));
        }
      });
    } else {
      print("there is no access token saved");
      setState(() {});
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _userNotifier = Provider.of<UserNotifier>(context, listen: false);

    super.initState();
  }

  void configEasyLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.dark
      ..maskType = EasyLoadingMaskType.black
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

  Widget showLoading(BuildContext context) {
    EasyLoading.show(
        status: "Lütfen Bekleyin...",
        dismissOnTap: false,
        maskType: EasyLoadingMaskType.black);
    return Container(
      child: Center(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterLogin(
          hideSignUpButton: true,
          title: "Düzce Üniversitesi",
          theme: LoginTheme(titleStyle: TextStyle(fontSize: 30)),
          hideForgotPasswordButton: true,
          logo: 'assets/unilogokucuk.png',
          footer: "Öğrenci Bilgilendirme Sistemi",
          messages: LoginMessages(loginButton: "Giriş", passwordHint: "Şifre"),
          onLogin: _authUser, //_authUser,
          onSubmitAnimationCompleted: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (BuildContext context) {
              return MyHomePage();
            }));
          },
        ),
        isLoggedBefore ? showLoading(context) : Container()
      ],
    );
  }
}

/*class LoginScreen1 extends StatelessWidget {
  Future<String> _authUser(LoginData data) async {
    print('Name: ${data.name}, Password: ${data.password}');
    return await login(data.name, data.password).then((value) {
      if (value) {
        return null;
      } else {
        print("false döndü");
        return "Kullanıcı bulunamadı";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _userNotifier = Provider.of<UserNotifier>(context, listen: false);
    return FlutterLogin(
      hideSignUpButton: true,
      title: "Düzce Üniversitesi",
      theme: LoginTheme(titleStyle: TextStyle(fontSize: 30)),
      hideForgotPasswordButton: true,
      logo: 'assets/unilogokucuk.png',
      footer: "Öğrenci Bilgilendirme Sistemi",
      messages: LoginMessages(loginButton: "Giriş", passwordHint: "Şifre"),
      onLogin: _authUser, //_authUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
          return MyHomePage();
        }));
      },
    );
  }
}
*/
/*class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: [
          const Locale('ru', "RU"),
          const Locale('en', "US"),
        ],
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(),
      ),
      providers: [ChangeNotifierProvider(create: (_) => UserNotifier())],
    );
  }
}*/

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final appPropertiesBloc = AppPropertiesBloc();
  UserNotifier _userNotifier;
  DersNotifier _dersNotifier;
  StudentNotifier _studentNotifier;

  @override
  void initState() {
    _userNotifier = Provider.of<UserNotifier>(context, listen: false);
    getAllDersByInstructor(
        _userNotifier, Provider.of<DersNotifier>(context, listen: false));
    getAllStudents(
        _userNotifier, Provider.of<StudentNotifier>(context, listen: false));
    super.initState();
  }

  var section = Section.DERSPROGRAMI;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    Widget body;
    switch (section) {
      case Section.DERSLER:
        body = DerslerPage();
        appPropertiesBloc.updateTitle("Dersler");
        break;
      case Section.DERSLERIM:
        body = Derslerim();
        appPropertiesBloc.updateTitle("Derslerim");
        break;
      case Section.OGRENCILER:
        body = OgrencilerScreen();
        appPropertiesBloc.updateTitle("Ogrenciler");
        break;
      case Section.DERSPROGRAMI:
        body = DersProgramiScreen();
        appPropertiesBloc.updateTitle("Ders Programi");
        break;
      case Section.DERSPROGRAMIM:
        body = DersProgramiScreen();
        appPropertiesBloc.updateTitle("Ders Programim");
        break;
      case Section.DERSMATERYALLERI:
        body = DersMateryalleriScreen();
        appPropertiesBloc.updateTitle("Ders Materyalleri");
        break;
      case Section.SINAVSONUCLARI:
        body = SinavSonuclariScreen();
        appPropertiesBloc.updateTitle("Sinav Sonuclari");
        break;
      case Section.SINAVSONUCLARIM:
        body = SinavSonuclariScreen();
        appPropertiesBloc.updateTitle("Sinav Sonuclarim");
        break;
      case Section.DUYURULAR:
        body = DuyurularScreen();
        appPropertiesBloc.updateTitle("Duyurular");
        break;
      case Section.AYARLAR:
        body = AyarlarScreen();
        appPropertiesBloc.updateTitle("Ayarlar");
        break;
      case Section.CIKIS:
        break;
    }
    print(_userNotifier.CurrentUser.userType);
    return Scaffold(
      drawer: Drawer(
          child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_userNotifier.CurrentUser.firstName +
                _userNotifier.CurrentUser.lastName),
            accountEmail: Text(_userNotifier.CurrentUser.email),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  "https://yt3.ggpht.com/ytc/AKedOLTjaz6FRdwA8gTingD5srx6cS0IGUPX0lPcn0UGaQ=s900-c-k-c0x00ffffff-no-rj",
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            decoration: BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                    image: NetworkImage(
                        "https://static.daktilo.com/sites/74/uploads/2021/04/21/51240271-1619011389.jpg"),
                    fit: BoxFit.cover)),
          ),
          _userNotifier.CurrentUser.userType == "Instructor"
              ? ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text("Ders Programı"),
                  onTap: () {
                    setState(() {
                      section = Section.DERSPROGRAMI;
                    });
                    Navigator.of(context).pop();
                  },
                )
              : ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text("Ders Programım"),
                  onTap: () {
                    setState(() {
                      section = Section.DERSPROGRAMIM;
                    });
                    Navigator.of(context).pop();
                  },
                ),
          _userNotifier.CurrentUser.userType == "Instructor"
              ? ListTile(
                  leading: Icon(Icons.book_online),
                  title: Text("Dersler"),
                  onTap: () {
                    setState(() {
                      section = Section.DERSLER;
                    });
                    Navigator.of(context).pop();
                  },
                )
              : ListTile(
                  leading: Icon(Icons.book_online),
                  title: Text("Derslerim"),
                  onTap: () {
                    setState(() {
                      section = Section.DERSLERIM;
                    });
                    Navigator.of(context).pop();
                  },
                ),
          /*
          ListTile(
            leading: Icon(Icons.bookmarks),
            title: Text("Ders Materyalleri"),
            onTap: () {
              setState(() {
                section = Section.DERSMATERYALLERI;
              });
              Navigator.of(context).pop();
            },
          ),*/
          _userNotifier.CurrentUser.userType == "Instructor"
              ? ListTile(
                  leading: Icon(Icons.supervised_user_circle),
                  title: Text("Öğrenciler"),
                  onTap: () {
                    setState(() {
                      section = Section.OGRENCILER;
                    });
                    Navigator.of(context).pop();
                  },
                )
              : Container(),
          _userNotifier.CurrentUser.userType == "Instructor"
              ? ListTile(
                  leading: Icon(Icons.grade),
                  title: Text("Sınav Sonuçları"),
                  onTap: () {
                    setState(() {
                      section = Section.SINAVSONUCLARI;
                    });
                    Navigator.of(context).pop();
                  },
                )
              : Container(),
          /*ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Duyurular"),
            onTap: () {
              setState(() {
                section = Section.DUYURULAR;
              });
              Navigator.of(context).pop();
            },
          ),*/
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Çıkış"),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.clear();
              /*Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false);*/
              /*SchedulerBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false);
              });*/
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (BuildContext context) {
                return LoginScreen();
              }));
            },
          ),
        ],
      )),
      appBar: AppBar(
        title: StreamBuilder<Object>(
          stream: appPropertiesBloc.titleStream,
          initialData: "Düzce Üniversitesi Obs",
          builder: (context, snapshot) {
            return Text(snapshot.data);
          },
        ),
      ),
      /*appBar: AppBar(
        title: Text("Düzce Universitesi Obs"),
      ),*/
      body: body,
    );
  }
}

class NavigationDrawerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          accountName: Text('Şeyhmuz'),
          accountEmail: Text('Şeyhmuz@duzce.edu.tr'),
          currentAccountPicture: CircleAvatar(
            child: ClipOval(
              child: Image.network(
                "https://yt3.ggpht.com/ytc/AKedOLTjaz6FRdwA8gTingD5srx6cS0IGUPX0lPcn0UGaQ=s900-c-k-c0x00ffffff-no-rj",
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
          ),
          decoration: BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                  image: NetworkImage(
                      "https://lh3.googleusercontent.com/proxy/pmHnLc3kjdhHO-0HK7mR860YwNiI-nMCn2vqH9ZOSpkqvBc0Mth_lwgQ5khQGIv9W0CcIGGU7ZS1i9BdSZtbuwQz14kigRk"),
                  fit: BoxFit.cover)),
        ),
        ListTile(
          leading: Icon(Icons.calendar_today),
          title: Text("Ders Programı"),
          onTap: () {
            print("dersler tıklandı");
          },
        ),
        ListTile(
          leading: Icon(Icons.book_online),
          title: Text("Dersler"),
          onTap: () {
            print("dersler tıklandı");
          },
        ),
        ListTile(
          leading: Icon(Icons.bookmarks),
          title: Text("Ders Materyalleri"),
          onTap: () {
            print("dersler tıklandı");
          },
        ),
        ListTile(
          leading: Icon(Icons.supervised_user_circle),
          title: Text("Öğrenciler"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OgrencilerScreen()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.grade),
          title: Text("Sınav Sonuçları"),
          onTap: () {
            print("dersler tıklandı");
          },
        ),
        ListTile(
          leading: Icon(Icons.notifications),
          title: Text("Duyurular"),
          onTap: () {
            print("dersler tıklandı");
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text("Ayarlar"),
          onTap: () {
            print("dersler tıklandı");
          },
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text("Çıkış"),
          onTap: () {
            print("dersler tıklandı");
          },
        ),
      ],
    ));
  }
}
