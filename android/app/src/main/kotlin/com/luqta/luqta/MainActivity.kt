package com.luqta.luqta

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onBackPressed() {
        // Disable system back to prevent exiting the app from the root.
    }
}
