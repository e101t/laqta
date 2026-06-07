package com.laqta.laqta

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Debug
import java.io.File
import java.security.MessageDigest

class DeviceSecurityService(private val context: Context) {
    fun check(): Map<String, Any?> {
        val warnings = mutableListOf<String>()
        val rooted = isRooted()
        val emulator = isLikelyEmulator()
        val debugger = Debug.isDebuggerConnected()
        val hooking = hasHookingFramework()
        val signatureValid = isSignatureValid()

        if (rooted) warnings.add("root_detected")
        if (emulator) warnings.add("emulator_detected")
        if (debugger) warnings.add("debugger_attached")
        if (hooking) warnings.add("hooking_framework_detected")
        if (signatureValid == false) warnings.add("signature_mismatch")

        return mapOf(
            "isRooted" to rooted,
            "isEmulator" to emulator,
            "isDebuggerAttached" to debugger,
            "hasHookingFramework" to hooking,
            "signatureValid" to signatureValid,
            "warnings" to warnings,
        )
    }

    private fun isRooted(): Boolean {
        val paths = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/su/bin/su",
        )
        return paths.any { File(it).exists() } || Build.TAGS?.contains("test-keys") == true
    }

    private fun isLikelyEmulator(): Boolean {
        val fingerprint = Build.FINGERPRINT.lowercase()
        val model = Build.MODEL.lowercase()
        val manufacturer = Build.MANUFACTURER.lowercase()
        val brand = Build.BRAND.lowercase()
        val device = Build.DEVICE.lowercase()
        val product = Build.PRODUCT.lowercase()
        return fingerprint.startsWith("generic") ||
            fingerprint.contains("vbox") ||
            fingerprint.contains("test-keys") ||
            model.contains("google_sdk") ||
            model.contains("emulator") ||
            model.contains("android sdk built for") ||
            manufacturer.contains("genymotion") ||
            (brand.startsWith("generic") && device.startsWith("generic")) ||
            product.contains("sdk_gphone") ||
            product == "google_sdk"
    }

    private fun hasHookingFramework(): Boolean {
        return try {
            File("/proc/self/maps").useLines { lines ->
                lines.any { line ->
                    val normalized = line.lowercase()
                    normalized.contains("frida") ||
                        normalized.contains("xposed") ||
                        normalized.contains("substrate") ||
                        normalized.contains("zygisk")
                }
            }
        } catch (_: Throwable) {
            false
        }
    }

    private fun isSignatureValid(): Boolean? {
        val expected = BuildConfig.EXPECTED_SIGNATURE_SHA256
        if (expected.isBlank()) return null
        return try {
            val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val info = context.packageManager.getPackageInfo(
                    context.packageName,
                    PackageManager.GET_SIGNING_CERTIFICATES,
                )
                info.signingInfo?.apkContentsSigners ?: return false
            } else {
                @Suppress("DEPRECATION")
                val info = context.packageManager.getPackageInfo(
                    context.packageName,
                    PackageManager.GET_SIGNATURES,
                )
                @Suppress("DEPRECATION")
                info.signatures ?: return false
            }
            signatures.any { signature -> sha256(signature.toByteArray()).equals(expected, ignoreCase = true) }
        } catch (_: Throwable) {
            false
        }
    }

    private fun sha256(bytes: ByteArray): String {
        val digest = MessageDigest.getInstance("SHA-256").digest(bytes)
        return digest.joinToString("") { "%02x".format(it) }
    }
}
