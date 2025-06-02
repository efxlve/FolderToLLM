# FolderToLLM Mac - Türkçe Kullanım Örnekleri

## 🎯 Sadece Belirli Bir Projeyi İşlemek

Scriptiniz **varsayılan olarak çalıştırıldığı dizini** işler. Sadece belirli bir projenizi işlemek için `-r` (root path) parametresini kullanın:

## 📁 Temel Kullanım

### 1. Belirli Bir Projeyi İşlemek
```bash
# Masaüstünüzdeki bir projeyi işleyin
./folderToLLM.sh -r "/Users/kullaniciadi/Desktop/MyProject"

# Documents klasöründeki bir projeyi işleyin
./folderToLLM.sh -r "~/Documents/WebProject"

# Geçerli konumdan farklı bir dizindeki projeyi işleyin
./folderToLLM.sh -r "/path/to/your/project"
```

### 2. Proje Tipine Göre Örnekler

#### React/Next.js Projesi
```bash
./folderToLLM.sh \
  -r "/Users/kullaniciadi/Desktop/ReactProject" \
  -ie ".js,.jsx,.ts,.tsx,.json,.md,.css" \
  -ef "node_modules,.next,dist,build,.git"
```

#### Python Projesi
```bash
./folderToLLM.sh \
  -r "/Users/kullaniciadi/Documents/PythonProject" \
  -ie ".py,.md,.txt,.yml,.yaml,.json" \
  -ef ".venv,__pycache__,.git,dist,build"
```

#### Vue.js Projesi
```bash
./folderToLLM.sh \
  -r "~/Projects/VueProject" \
  -ie ".vue,.js,.ts,.json,.md,.css,.scss" \
  -ef "node_modules,dist,.git"
```

#### Laravel/PHP Projesi
```bash
./folderToLLM.sh \
  -r "/Users/kullaniciadi/Sites/LaravelProject" \
  -ie ".php,.blade.php,.js,.css,.md,.json" \
  -ef "vendor,node_modules,storage/logs,public/storage,.git"
```

#### Swift/iOS Projesi
```bash
./folderToLLM.sh \
  -r "~/XcodeProjects/MyApp" \
  -ie ".swift,.m,.h,.md,.plist" \
  -ef ".build,DerivedData,*.xcworkspace,Pods,.git"
```

## 🔧 Gelişmiş Filtreleme

### 3. Sadece Kaynak Kodları
```bash
# Sadece kod dosyaları, dokümantasyon hariç
./folderToLLM.sh \
  -r "/path/to/project" \
  -ie ".js,.ts,.jsx,.tsx,.py,.php,.swift,.java,.cpp,.c,.h"
```

### 4. Sadece Dokümantasyon
```bash
# Sadece README, dokümantasyon dosyaları
./folderToLLM.sh \
  -r "/path/to/project" \
  -ie ".md,.txt,.rst,.adoc"
```

### 5. Belirli Klasörleri Dahil Etmek
```bash
# Sadece src ve docs klasörlerini işle
./folderToLLM.sh \
  -r "/path/to/project" \
  -if "src,docs,components"
```

### 6. Küçük Dosyalar İçin
```bash
# Sadece 100KB'dan küçük dosyalar
./folderToLLM.sh \
  -r "/path/to/project" \
  -max 102400
```

## 🚨 Önemli Notlar

### ✅ Doğru Kullanım:
```bash
# ✅ Bu şekilde sadece belirttiğiniz projeyi işler
./folderToLLM.sh -r "/Users/kullaniciadi/Desktop/MyProject"
```

### ❌ Yanlış Kullanım:
```bash
# ❌ Bu şekilde script'in bulunduğu dizini işler (tüm Mac değil ama istemediğiniz yer)
./folderToLLM.sh
```

## 📂 Gerçek Örnek Senaryo

Diyelim ki masaüstünüzde "ECommerceApp" adında bir projeniz var:

```bash
# Projenizin tam yolunu kullanın
./folderToLLM.sh -r "/Users/$(whoami)/Desktop/ECommerceApp"

# Veya kısaca
./folderToLLM.sh -r "~/Desktop/ECommerceApp"

# Sadece önemli dosyaları dahil etmek için
./folderToLLM.sh \
  -r "~/Desktop/ECommerceApp" \
  -ie ".js,.jsx,.ts,.tsx,.json,.md,.css" \
  -ef "node_modules,dist,build,.git,.env"
```

## 🎯 Sonuç

- Script **sadece belirttiğiniz dizini** işler
- `-r` parametresi ile **tam proje yolunu** verin
- **Mac'inizin tamamını** işlemez, endişelenmeyin
- Çıktı dosyası **belirttiğiniz proje dizininde** oluşur

Bu şekilde sadece istediğiniz projeyi LLM'ye göndermek için hazırlamış olursunuz! 🚀 