# LAQTA Closed Testing Operations

Date: 2026-06-12

Purpose: run Google Play Closed Testing without losing feedback, crash signals, or tester progress.

## Tester Instruction Message

Arabic:

> مرحباً، شكراً لانضمامك لاختبار LAQTA المغلق. الرجاء تثبيت التطبيق من رابط Google Play، تسجيل الدخول، ثم اختبار: الصفحة الرئيسية، الإشعارات، المحادثات، الملف الشخصي، معرض الأعمال، والبحث عن المصورين. إذا ظهر تعليق أو خطأ، أرسل لنا وصف الخطأ وصورة للشاشة إن أمكن ووقت حدوثه.

English:

> Thank you for joining the LAQTA closed test. Please install the app from Google Play, sign in, then test Home, Notifications, Chat, Profile, Portfolio, and photographer discovery. If anything freezes or fails, send the issue description, a screenshot if possible, and the time it happened.

## Feedback Form Questions

1. Tester name or alias.
2. Phone model and Android version.
3. Did installation from Google Play work?
4. Did login work?
5. Did Home open quickly?
6. Did notifications open?
7. Did chat list open?
8. Were you able to send or receive a chat message?
9. Did profile image and portfolio images load?
10. Did any screen freeze?
11. Did any button do nothing?
12. Did the app crash or close unexpectedly?
13. What felt slow?
14. What was confusing?
15. Overall rating from 1 to 5.

## Daily Monitoring Checklist

- Google Play Console crashes: review daily.
- Google Play Console ANRs: review daily.
- Sentry new issues: review daily.
- Backend 5xx count: review daily.
- Auth/login failures: review daily.
- Media upload failures: review daily.
- Chat send failures: review daily.
- User feedback form: triage daily.

## Issue Triage Template

- Issue ID:
- Reporter:
- Device:
- App version:
- Screen:
- Steps to reproduce:
- Expected result:
- Actual result:
- Screenshot/log evidence:
- Severity: Critical / High / Medium / Low
- Owner:
- Status: New / Reproduced / Fixed / Won't fix / Needs info

## Tester Tracker

| Tester | Joined | Installed | Logged In | Tested Chat | Tested Profile | Tested Portfolio | Reported Issue | Notes |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| Tester 01 | No | No | No | No | No | No | No | |
| Tester 02 | No | No | No | No | No | No | No | |
| Tester 03 | No | No | No | No | No | No | No | |
| Tester 04 | No | No | No | No | No | No | No | |
| Tester 05 | No | No | No | No | No | No | No | |
| Tester 06 | No | No | No | No | No | No | No | |
| Tester 07 | No | No | No | No | No | No | No | |
| Tester 08 | No | No | No | No | No | No | No | |
| Tester 09 | No | No | No | No | No | No | No | |
| Tester 10 | No | No | No | No | No | No | No | |
| Tester 11 | No | No | No | No | No | No | No | |
| Tester 12 | No | No | No | No | No | No | No | |

## 14-Day Tracking

| Day | Active Testers | New Crashes | New ANRs | Backend 5xx | Top Issue | Action |
|---:|---:|---:|---:|---:|---|---|
| 1 | 0 | 0 | 0 | 0 | | |
| 2 | 0 | 0 | 0 | 0 | | |
| 3 | 0 | 0 | 0 | 0 | | |
| 4 | 0 | 0 | 0 | 0 | | |
| 5 | 0 | 0 | 0 | 0 | | |
| 6 | 0 | 0 | 0 | 0 | | |
| 7 | 0 | 0 | 0 | 0 | | |
| 8 | 0 | 0 | 0 | 0 | | |
| 9 | 0 | 0 | 0 | 0 | | |
| 10 | 0 | 0 | 0 | 0 | | |
| 11 | 0 | 0 | 0 | 0 | | |
| 12 | 0 | 0 | 0 | 0 | | |
| 13 | 0 | 0 | 0 | 0 | | |
| 14 | 0 | 0 | 0 | 0 | | |

## Go/No-Go After 14 Days

Continue toward public release only if:

- 12 testers completed the minimum closed-test participation.
- Crash-free sessions are acceptable.
- No unresolved critical login, chat, media, payment, or account-management bug remains.
- Backend stays healthy under tester traffic.
- Store policy requirements remain satisfied.
