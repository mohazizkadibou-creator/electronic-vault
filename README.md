# Electronic Vault

خزنة مشفّرة محلياً (local-first) لإدارة مشاريعك ومنتجاتك البرمجية، مع مصنع بناء تلقائي ينتج
نسخاً قابلة للتحميل لكل المنصات.

A secure, local-first encrypted vault for AI project resources, together with an
automated **build factory** that produces downloadable products.

## الميزات | Features

- 🔐 **تشفير محلي**: كلمات المرور تُشتق بـ Argon2id، والبيانات تُشفّر بـ AES-256-GCM.
- 🗄️ **بدون سيرفر**: كل شيء يبقى على جهازك (SharedPreferences / التخزين المحلي).
- 📦 **إدارة المشاريع والمنتجات**: أنشئ مشاريع، اربطها بمنتجات قابلة للتحميل (ZIP / APK / AAB / Web).
- 🌍 **متعدد اللغات**: واجهة تدعم العربية (RTL) والإنجليزية والفرنسية والإسبانية.
- 🏭 **مصنع البناء**: GitHub Actions يبني Web + Android + Windows عند دفع وسم `v*` وينشر إصداراً.

## المتطلبات | Requirements

- Flutter SDK (stable)
- للأندرويد: JDK 17 + Android SDK
- لسطح مكتب ويندوز: Visual Studio مع "Desktop development with C++"

## التشغيل السريع | Quick start

```bat
setup_and_run.bat
```

يفتح التطبيق في متصفح Chrome.

## البناء | Building products

بناء كل ما تستطيعه الآلة:

```bash
bash build_scripts/build_all.sh
```

أو على ويندوز بالنقر على `factory_platform.bat`.

## المصنع التلقائي | Automated factory (CI/CD)

ادفع وسم إصدار وسيبني GitHub الأفعال كل المنتجات وينشرها:

```bash
git tag v1.0.0
git push origin v1.0.0
```

ثم افتح تبويب **Releases** في المستودع للتحميل. كل إصدار يحتوي على
`SHA256SUMS.txt` للتحقق من سلامة الملفات.

## بنية المشروع | Project layout

```
lib/
  main.dart              نقطة الدخول
  app.dart               إعداد MaterialApp والاتجاه (RTL/LTR)
  core/                  النصوص والترجمة
  models/                Project / ProductInfo
  services/              المصادقة، الخزنة، المشاريع، تتبع التحميلات
  ui/screens/            شاشة الدخول ولوحة التحكم
build_scripts/           سكربتات البناء
.github/workflows/       مصنع GitHub Actions
landing_page/            صفحة التحميل
```

## الأمان | Security notes

- كلمة المرور لا تُخزَّن أبداً؛ يُخزَّن فقط ناتج اشتقاق Argon2id مع ملح عشوائي لكل تثبيت.
- النسخة الحالية تخزّن فهرس المشاريع محلياً بشكل غير مشفّر (قابل للتحويل لاحقاً إلى مخزن مشفّر).
- لا يتم إرسال أي بيانات إلى أي سيرفر خارجي.
