import 'package:PikaMed/model/app_theme.dart';
import 'package:PikaMed/Menu/custom_drawer/drawer_user_controller.dart';
import 'package:PikaMed/Menu/custom_drawer/home_drawer.dart';
import 'package:PikaMed/Menu/feedback_screen.dart';
import 'package:PikaMed/Menu/help_screen.dart';
import 'package:PikaMed/Menu/invite_friend_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:PikaMed/hasta menu/fitness_app_home_screen.dart';
import 'package:PikaMed/giris_animasyon/introduction_animation_screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:PikaMed/functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:PikaMed/model/InsulinDose.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:PikaMed/Service/AuthService.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_html/flutter_html.dart';
class NavigationHomeScreen extends StatefulWidget {
  @override
  _NavigationHomeScreenState createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen> {
  Widget? screenView;
  DrawerIndex? drawerIndex;

  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? _user) {
      setState(() {
        user = _user;
      });
      //debugPrint('user=$_user');
      _initUserAndNotifications();
    });
  }

  Future<void> _initUserAndNotifications() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Message received: ${message.notification?.title}, ${message.notification?.body}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(message.notification?.title ?? 'Bildirim'),
              content: Text(message.notification?.body ?? 'Bildirim içeriği yok.'),
              actions: <Widget>[
                TextButton(
                  child: Text('Tamam'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      });
    });

    setState(() {
      drawerIndex = DrawerIndex.HOME;
      InsulinListData.updateDoseLists();  // Diğer verileri güncelle
    });

    if (user == null) {
      setState(() {
        screenView = GirisAnimasyonScreen();  // Giriş ekranı göster
      });
    } else {
      setState(() {
        screenView = HastaHomeScreen();  // Hasta ana ekranı göster
      });
    }
    surumKiyasla(context);
    await initializeDateFormatting('tr_TR', null);
    await readFromFile((update) => setState(update));

    bmi = weight / ((size / 100) * (size / 100));
    bmi = bmi.isNaN ? 0 : bmi;
    if (bmi < 18.5) {
      bmiCategory = 'Zayıf';
    } else if (bmi >= 18.5 && bmi < 24.9) {
      bmiCategory = 'Normal';
    } else if (bmi >= 25 && bmi < 29.9) {
      bmiCategory = 'Fazla Kilolu';
    } else {
      bmiCategory = 'Obez';
    }
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (changeWaterDay == "" || changeWaterDay != today) {
      changeWaterDay = DateFormat('yyyy-MM-dd').format(DateTime.now());
      debugPrint("Yeni gün tespit edildi! Veriler sıfırlandı.");
      availableWater=0;
      changeWaterClock = DateFormat('EEEE,  ', 'tr_TR').format(DateTime.now());
      changeWaterClock +='00:00';
      for (var dose in InsulinListData.insulinList) {
        dose.notificationSend = false;
      }
    } else {
      debugPrint("Bugün zaten kaydedilmiş: $today");
    }
    writeToFile();
    postInfo();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.white,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: AppTheme.nearlyWhite,
          body: DrawerUserController(
            screenIndex: drawerIndex,
            drawerWidth: MediaQuery.of(context).size.width * 0.75,
            onDrawerCall: (DrawerIndex drawerIndexdata) {
              changeIndex(drawerIndexdata);
              //callback from drawer for replace screen as user need with passing DrawerIndex(Enum index)
            },
            screenView: screenView,
            //we replace screen view as we need on navigate starting screens like MyHomePage, HelpScreen, FeedbackScreen, etc...
          ),
        ),
      ),
    );
  }

  Future<void> surumKiyasla(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String localVersion = packageInfo.version;

    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/KeremKuyucu/PikaMed/releases'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          final latestRelease = data[0];
          String remoteVersion = latestRelease['tag_name'] ?? 'N/A';
          String updateNotes = latestRelease['body'] ?? 'Yama notları mevcut değil';

          String html = md.markdownToHtml(updateNotes);

          String releasePageUrl = 'https://github.com/KeremKuyucu/PikaMed/releases';

          if (remoteVersion != localVersion) {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Yeni Sürüm Var'),
                  content: SizedBox(
                    width: double.maxFinite,
                    height: 300,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mevcut Sürüm: $localVersion'),
                          Text('Yeni Sürüm: $remoteVersion'),
                          SizedBox(height: 10),
                          Text('Yama Notları:'),
                          SizedBox(height: 10),
                          Html(data: html),
                        ],
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Güncelle'),
                      onPressed: () {
                        EasyLauncher.url(url: releasePageUrl);
                      },
                    ),
                  ],
                );
              },
            );
          }
        }
      } else {
        throw Exception('GitHub API hatası: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Hata: $e');
    }
  }

  void changeIndex(DrawerIndex drawerIndexdata) async {
      drawerIndex = drawerIndexdata;
      switch (drawerIndex) {
        case DrawerIndex.HOME:
          if(user==null) {
            setState(() {
              screenView =GirisAnimasyonScreen();
            });
          } else {
            setState(() {
              screenView = HastaHomeScreen();
            });
          }
          break;
        case DrawerIndex.Doctor:
          bool isDoctorUser = await isDoctor();
          if (isDoctorUser) {
            setState(() {
              EasyLauncher.url(
                // kendi whatsapp linkim değiştirilcek
                url: 'https://pikamed-panel.keremkk.com.tr',
              );
            });
          } else {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Doktor menüsüne girmek için yetkiniz bulunmuyor.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          break;
        case DrawerIndex.Help:
          setState(() {
            screenView = HelpScreen();
          });
          break;
        case DrawerIndex.FeedBack:
          setState(() {
            screenView = FeedbackScreen();
          });
          break;
        case DrawerIndex.Invite:
          setState(() {
            screenView = InviteFriend();
          });
          break;
        case DrawerIndex.Share:
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Uygulamayı değerlendir sekmesi açılacak."),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.blue,
                action: SnackBarAction(
                  label: "Kapat",
                  onPressed: () {
                    // İşlem yapılabilir
                  },
                ),
              ),
            );
          });
          break;
        case DrawerIndex.About:
          setState(() {
            EasyLauncher.url(
              url: 'https://pikamed.keremkk.com.tr',
            );
          });
          break;
        default:
          break;
      }
    }

}
