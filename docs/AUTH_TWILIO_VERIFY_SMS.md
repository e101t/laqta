# LAQTA Twilio Verify SMS OTP Auth

Flutter uses the existing backend auth endpoints:

- `POST /api/v1/auth/send-otp`
- `POST /api/v1/auth/verify-otp`

The backend sends OTP codes through Twilio Verify SMS, then returns LAQTA JWT access and refresh tokens after successful verification. Firebase Authentication is not used.

## UX Copy

- Sent: `تم إرسال رمز التحقق عبر رسالة SMS`
- Entry prompt: `أدخل رمز التحقق`
- Resend countdown: `إعادة الإرسال خلال 60 ثانية`

## Response Shape

Send OTP:

```json
{
  "success": true,
  "requestId": "internal-request-id",
  "phone": "+9647701234567",
  "message": "تم إرسال رمز التحقق عبر رسالة SMS",
  "expiresInSeconds": 300,
  "resendAfterSeconds": 60
}
```

Verify OTP:

```json
{
  "accessToken": "...",
  "refreshToken": "...",
  "user": {}
}
```
