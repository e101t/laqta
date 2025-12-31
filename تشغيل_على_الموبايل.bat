@echo off
echo =====================================
echo     🚀 تشغيل LAQTA على الهاتف المحمول 🚀
echo =====================================
echo.

echo ✅ تم بناء تطبيق الويب بنجاح!
echo.
echo 📱 يمكنك الآن تشغيل التطبيق على هاتفك المحمول:
echo.
echo خطوات التشغيل على الهاتف:
echo.
echo 1️⃣ تأكد من أن الكمبيوتر والهاتف على نفس الشبكة (WiFi)
echo.
echo 2️⃣ افتح Command Prompt وانتقل إلى مجلد build\web:
echo    cd build\web
echo.
echo 3️⃣ شغل السيرفر:
echo    python -m http.server 8080
echo.
echo 4️⃣ على هاتفك، افتح المتصفح واذهب إلى:
echo    http://[عنوان-الكمبيوتر]:8080
echo.
echo    لمعرفة عنوان الكمبيوتر، اكتب في Command Prompt:
echo    ipconfig
echo    أو
echo    hostname
echo.
echo 5️⃣ بعد فتح التطبيق في المتصفح:
echo    • اضغط على زر القائمة (⋮) في المتصفح
echo    • اختر "إضافة إلى الشاشة الرئيسية"
echo    • أو "تثبيت التطبيق" أو "Add to Home Screen"
echo.
echo 6️⃣ سيظهر أيقونة LAQTA على هاتفك!
echo.
echo 🔑 للحساب التجريبي:
echo رقم الهاتف: +201234567890
echo كود OTP: 123456
echo.
echo ✅ التطبيق سيعمل كتطبيق PWA (Progressive Web App)
echo ✅ يمكن تثبيته على الشاشة الرئيسية
echo ✅ يعمل بدون إنترنت بعد التحميل الأول
echo.
echo اضغط أي مفتاح لبدء تشغيل السيرفر...
pause > nul

cd build\web
echo 🚀 بدء تشغيل السيرفر...
echo.
echo 🌐 التطبيق متاح الآن على:
echo http://localhost:8080
echo.
echo 📱 من هاتفك، اذهب إلى:
echo http://%COMPUTERNAME%:8080
echo.
echo اضغط Ctrl+C لإيقاف السيرفر
echo.
python -m http.server 8080