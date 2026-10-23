package com.example.coursaty_student_and_teacher

import android.media.MediaDrm
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.StandardIntegrityManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.Signature
import java.security.spec.ECGenParameterSpec
import java.util.UUID

class MainActivity : FlutterActivity() {
    private val channelName = "coursaty/video_security"
    private val keyAlias = "coursaty_video_device_key_v1"
    private val keyStoreType = "AndroidKeyStore"
    private lateinit var integrityManager: StandardIntegrityManager
    private var integrityProvider: StandardIntegrityManager.StandardIntegrityTokenProvider? = null

    // The Flutter engine, and the Dart download with it, ends with this
    // activity (the back button on older Android, or the system reclaiming
    // it). Stop the keep-alive service so its "downloading" notification does
    // not outlive the download.
    override fun onDestroy() {
        if (!isChangingConfigurations) {
            DownloadKeepAliveService.stop(applicationContext)
        }
        super.onDestroy()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        integrityManager = IntegrityManagerFactory.createStandard(applicationContext)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "prepareIntegrity" -> prepareIntegrity(result)
                    "requestIntegrityToken" -> {
                        val requestHash = call.argument<String>("requestHash")
                        requestIntegrityToken(requestHash, result)
                    }
                    "ensureVideoDeviceKey" -> {
                        ensureVideoDeviceKey()
                        result.success(null)
                    }
                    "hasVideoDeviceKey" -> result.success(hasVideoDeviceKey())
                    "getVideoDevicePublicKey" -> result.success(getVideoDevicePublicKey())
                    "signVideoPayload" -> {
                        val payload = call.argument<String>("payload")
                        if (payload.isNullOrEmpty()) {
                            result.error("invalid_payload", "payload is required", null)
                        } else {
                            result.success(signVideoPayload(payload))
                        }
                    }
                    "deleteVideoDeviceKey" -> {
                        deleteVideoDeviceKey()
                        result.success(null)
                    }
                    // Stable per device and app signing key; survives app
                    // reinstalls (reset only by a factory reset).
                    "getLoginDeviceId" -> result.success(
                        Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
                    )
                    // Per device and independent of the signing key, unlike
                    // ANDROID_ID: recognises this phone after a reinstall with
                    // another signature (an APK from outside the store, then
                    // the store version). Null without Widevine.
                    "getLoginDeviceAltId" -> Thread {
                        val id = widevineDeviceId()
                        Handler(Looper.getMainLooper()).post { result.success(id) }
                    }.start()
                    "getEmulatorSignals" -> result.success(EmulatorSignals.collect(applicationContext))
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "coursaty/background_downloads")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        try {
                            DownloadKeepAliveService.start(applicationContext)
                            result.success(true)
                        } catch (error: Exception) {
                            // e.g. not allowed to start from the background.
                            result.error("keep_alive_failed", error.javaClass.simpleName, null)
                        }
                    }
                    "stop" -> {
                        DownloadKeepAliveService.stop(applicationContext)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun widevineDeviceId(): String? = try {
        val drm = MediaDrm(UUID.fromString("edef8ba9-79d6-4ace-a3c8-27dcd51d21ed"))
        try {
            drm.getPropertyByteArray(MediaDrm.PROPERTY_DEVICE_UNIQUE_ID)
                .joinToString("") { "%02x".format(it) }
                .takeIf { it.isNotEmpty() }
        } finally {
            drm.close()
        }
    } catch (_: Exception) {
        null
    }

    private fun prepareIntegrity(result: MethodChannel.Result) {
        val projectNumber = BuildConfig.GOOGLE_PLAY_INTEGRITY_PROJECT_NUMBER
        if (projectNumber <= 0L) {
            result.error(
                "missing_project_number",
                "GOOGLE_PLAY_INTEGRITY_PROJECT_NUMBER must be configured",
                null
            )
            return
        }

        val request = StandardIntegrityManager.PrepareIntegrityTokenRequest.builder()
            .setCloudProjectNumber(projectNumber)
            .build()
        integrityManager.prepareIntegrityToken(request)
            .addOnSuccessListener { provider ->
                integrityProvider = provider
                result.success(null)
            }
            .addOnFailureListener { error ->
                result.error("integrity_prepare_failed", error.message, null)
            }
    }

    private fun requestIntegrityToken(requestHash: String?, result: MethodChannel.Result) {
        if (requestHash.isNullOrEmpty()) {
            result.error("missing_request_hash", "requestHash is required", null)
            return
        }
        val provider = integrityProvider
        if (provider == null) {
            result.error("integrity_not_prepared", "prepareIntegrity must complete first", null)
            return
        }

        val request = StandardIntegrityManager.StandardIntegrityTokenRequest.builder()
            .setRequestHash(requestHash)
            .build()
        provider.request(request)
            .addOnSuccessListener { token -> result.success(token.token()) }
            .addOnFailureListener { error ->
                integrityProvider = null
                result.error("integrity_request_failed", error.message, null)
            }
    }

    private fun ensureVideoDeviceKey() {
        val keyStore = KeyStore.getInstance(keyStoreType).apply { load(null) }
        if (keyStore.containsAlias(keyAlias)) return

        val generator = KeyPairGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_EC,
            keyStoreType
        )
        val builder = KeyGenParameterSpec.Builder(
            keyAlias,
            KeyProperties.PURPOSE_SIGN
        )
            .setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))
            .setDigests(KeyProperties.DIGEST_SHA256)
            .setUserAuthenticationRequired(false)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            builder.setUnlockedDeviceRequired(false)
        }

        generator.initialize(builder.build())
        generator.generateKeyPair()
    }

    private fun hasVideoDeviceKey(): Boolean {
        val keyStore = KeyStore.getInstance(keyStoreType).apply { load(null) }
        return keyStore.containsAlias(keyAlias)
    }

    private fun getVideoDevicePublicKey(): String {
        ensureVideoDeviceKey()
        val keyStore = KeyStore.getInstance(keyStoreType).apply { load(null) }
        val certificate = keyStore.getCertificate(keyAlias)
        return Base64.encodeToString(
            certificate.publicKey.encoded,
            Base64.URL_SAFE or Base64.NO_WRAP or Base64.NO_PADDING
        )
    }

    private fun signVideoPayload(payload: String): String {
        ensureVideoDeviceKey()
        val keyStore = KeyStore.getInstance(keyStoreType).apply { load(null) }
        val privateKey = keyStore.getKey(keyAlias, null)
        val signature = Signature.getInstance("SHA256withECDSA")
        signature.initSign(privateKey as java.security.PrivateKey)
        signature.update(payload.toByteArray(Charsets.UTF_8))
        return Base64.encodeToString(
            signature.sign(),
            Base64.URL_SAFE or Base64.NO_WRAP or Base64.NO_PADDING
        )
    }

    private fun deleteVideoDeviceKey() {
        val keyStore = KeyStore.getInstance(keyStoreType).apply { load(null) }
        if (keyStore.containsAlias(keyAlias)) {
            keyStore.deleteEntry(keyAlias)
        }
    }
}
