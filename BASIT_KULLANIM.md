# 🚀 FolderToLLM - Basit Kullanım

## 📁 Proje Klasörünüzde Terminal Açın

1. **Finder'da projenize gidin**
2. **Sağ tık > Services > New Terminal at Folder** (veya Terminal'i açıp `cd /path/to/your-project`)

## ⚡ Tek Komutla Çalıştırın

```bash
# FolderToLLM script'inin bulunduğu yerden proje klasörünüze kopyalayın
cp /path/to/FolderToLLM-main/folderToLLM.sh .
cp /path/to/FolderToLLM-main/*.sh .

# Çalıştırılabilir yapın
chmod +x *.sh

# Tek komutla çalıştırın
./folderToLLM.sh
```

## 🎯 Ne Yapar?

- **Otomatik olarak** `.dart`, `.js`, `.py`, `.md`, `.json`, `.yaml` gibi yaygın dosya tiplerini dahil eder
- **Otomatik olarak** `node_modules`, `.git`, `build` gibi gereksiz klasörleri hariç tutar
- **Proje klasörünüzde** `LLM_Output_YYYYMMDDHHMMSS.txt` dosyası oluşturur

## 🔧 Özelleştirme (İsteğe Bağlı)

```bash
# Flutter/Dart projeleri için gereksiz klasörleri hariç tutun
./folderToLLM.sh -ef ".git,build,.dart_tool,android,ios"

# Sadece belirli klasörleri dahil edin
./folderToLLM.sh -if "lib,assets"

# Dosya boyutu limitini artırın
./folderToLLM.sh -max 2000000
```

## ✅ Sonuç

Artık proje klasörünüzde sadece `./folderToLLM.sh` yazarak:
- ✅ Dart dosyalarının içeriğini alır
- ✅ Diğer kod dosyalarını dahil eder  
- ✅ Gereksiz dosyaları hariç tutar
- ✅ LLM'ye gönderebileceğiniz tek dosya oluşturur

**Bu kadar basit!** 🎉

## 🎁 Bonus: Her Projede Kullanım

Script'leri bir kez kopyaladıktan sonra her Flutter/Dart projenizde `./folderToLLM.sh` yazarak kullanabilirsiniz. 