package com.laqta.laqta

import android.app.Activity
import com.google.android.gms.tasks.Tasks
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import io.flutter.plugin.common.MethodChannel

class IntegrityService(private val activity: Activity) {
    fun requestIntegrityToken(arguments: Map<*, *>?, result: MethodChannel.Result) {
        val nonce = arguments?.get("nonce") as? String
        if (nonce.isNullOrBlank()) {
            result.error("INVALID_NONCE", "Nonce is required", null)
            return
        }

        val cloudProjectNumber = when (val raw = arguments["cloudProjectNumber"]) {
            is Int -> raw.toLong()
            is Long -> raw
            is Number -> raw.toLong()
            else -> 0L
        }

        val builder = IntegrityTokenRequest.builder().setNonce(nonce)
        if (cloudProjectNumber > 0L) {
            builder.setCloudProjectNumber(cloudProjectNumber)
        }

        val manager = IntegrityManagerFactory.create(activity)
        manager.requestIntegrityToken(builder.build())
            .addOnSuccessListener { response -> result.success(response.token()) }
            .addOnFailureListener { error ->
                result.error(
                    "PLAY_INTEGRITY_FAILED",
                    error.localizedMessage ?: "Play Integrity request failed",
                    null,
                )
            }
    }
}
