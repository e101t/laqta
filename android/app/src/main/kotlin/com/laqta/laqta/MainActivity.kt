package com.laqta.laqta

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        SecurityBridge.loadNative()
        window.addFlags(android.view.WindowManager.LayoutParams.FLAG_SECURE)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val integrityService = IntegrityService(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "laqta/security/integrity")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestIntegrityToken" -> integrityService.requestIntegrityToken(call.arguments as? Map<*, *>, result)
                    else -> result.notImplemented()
                }
            }

        val deviceSecurityService = DeviceSecurityService(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "laqta/security/device")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "checkDeviceSecurity" -> result.success(deviceSecurityService.check())
                    else -> result.notImplemented()
                }
            }

        val securityBridge = SecurityBridge(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "laqta/security/rasp")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "checkRoot" -> result.success(securityBridge.checkRoot())
                    "checkEmulator" -> result.success(securityBridge.checkEmulator())
                    "checkHooking" -> result.success(securityBridge.checkHooking())
                    "checkDebugger" -> result.success(securityBridge.checkDebugger())
                    "verifyIntegrity" -> result.success(securityBridge.verifyIntegrity())
                    "enableFlagSecure" -> {
                        securityBridge.enableFlagSecure(window)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
