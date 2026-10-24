# 🛰️ Wi-Fi Suite & Network Engine (Polyglot Monorepo)

تم بناء هذا المشروع بالكامل من واجهة السطر البرمجي (Zero-IDE) باستخدام هاتف يعمل بنظام أندرويد عبر تطبيق Termux.

## 🏗️ المعمارية (Architecture)
- **Native Core (C/C++):** فحص واجهة الواي فاي (`wlan0`) وعناوين IP (JNI & FFI).
- **Backend Services:**
  - **Go Engine:** استخراج واجهات الشبكة عالية الأداء (Port 8081).
  - **Python Analytics:** تحليل جودة الإشارة (Port 8082).
  - **Spring Boot (Java):** REST API لإدارة نقاط الوصول (Port 8083).
- **Frontend Apps:**
  - **Flutter:** واجهة Dashboard تجلب البيانات من الـ APIs.
  - **Jetpack Compose & React Native:** هياكل بديلة للواجهات.
- **Infra:** ملفات Docker Compose و Kubernetes جاهزة للسحابة.

## 🚀 كيفية التشغيل (في Termux)
```bash
chmod +x build_all.sh
./build_all.sh
pkill -9 -f java; pkill -9 -f go_engine; pkill -9 -f python
