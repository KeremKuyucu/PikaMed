import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:PikaMed/functions.dart';

import '../model/InsulinDose.dart';
class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  /// Google ile giriş yapar ve kullanıcıyı döner.
  Future<User?> googleSignIn({required BuildContext context}) async {
    try {
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint("Kullanıcı oturum açmayı iptal etti.");
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        name = user.providerData.first.displayName!;
        uid = user.uid;
        photoURL = user.photoURL ?? "";

        // Kullanıcı bilgilerini sunucuya gönder
        await _logAuthAction("Giriş");
      }

      return user;
    } catch (error) {
      debugPrint("Google Sign-In Hatası: $error");
      _showSnackBar(context, "Giriş işlemi sırasında hata oluştu.");
      return null;
    }
  }

  /// Çıkış yapar ve API'ye çıkış kaydı yollar.
  Future<void> signOut({required BuildContext context}) async {
    try {
      final user = _auth.currentUser;
      await _logAuthAction("Çıkış");

      if (user != null) {
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
        InsulinListData.updateDoseLists();
        _showSnackBar(context, '"${user.displayName ?? 'Bilinmeyen Kullanıcı'}" hesabından çıkış yapıldı.');
      } else {
        _showSnackBar(context, "Zaten giriş yapılmamış.");
      }

      await _auth.signOut();


    } catch (e) {
      debugPrint('Çıkış Hatası: $e');
      _showSnackBar(context, "Çıkış sırasında hata oluştu.");
    }
  }

  /// API sunucusuna giriş/çıkış olayını bildirir.
  Future<void> _logAuthAction(String sebep) async {
    String? token = await AuthService().getIdToken();
    try {
      final targetUrl = '$apiserver/authlog';
      final response = await http.post(
        Uri.parse(targetUrl),
        headers: {'Content-Type': 'application/json','Authorization': 'Bearer $token',},
        body: json.encode({
          'sebep': sebep,
          'uid': uid,
          'name': name,
          'profilUrl': photoURL,
        }),
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        debugPrint('$sebep kaydı başarıyla gönderildi.');
      } else {
        debugPrint('$sebep kaydı gönderilemedi: ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException {
      debugPrint('İstek zaman aşımına uğradı.');
    } catch (e) {
      debugPrint('Hata: $e');
    }
  }

  /// Şu anki kullanıcıyı döner.


  /// Her zaman güncel idToken'ı almak için
  Future<String?> getIdToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  /// Ekranda SnackBar mesajı gösterir.
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
