package com.example.coursaty_student_and_teacher

import android.content.Context
import android.media.AudioManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager

/**
 * Short vibrations for the app's haptics (AppHaptics on the Dart side).
 *
 * Uses the vibration motor directly instead of View.performHapticFeedback:
 * that one depends on the system "touch feedback" setting (off by default on
 * Xiaomi MIUI/HyperOS and Honor MagicOS) and their builds ignore its light
 * effects, so nothing was felt on those phones.
 *
 * Silent mode is respected: nothing vibrates, and the call still counts as
 * handled so Dart does not try another way.
 */
object AppVibration {
    /** Returns true when the kind was handled (played, or muted on purpose). */
    fun play(context: Context, kind: String): Boolean {
        val vibrator = vibrator(context) ?: return false
        if (!vibrator.hasVibrator()) return false
        val audio = context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager
        if (audio?.ringerMode == AudioManager.RINGER_MODE_SILENT) return true

        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val effect = effectFor(kind, vibrator) ?: return false
                vibrator.vibrate(effect)
            } else {
                val pattern = legacyPatternFor(kind) ?: return false
                @Suppress("DEPRECATION")
                vibrator.vibrate(pattern, -1)
            }
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun vibrator(context: Context): Vibrator? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager)
                ?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        }

    private fun effectFor(kind: String, vibrator: Vibrator): VibrationEffect? {
        // Predefined effects (Android 10+) are tuned by each phone's maker for
        // its motor; they fall back to a plain vibration where not supported.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            when (kind) {
                "lightTap" -> return VibrationEffect.createPredefined(VibrationEffect.EFFECT_CLICK)
                "selection" -> return VibrationEffect.createPredefined(VibrationEffect.EFFECT_TICK)
            }
        }
        val amplitudes = vibrator.hasAmplitudeControl()
        fun oneShot(ms: Long, amplitude: Int) = VibrationEffect.createOneShot(
            ms,
            if (amplitudes) amplitude else VibrationEffect.DEFAULT_AMPLITUDE,
        )
        // Patterns: timings start with a wait, then pulse / pause / pulse...
        fun pattern(timings: LongArray, levels: IntArray) =
            if (amplitudes) {
                VibrationEffect.createWaveform(timings, levels, -1)
            } else {
                VibrationEffect.createWaveform(timings, -1)
            }
        return when (kind) {
            "lightTap" -> oneShot(18, 140)
            "selection" -> oneShot(12, 90)
            // Two rising taps.
            "success" -> pattern(longArrayOf(0, 25, 70, 35), intArrayOf(0, 120, 0, 220))
            // Three firm taps, the last the strongest.
            "error" -> pattern(
                longArrayOf(0, 35, 60, 35, 60, 50),
                intArrayOf(0, 180, 0, 180, 0, 255),
            )
            // A strong tap then a light one.
            "warning" -> pattern(longArrayOf(0, 45, 90, 20), intArrayOf(0, 255, 0, 110))
            else -> null
        }
    }

    private fun legacyPatternFor(kind: String): LongArray? = when (kind) {
        "lightTap" -> longArrayOf(0, 18)
        "selection" -> longArrayOf(0, 12)
        "success" -> longArrayOf(0, 25, 70, 35)
        "error" -> longArrayOf(0, 35, 60, 35, 60, 50)
        "warning" -> longArrayOf(0, 45, 90, 20)
        else -> null
    }
}
