# Flutter/Dart Projeleri için FolderToLLM Kullanım Kılavuzu

## 🎯 Dart Dosyalarının İçeriği Alınmıyor Sorunu

Dart dosyalarının içeriğini alamama sorununuz muhtemelen şu nedenlerden biri:

### ❌ Yaygın Hatalar:

1. **`.dart` uzantısını belirtmemek**
2. **Çok büyük dosya limitine takılmak**
3. **Yanlış klasör yolu vermek**

## ✅ Doğru Flutter/Dart Kullanımı

### 1. Temel Flutter Projesi
```bash
# Dart dosyalarını dahil etmek için mutlaka -ie parametresini kullanın
./folderToLLM.sh \
  -r "/path/to/your/flutter-project" \
  -ie ".dart,.yaml,.pubspec.yaml,.md" \
  -ef ".git,build,.dart_tool,android,ios"
```

### 2. Sadece Dart Kodları
```bash
# Sadece .dart dosyalarının içeriğini almak için
./folderToLLM.sh \
  -r "/path/to/your/flutter-project" \
  -ie ".dart" \
  -ef ".git,build,.dart_tool"
```

### 3. Flutter Projesi (Kapsamlı)
```bash
./folderToLLM.sh \
  -r "/path/to/your/flutter-project" \
  -ie ".dart,.yaml,.json,.md,.gitignore" \
  -ef ".git,build,.dart_tool,android/app/build,ios/Runner.xcworkspace,ios/Pods"
```

### 4. Sadece lib Klasörü
```bash
# Sadece lib klasöründeki Dart kodları
./folderToLLM.sh \
  -r "/path/to/your/flutter-project" \
  -if "lib" \
  -ie ".dart"
```

## 🔧 Sorun Giderme

### Debug Testi Çalıştırın:
```bash
chmod +x debug_dart_issue.sh
./debug_dart_issue.sh
```

### Manuel Kontrol:
```bash
# Projenizde dart dosyası var mı?
find /path/to/your/flutter-project -name "*.dart" | head -5

# Bir dart dosyasının içeriğini manuel okuyun
cat /path/to/your/flutter-project/lib/main.dart
```

## 📁 Örnek Flutter Proje Komutları

### Gerçek Dünya Örnekleri:

#### Counter App (Flutter varsayılan proje):
```bash
./folderToLLM.sh \
  -r "~/FlutterProjects/counter_app" \
  -ie ".dart,.yaml" \
  -if "lib" \
  -max 500000
```

#### E-commerce Flutter App:
```bash
./folderToLLM.sh \
  -r "~/FlutterProjects/ecommerce_app" \
  -ie ".dart,.yaml,.json" \
  -ef ".git,build,.dart_tool,android,ios,test" \
  -if "lib,assets"
```

#### Widget Kütüphanesi:
```bash
./folderToLLM.sh \
  -r "~/FlutterProjects/my_widgets" \
  -ie ".dart,.md" \
  -if "lib,example" \
  -max 200000
```

## 🚨 Önemli Notlar

### ✅ Mutlaka Yapın:
- `-ie ".dart"` parametresini kullanın
- Flutter proje yolunu `-r` ile belirtin
- `build`, `.dart_tool` klasörlerini hariç tutun

### ❌ Yapmayın:
- Extension belirtmeden çalıştırmayın
- Çok büyük dosya limitlerini kullanmayın
- Android/iOS native kodlarını dahil etmeyin (gereksiz)

## 🎯 Hızlı Test Komutu

Flutter projenizin yolunu aşağıdaki komutta değiştirip test edin:

```bash
# Bu komutu kendi proje yolunuzla değiştirin
./folderToLLM.sh \
  -r "/Users/$(whoami)/FlutterProjects/MyApp" \
  -ie ".dart,.yaml" \
  -ef ".git,build,.dart_tool" \
  -max 1000000
```

## 📊 Beklenen Sonuç

Başarılı olduğunda şunları göreceksiniz:
- `main.dart`, `app.dart` gibi dosyaların içerikleri
- Widget kodları tamamen okunabilir
- Yaml konfigürasyon dosyaları
- Proje dizin yapısı

## 🔍 Hala Çalışmıyorsa

1. **Debug scripti çalıştırın**: `./debug_dart_issue.sh`
2. **Manuel test yapın**: `cat your_flutter_project/lib/main.dart`
3. **Dosya yollarını kontrol edin**: `-r` parametresinde tam yol var mı?
4. **Extension'ı kontrol edin**: `-ie ".dart"` yazdınız mı?

Bu adımları takip ederseniz Dart dosyalarının içeriğini alabilirsiniz! 🚀 