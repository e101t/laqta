# Flutter engine and plugin registrant
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase / Google Play services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.play.core.integrity.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
-dontwarn com.google.android.play.core.**

# Stripe SDK
-keep class com.stripe.android.** { *; }
-keep class com.stripe.** { *; }
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider

# Google Maps / Places
-keep class com.google.android.libraries.maps.** { *; }
-keep class com.google.android.gms.maps.** { *; }
-dontwarn com.google.android.libraries.maps.**

# Kotlin metadata used by reflection-heavy Android libraries
-keep class kotlin.Metadata { *; }
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod
-dontwarn kotlinx.coroutines.debug.**
-assumenosideeffects class kotlinx.coroutines.debug.** { *; }

# LAQTA native security channels. Dart code is obfuscated separately by Flutter
# release flags; keep channel entry points available for Flutter MethodChannel.
-keep class com.laqta.laqta.MainActivity { *; }
-keep class com.laqta.laqta.IntegrityService { *; }
-keep class com.laqta.laqta.DeviceSecurityService { *; }
