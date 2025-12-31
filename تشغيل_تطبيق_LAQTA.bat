@echo off
echo =====================================
echo     🚀 تشغيل تطبيق LAQTA 🚀
echo =====================================
echo.

echo جاري تشغيل تطبيق Windows Desktop...
start "" "build\windows\x64\runner\Release\luqta.exe"

echo.
echo ✅ تم تشغيل التطبيق بنجاح!
echo.
echo إذا لم يعمل التطبيق:
echo 1. اذهب إلى مجلد المشروع
echo 2. انتقل إلى: build\windows\x64\runner\Release\
echo 3. انقر مرتين على: luqta.exe
echo.
echo أو افتح المتصفح وانتقل إلى:
echo build\web\index.html
echo.
echo للحساب التجريبي:
echo رقم الهاتف: +201234567890
echo كود OTP: 123456
echo.
echo اضغط أي مفتاح للخروج...
pause > nul