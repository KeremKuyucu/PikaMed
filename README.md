# PikaMed Mobil Uygulaması

PikaMed, sağlık hizmetleri ve hasta takibi için geliştirilmiş modern bir mobil uygulamadır.
Deneyap bitirme projesi olarak hazırlanmıştır.

**Uygulama internet sitesi:** [https://pikamed.keremkk.com.tr](https://pikamed.keremkk.com.tr)

* API sunucusunu Glitch'ten Vercel'e taşıdım.
* Şimdilik başka büyük bir güncelleme planlamıyorum.

---

## Projeyi Destekle

PikaMed projesini faydalı buluyorsan, geliştirilmesine destek olmak için GitHub Sponsors üzerinden beni destekleyebilirsin.

[![GitHub Sponsors](https://img.shields.io/badge/Destekle-GitHub-green?logo=github)](https://github.com/sponsors/KeremKuyucu)

---

## Özellikler

1. 🔐 Güvenli kullanıcı kimlik doğrulama (Firebase Authentication)
2. 📱 Modern ve kullanıcı dostu arayüz
3. 🔔 Anlık bildirimler
4. 💬 Mesajlaşma özelliği
5. 📊 Hasta takip sistemi
6. 🌐 Çoklu platform desteği (Android, iOS)
7. 🤖 Yapay zeka destekli hasta analizi (Gemini AI)

---

## Kullanılan Teknolojiler

* Flutter SDK
* Firebase (Authentication, Analytics, Cloud Messaging)
* Google Sign-In
* Gemini AI

---

## Gereksinimler

* Flutter SDK (>=2.17.5)
* Dart SDK
* Firebase hesabı
* Android Studio veya VS Code
* Git
* Gemini AI API anahtarı
* Bir API sunucusu

---

## Kurulum

1. Projeyi klonlayın:

   ```bash
   git clone https://github.com/keremlolgg/PikaMed.git
   ```

2. Bağımlılıkları yükleyin:

   ```bash
   flutter pub get
   ```

3. Firebase yapılandırmasını yapın:

    * Firebase Console’dan yeni bir proje oluşturun
    * Android ve iOS uygulamalarınızı Firebase’e ekleyin
    * `google-services.json` ve `GoogleService-Info.plist` dosyalarını ilgili klasörlere ekleyin

4. API sunucusunu ayarlayın:

    * [API kodu (Glitch)](https://glitch.com/edit/#!/keremkk?path=routes/pikamed.js)
    * API sunucu adresini uygulamada güncelleyin

5. Uygulamayı çalıştırın:

   ```bash
   flutter run
   ```

---

## Katkıda Bulunma

1. Depoyu fork edin
2. Yeni bir branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some amazing feature'`)
4. Branch’inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

---

## Lisans

Bu proje **GPL lisansı** altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakabilirsiniz.

---

## İletişim

Proje Sahibi - [Kerem Kuyucu](https://keremkk.com.tr)

---