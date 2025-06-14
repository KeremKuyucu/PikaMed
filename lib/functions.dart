import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:PikaMed/model/InsulinDose.dart';

import 'Service/AuthService.dart';

class Yazi {
  static Map<String, dynamic>? _localizedStrings;
  static String _currentLanguage = 'English';

  static Future<void> loadDil(String dilKodu) async {
    if (_currentLanguage == dilKodu && _localizedStrings != null) {
      return; // Dil zaten yüklü, ekstra işlem yapma
    }

    try {
      String jsonString = await rootBundle.loadString('assets/dil.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      if (jsonMap['Veriler'] != null) {
        _localizedStrings = jsonMap['Veriler'];
        _currentLanguage = dilKodu;
      } else {
        throw Exception('JSON dosyasında "Veriler" anahtarı bulunamadı!');
      }
    } catch (e) {
      _localizedStrings = {};
    }

  }

  static String get(String key) {
    if (_localizedStrings == null) {
      dilDegistir();
      return '⚠️ Dil dosyası yükleniyor...';
    }

    if (_localizedStrings!.containsKey(key)) {
      final metin = _localizedStrings?[key]?[_currentLanguage] ?? '';
      return metin.replaceAll('\\n', '\n');
    }

    return '⚠️ $key bulunamadı';
  }

  static Future<void> dilDegistir() async {
    if (selectedLanguage.isEmpty)
      selectedLanguage = localLanguage == 'tr' ? "Türkçe" : "English";
    isEnglish = (selectedLanguage != 'Türkçe');
  }
}
String apiserver = "https://pikamed-api.keremkk.com.tr/api/pikamed";

String name = "", photoURL= "https://raw.githubusercontent.com/KeremKuyucu/PikaMed/main/assets/custom_profile.png",uid = '';
String selectedLanguage='';
bool isEnglish=false;
final List<String> diller = ['Türkçe','English'];
String localLanguage = '';
bool notificationRequest = true;

int targetWater=3500, availableWater=0 ,cupSize=200;
String changeWaterClock= "", changeWaterDay="";

int weight=0, size=0;
String changeWeightClock= "", bmiCategory="";
double bmi=0.0;

final AuthService _authService = AuthService();
Future<void> readFromFile(Function updateState) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/pikamed.json';
  final file = File(filePath);

  if (await file.exists()) {
    final contents = await file.readAsString();
    final jsonData = jsonDecode(contents);

    updateState(() {
      name = jsonData['name'] ?? '';
      uid = jsonData['uid'] ?? '';
      photoURL = jsonData['photoURL'] ?? 'https://cdn.glitch.global/e74d89f5-045d-4ad2-94c7-e2c99ed95318/2815428.png?v=1738114346363';
      selectedLanguage = jsonData['selectedLanguage'] ?? 'Türkçe';
      targetWater = jsonData['targetWater'] ?? 3500;
      availableWater = jsonData['availableWater'] ?? 0;
      cupSize = jsonData['cupSize'] ?? 200;
      weight = jsonData['weight'] ?? 0;
      size = jsonData['size'] ?? 0;
      changeWeightClock= jsonData['changeWeightClock'] ?? "";
      bmiCategory= jsonData['bmiCategory'] ?? "";
      bmi= jsonData['bmi'] ?? 0.0;
      changeWaterClock = jsonData['changeWaterClock'] ?? '';
      changeWaterDay = jsonData['changeWaterDay'] ?? '';
      notificationRequest = jsonData['notificationRequest'] ?? true;
      InsulinListData.insulinList = (jsonData['InsulinListData'] as List<dynamic>?)
          ?.map((e) => InsulinListData.fromJson(e))
          .toList() ?? [];

      debugPrint("dosyadan okundu");
    });
  } else {
    debugPrint('Dosya bulunamadı: pikamed.json');
    writeToFile();
  }
}
Future<void> writeToFile() async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/pikamed.json';
  final file = File(filePath);

  final data = {
    'name': name,
    'uid': uid,
    'photoURL': photoURL,
    'selectedLanguage': selectedLanguage,
    'targetWater': targetWater,
    'availableWater': availableWater,
    'changeWaterClock': changeWaterClock,
    'changeWaterDay': changeWaterDay,
    'cupSize': cupSize,
    'weight': weight,
    'size': size,
    'changeWeightClock':  changeWeightClock,
    'bmiCategory': bmiCategory,
    'bmi': bmi,
    'notificationRequest': notificationRequest,
    'InsulinListData': InsulinListData.insulinList.map((e) => e.toJson()).toList(),
  };
  print(data);
  final jsonData = jsonEncode(data);
  await file.writeAsString(jsonData);
  debugPrint("dosyaya yazıldı");
}
Future<void> fetchUserData(Function updateState) async {
  String? token = await AuthService().getIdToken();
  final Map<String, dynamic> data = { "uid": uid};
  final response = await http.post(
    Uri.parse('$apiserver/userdata'), // API URL'sini buraya ekleyin
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Token'ı Authorization başlığına ekleyin
    },
    body: json.encode(data),
  );
  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);

    updateState(() {
      name = data['name'];
      uid = data['uid'];
      photoURL = data['photoURL'];
      selectedLanguage = data['selectedLanguage'];
      targetWater = data['targetWater'];
      availableWater = data['availableWater'];
      cupSize = data['cupSize'];
      changeWaterClock = data['changeWaterClock'];
      changeWaterDay = data['changeWaterDay'];
      size = data['size'];
      weight = data['weight'];
      changeWeightClock = data['changeWeightClock'];
      bmiCategory = data['bmiCategory'];
      bmi = data['bmi'];
      notificationRequest = data['notificationRequest'] ?? true;
      InsulinListData.insulinList = (data['InsulinListData'] as List<dynamic>?)
          ?.map((e) => InsulinListData.fromJson(e))
          .toList() ?? [];
    });

    debugPrint("veri güncellendi");
    await writeToFile();
  } else {
    // Hata durumu
    debugPrint("API isteği başarısız: ${response.statusCode}");
  }
}
Future<void> resetAllData(Function updateState) async {
  // Burada sıfırlama işlemi yapılıyor
  updateState(() {
    name = "";
    photoURL = "https://cdn.glitch.global/e74d89f5-045d-4ad2-94c7-e2c99ed95318/2815428.png?v=1738114346363";
    uid = '';
    selectedLanguage = '';
    isEnglish = false;
    localLanguage = '';

    targetWater = 3500;
    availableWater = 0;
    cupSize = 200;
    changeWaterClock = "";
    changeWaterDay = "";

    weight = 0;
    size = 0;
    changeWeightClock = "";
    bmiCategory = "";
    bmi = 0.0;
    notificationRequest = true;
    InsulinListData.insulinList = [];
  });

  debugPrint("Veriler sıfırlandı.");
}
Future<void> postInfo() async {
  String? token = await AuthService().getIdToken();
  if (token == null || token.isEmpty) {
    debugPrint('Token yok, işlem iptal edildi.');
    return; // Token yoksa fonksiyonu sonlandır
  }
  notificationInfo();
  try {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String localVersion = packageInfo.version;
    String country = (await getCountry()).trim(); // Gereksiz \n karakterlerini temizledik.

    final Map<String, dynamic> data = {
      "message": "Bilgi Logu",
      "name": name,
      "uid": uid,
      "photoURL": photoURL,
      "version": localVersion,
      "country": country,
      'selectedLanguage': selectedLanguage,
      'targetWater': targetWater,
      'availableWater': availableWater,
      'changeWaterClock': changeWaterClock,
      'changeWaterDay': changeWaterDay,
      'cupSize': cupSize,
      'weight': weight,
      'size': size,
      'changeWeightClock':  changeWeightClock,
      'bmiCategory': bmiCategory,
      'bmi': bmi,
      'notificationRequest': notificationRequest,
      'InsulinListData': InsulinListData.insulinList.map((e) => e.toJson()).toList(),
    };

    final response = await http.post(
      Uri.parse('$apiserver/info'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data), // Direkt Map'i JSON'a çeviriyoruz
    ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      debugPrint('✅ Log başarıyla gönderildi!');
    } else {
      debugPrint('❌ Log gönderilemedi: ${response.statusCode}');
      debugPrint('🛑 API Yanıtı: ${response.body}');
    }
  } catch (e) {
    debugPrint('❌ Hata: $e');
  }
}

Future<String> askAi(String message) async {
  String? token = await AuthService().getIdToken();
  try {
    final targetUrl = '$apiserver/ai';
    final response = await http.post(
      Uri.parse(targetUrl),
      headers: {'Content-Type': 'application/json','Authorization': 'Bearer $token',},
      body: json.encode({
        'uid': uid,
        'message': message,
        'targetWater': targetWater,
        'availableWater': availableWater,
        'cupSize': cupSize,
        'changeWaterDay': changeWaterDay,
        'changeWaterClock': changeWaterClock,
        'weight': weight,
        'size': size,
        'bmi': bmi,
        'bmiCategory': bmiCategory,
        'name': name,
        'selectedLanguage': selectedLanguage,
        'localTime': DateFormat('EEEE,  HH:mm', 'tr_TR').format(DateTime.now()),
        'insulinPlan': InsulinListData.insulinList.map((e) => e.toJson()).toList(),
      }),
    ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      debugPrint('Mesaj başarıyla gönderildi!');
      final responseBody = json.decode(response.body);
      return responseBody['aiResponse'];
    } else {
      debugPrint('Mesaj gönderilemedi: ${response.statusCode}');
      return 'Mesaj gönderilemedi.';
    }
  } catch (e) {
    debugPrint('Hata: $e');
    return 'Bir hata oluştu.';
  }
}
Future<void> postmessage(String message, String neden, String? isim, String? eposta, String? uid) async {
  String? token = await AuthService().getIdToken();
  try {
    final targetUrl = '$apiserver/pikamedfeedback';
    final response = await http.post(
      Uri.parse(targetUrl),
      headers: {'Content-Type': 'application/json','Authorization': 'Bearer $token',},
      body: json.encode({
        'sebep': neden,
        'message': message,
        'isim': isim,
        'eposta': eposta,
        'uid': uid,
      }),
    ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      debugPrint('Mesaj başarıyla gönderildi!');
    } else {
      debugPrint('Mesaj gönderilemedi: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Hata: $e');
  }
}
Future<void> notificationInfo() async {
  String? token = await AuthService().getIdToken();
  final user = _authService.currentUser;
  try {
    final Map<String, dynamic> data = {
      "name": name,
      'email': user?.email,
      "uid": uid,
      'notificationRequest': notificationRequest,
      'InsulinListData': InsulinListData.insulinList.map((e) => e.toJson()).toList(),
    };

    final response = await http.post(
      Uri.parse('$apiserver/notificationInfo'),
      headers: {'Content-Type': 'application/json','Authorization': 'Bearer $token',},
      body: json.encode(data), // Direkt Map'i JSON'a çeviriyoruz
    ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      debugPrint('✅ NotificationInfo başarıyla gönderildi!');
    } else {
      debugPrint('❌ NotificationInfo gönderilemedi: ${response.statusCode}');
      debugPrint('🛑 NotificationInfo API Yanıtı: ${response.body}');
    }
  } catch (e) {
    debugPrint('❌ Hata: $e');
  }
}

Future<String> getCountry() async {
  final url = Uri.parse('https://am.i.mullvad.net/country');
  try {
    // HTTP GET isteği gönderiyoruz
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // İstek başarılıysa, cevabı string olarak döndürüyoruz
      return response.body;
    } else {
      throw Exception('Hata: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Hata oluştu: $e');
  }
}
Future<String> getChannelId() async {
  final user = _authService.currentUser;
  String? token = await AuthService().getIdToken();
  final url = Uri.parse('$apiserver/check-user');
  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json",'Authorization': 'Bearer $token',},
      body: jsonEncode({"uid": user?.uid}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['channelID'];
      } else {
        throw Exception('Hata: ${data['message']}');
      }
    } else {
      throw Exception('HTTP Hata: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Hata oluştu: $e');
  }
}
Future<bool> isDoctor() async {
  final user = _authService.currentUser;
  if (user != null) {
    // Yeni bir idToken alınması
    final idTokenResult = await user.getIdTokenResult(); // true parametresi ile yeni bir idToken alınır.

    return idTokenResult.claims?['role'] == 'doctor';
  }
  return false;
}
