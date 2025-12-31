# LAQTA Codebase Audit (Phase 3)

## Snapshot
- البنية الحالية: `lib/core` + `lib/screens` بدون Feature Modules واضحة.
- التوجيه: GoRouter مع Routes صريحة، بلا Guards مبنية على الدور/الحالة.
- الحالة: Provider للثيم/اللغة فقط، وباقي الشاشات تعتمد `setState`.
- البيانات: استدعاءات Firestore مباشرة من UI في أغلب الشاشات.

## State Management
- حالياً: Provider محدود + `setState` كثيف.
- المطلوب: نقل الحالة إلى طبقة Presentation (Cubit/Notifier) لكل Feature.

## فصل الواجهات عن المنطق
- UI يحتوي منطق الشبكة والـFirestore.
- مطلوب Repositories + UseCases لكل Feature.

## Performance
- إعادة بناء واسعة بسبب `setState` في شاشات كبيرة.
- غياب Pagination في بعض القوائم.
- استخدام صور الشبكة بدون قيود واضحة على الحجم.

## Assets & Dependencies
- توجد حزم غير مستخدمة: cloud_functions, firebase_messaging, firebase_analytics, firebase_crashlytics, photo_view, lottie, flutter_staggered_animations, intl, image, uuid, connectivity_plus.
- أصول مهملة مثل `assets/lottie/*.json` وملف احتياطي `lib/screens/auth/auth_screen.dart.backup`.

## Error Handling
- الأخطاء تُعرض بـ SnackBar محلياً.
- مطلوب طبقة Error موحدة + mapping للرسائل.

## Startup
- Firebase initialize داخل `main.dart` مع try/catch.
- مطلوب قياس أداء الإقلاع وتجزئة التهيئة.

## Outputs

### Health Score
- 58/100
  - (+) واجهات كثيرة ومتكاملة.
  - (-) غياب الطبقات المعمارية.
  - (-) أمان وقواعد بيانات تحتاج تشديد.

### Refactor Plan (3 مراحل)
1) **تثبيت الأساس**: نقل Authentication Feature كبداية، إنشاء طبقات Domain/Data، وتنظيف الاعتماديات المهملة.
2) **توسعة الميزات**: نقل Booking/Chat/Payments إلى Features كاملة مع Repositories.
3) **تحسين الأداء**: تقليل إعادة البناء، Pagination، وتعزيز الاختبارات.

### Folder Structure المقترحة
```text
lib/
  app/
    router/
    theme/
  core/
    error/
    utils/
    widgets/
    services/
  features/
    auth/
      data/
      domain/
      presentation/
    profile/
      data/
      domain/
      presentation/
    booking/
      data/
      domain/
      presentation/
    chat/
      data/
      domain/
      presentation/
    payments/
      data/
      domain/
      presentation/
```

### Performance Optimization Plan
- تقليل `setState` واستبداله بإدارة حالة Feature-scoped.
- استخدام Pagination وLazy Loading في القوائم الكبيرة.
- تفكيك الشاشات الضخمة إلى Widgets أصغر مع `const`.
- كاش صور مضبوط وحدود واضحة للأحجام.

### Minimal Test Plan
- Unit: UseCases + Validators.
- Widget: Auth/Booking/Chat/Payment screens.
- Integration: رحلة حجز كاملة من البحث حتى التقييم.

### Coding Guidelines (10 قواعد)
1) UI لا يتواصل مباشرة مع Firestore.
2) كل Feature لديه Repository وUseCase.
3) لا تحديث لحالة حساسة بدون Server-side verification.
4) كل شاشة لها Loading/Empty/Error قياسية.
5) استخدام `const` عند الإمكان.
6) الالتزام بـ RTL/LTR في كل عنصر نصي.
7) لا تخزين أسرار داخل الكود.
8) فصل النصوص إلى i18n.
9) استخدام Pagination لكل قائمة كبيرة.
10) كل تغيير بيانات يمر عبر طبقة Domain.

## Refactor Start (تمهيد)
- بدء نقل Feature: auth → `lib/features/auth/presentation/screens/`.
- تحديث الاستيراد في router ليعكس المسار الجديد.
