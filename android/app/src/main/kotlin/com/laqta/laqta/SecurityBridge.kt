package com.laqta.laqta

import android.content.Context
import android.content.pm.PackageManager
import android.hardware.SensorManager
import android.os.Build
import android.os.Debug
import android.provider.Settings
import android.view.Window
import android.view.WindowManager
import java.io.File
import java.net.InetSocketAddress
import java.net.Socket
import java.security.MessageDigest

class SecurityBridge(private val context: Context) {
    companion object {
        fun loadNative() {
            try {
                System.loadLibrary("security")
            } catch (_: Throwable) {
                // Native checks are defense-in-depth. Kotlin checks remain active.
            }
        }
    }

    private external fun nativeAntiDebug(): Boolean
    private external fun nativeScanMaps(): String

    fun enableFlagSecure(window: Window) {
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }

    fun checkRoot(): Map<String, Any?> {
        val vectors = mutableListOf<String>()
        val suPaths = listOf(
            "/system/bin/su",
            "/system/xbin/su",
            "/sbin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/data/local/su",
        )
        suPaths.filter { File(it).exists() }.forEach { vectors.add("su_binary:$it") }

        val busyboxPaths = listOf(
            "/system/bin/busybox",
            "/system/xbin/busybox",
            "/sbin/busybox",
            "/vendor/bin/busybox",
            "/data/local/busybox",
        )
        busyboxPaths.filter { File(it).exists() }.forEach { vectors.add("busybox:$it") }

        if (Build.TAGS?.contains("test-keys") == true) vectors.add("build_tags_test_keys")
        if (Build.TYPE != "user") vectors.add("build_type:${Build.TYPE}")
        if (File("/system/app/Superuser.apk").exists()) vectors.add("superuser_apk")

        val dangerousPackages = listOf(
            "com.topjohnwu.magisk",
            "eu.chainfire.supersu",
            "com.noshufou.android.su",
            "com.thirdparty.superuser",
            "io.github.huskydg.magisk",
            "com.kingroot.kinguser",
            "com.kingo.root",
        )
        dangerousPackages.filter { isPackageInstalled(it) }.forEach { vectors.add("dangerous_app:$it") }

        return mapOf("detected" to vectors.isNotEmpty(), "vectors" to vectors)
    }

    fun checkEmulator(): Map<String, Any?> {
        val vectors = mutableListOf<String>()
        val fingerprint = Build.FINGERPRINT.lowercase()
        val model = Build.MODEL.lowercase()
        val manufacturer = Build.MANUFACTURER.lowercase()
        val hardware = Build.HARDWARE.lowercase()
        val product = Build.PRODUCT.lowercase()
        val brand = Build.BRAND.lowercase()
        val device = Build.DEVICE.lowercase()

        if (fingerprint.contains("generic") || fingerprint.contains("emulator") || fingerprint.contains("sdk")) vectors.add("fingerprint:$fingerprint")
        if (model.contains("sdk") || model.contains("emulator") || model.contains("android sdk built for")) vectors.add("model:$model")
        if (manufacturer.contains("genymotion")) vectors.add("manufacturer:$manufacturer")
        if (hardware.contains("goldfish") || hardware.contains("ranchu") || hardware.contains("vbox86")) vectors.add("hardware:$hardware")
        if (product.contains("sdk") || product == "google_sdk") vectors.add("product:$product")
        if (brand.startsWith("generic") && device.startsWith("generic")) vectors.add("generic_brand_device")
        if (Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID).orEmpty().all { it == '0' }) vectors.add("android_id_all_zero")

        val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        val sensorCount = sensorManager?.getSensorList(android.hardware.Sensor.TYPE_ALL)?.size ?: 0
        if (sensorCount in 1..3) vectors.add("low_sensor_count:$sensorCount")
        if (getSystemProperty("qemu.sf.fake_camera") == "1") vectors.add("qemu_fake_camera")

        return mapOf("detected" to vectors.isNotEmpty(), "vectors" to vectors, "sensorCount" to sensorCount)
    }

    fun checkHooking(): Map<String, Any?> {
        val vectors = mutableListOf<String>()
        vectors.addAll(scanMapsForHooks())
        if (isPortOpen(27042)) vectors.add("frida_port:27042")
        if (isPortOpen(27043)) vectors.add("frida_port:27043")
        Thread.getAllStackTraces().keys.map { it.name.lowercase() }.forEach { name ->
            if (name.contains("gum-js-loop") || name.contains("gmain") || name.contains("gdbus") || name.contains("frida")) {
                vectors.add("thread:$name")
            }
        }
        try {
            val nativeFinding = nativeScanMaps()
            if (nativeFinding.isNotBlank()) vectors.add("native_maps:$nativeFinding")
        } catch (_: Throwable) {
            // Native hook scan is optional defense-in-depth.
        }
        return mapOf("detected" to vectors.isNotEmpty(), "vectors" to vectors.distinct())
    }

    fun checkDebugger(): Map<String, Any?> {
        val vectors = mutableListOf<String>()
        if (Debug.isDebuggerConnected()) vectors.add("debugger_connected")
        if (Debug.waitingForDebugger()) vectors.add("waiting_for_debugger")
        try {
            if (nativeAntiDebug()) vectors.add("native_anti_debug")
        } catch (_: Throwable) {
            // Native anti-debug is optional defense-in-depth.
        }
        return mapOf("detected" to vectors.isNotEmpty(), "vectors" to vectors)
    }

    fun verifyIntegrity(): Map<String, Any?> {
        val vectors = mutableListOf<String>()
        val packageName = context.packageName
        if (packageName != "com.laqta.laqta") vectors.add("package_name_mismatch")

        val expected = BuildConfig.EXPECTED_SIGNATURE_SHA256.trim()
        val actualHashes = signingCertificateHashes()
        if (expected.isBlank()) {
            vectors.add("expected_signature_not_configured")
        } else if (actualHashes.none { it.equals(expected, ignoreCase = true) }) {
            vectors.add("signature_mismatch")
        }

        val installer = try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                context.packageManager.getInstallSourceInfo(packageName).installingPackageName
            } else {
                @Suppress("DEPRECATION")
                context.packageManager.getInstallerPackageName(packageName)
            }
        } catch (_: Throwable) {
            null
        }
        if (!installer.isNullOrBlank() && installer != "com.android.vending") {
            vectors.add("non_play_installer:$installer")
        }

        return mapOf(
            "detected" to vectors.any { it == "signature_mismatch" || it == "package_name_mismatch" },
            "vectors" to vectors,
            "packageName" to packageName,
            "installer" to installer,
            "signingCertSha256" to actualHashes,
        )
    }

    private fun scanMapsForHooks(): List<String> {
        val findings = mutableListOf<String>()
        return try {
            File("/proc/self/maps").useLines { lines ->
                lines.forEach { line ->
                    val normalized = line.lowercase()
                    if (normalized.contains("frida") || normalized.contains("xposed") || normalized.contains("substrate") || normalized.contains("zygote_injected")) {
                        findings.add("maps_marker:${normalized.take(96)}")
                    }
                    if (normalized.contains(".so") && normalized.contains("/data/local/tmp")) {
                        findings.add("suspicious_library_path:${normalized.take(96)}")
                    }
                }
            }
            findings
        } catch (_: Throwable) {
            emptyList()
        }
    }

    private fun isPackageInstalled(packageName: String): Boolean {
        return try {
            context.packageManager.getPackageInfo(packageName, 0)
            true
        } catch (_: Throwable) {
            false
        }
    }

    private fun isPortOpen(port: Int): Boolean {
        return try {
            Socket().use { socket ->
                socket.connect(InetSocketAddress("127.0.0.1", port), 120)
                true
            }
        } catch (_: Throwable) {
            false
        }
    }

    private fun signingCertificateHashes(): List<String> {
        return try {
            val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val info = context.packageManager.getPackageInfo(context.packageName, PackageManager.GET_SIGNING_CERTIFICATES)
                info.signingInfo?.apkContentsSigners ?: emptyArray()
            } else {
                @Suppress("DEPRECATION")
                val info = context.packageManager.getPackageInfo(context.packageName, PackageManager.GET_SIGNATURES)
                @Suppress("DEPRECATION")
                info.signatures ?: emptyArray()
            }
            signatures.map { sha256(it.toByteArray()) }
        } catch (_: Throwable) {
            emptyList()
        }
    }

    private fun sha256(bytes: ByteArray): String {
        val digest = MessageDigest.getInstance("SHA-256").digest(bytes)
        return digest.joinToString("") { "%02x".format(it) }
    }

    private fun getSystemProperty(name: String): String? {
        return try {
            val systemProperties = Class.forName("android.os.SystemProperties")
            val get = systemProperties.getMethod("get", String::class.java)
            get.invoke(null, name) as? String
        } catch (_: Throwable) {
            null
        }
    }
}
