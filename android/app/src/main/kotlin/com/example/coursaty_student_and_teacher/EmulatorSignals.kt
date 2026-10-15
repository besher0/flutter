package com.example.coursaty_student_and_teacher

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorManager
import android.os.Build
import java.io.File

/**
 * Signs that the app runs in an emulator or a PC Android environment
 * (Android Studio, Genymotion, BlueStacks, Nox, LDPlayer, MEmu, MuMu,
 * Windows Subsystem for Android, ...). Each entry names one signal; an empty
 * list means none was found.
 *
 * Desktop emulators usually report isPhysicalDevice = true and copy real
 * phone models, so these checks look at what they cannot hide easily: an x86
 * CPU or hypervisor, QEMU/VirtualBox properties and files, and a missing or
 * emulator-named motion sensor. Every real phone has an ARM CPU and an
 * accelerometer.
 */
object EmulatorSignals {
    fun collect(context: Context): List<String> {
        val signals = mutableListOf<String>()
        runCheck(signals) { checkBuild(it) }
        runCheck(signals) { checkProperties(it) }
        runCheck(signals) { checkFiles(it) }
        runCheck(signals) { checkCpu(it) }
        runCheck(signals) { checkSensors(context, it) }
        return signals
    }

    private fun runCheck(signals: MutableList<String>, check: (MutableList<String>) -> Unit) {
        try {
            check(signals)
        } catch (_: Throwable) {
            // A failing check proves nothing either way; the others still run.
        }
    }

    private fun checkBuild(signals: MutableList<String>) {
        if (Build.SUPPORTED_ABIS.firstOrNull()?.startsWith("x86") == true) {
            signals.add("abi:x86")
        }
        val model = Build.MODEL.lowercase()
        if (listOf("google_sdk", "emulator", "android sdk built for", "sdk_gphone",
                "subsystem for android").any { model.contains(it) }) {
            signals.add("model")
        }
        if (Build.MANUFACTURER.lowercase().contains("genymotion")) {
            signals.add("manufacturer")
        }
        val hardware = Build.HARDWARE.lowercase()
        if (hardware in setOf("goldfish", "ranchu", "vbox86", "nox", "ttvm_x86", "cutf_cvm")) {
            signals.add("hardware")
        }
        val product = Build.PRODUCT.lowercase()
        if (product in setOf("sdk", "google_sdk", "sdk_x86", "sdk_google", "vbox86p",
                "emulator", "simulator") || product.startsWith("sdk_gphone")) {
            signals.add("product")
        }
        if (Build.FINGERPRINT.startsWith("generic") || Build.FINGERPRINT.contains("vbox86")) {
            signals.add("fingerprint")
        }
        if (Build.BOOTLOADER.lowercase() == "nox") {
            signals.add("bootloader")
        }
    }

    private fun checkProperties(signals: MutableList<String>) {
        if (systemProperty("ro.kernel.qemu") == "1" || systemProperty("ro.boot.qemu") == "1") {
            signals.add("prop:qemu")
        }
        if (systemProperty("init.svc.qemud").isNotEmpty() ||
            systemProperty("init.svc.qemu-props").isNotEmpty()) {
            signals.add("prop:qemu-service")
        }
        val hardware = systemProperty("ro.hardware").lowercase()
        if (hardware == "goldfish" || hardware == "ranchu" || hardware.contains("vbox")) {
            signals.add("prop:hardware")
        }
    }

    private val emulatorFiles = listOf(
        "/dev/socket/qemud",
        "/dev/qemu_pipe",
        "/sys/qemu_trace",
        "/system/bin/qemu-props",
        "/system/lib/libc_malloc_debug_qemu.so",
        "/dev/socket/genyd",
        "/dev/socket/baseband_genyd",
        "/system/bin/nox-prop",
        "/system/bin/nox-vbox-sf",
        "/system/lib/libnoxspeedup.so",
        "/system/bin/ldinit",
        "/system/bin/ldmountsf",
        "/system/lib/libldutils.so",
        "/boot/bstsetup.env",
        "/system/xbin/bstk",
        "/data/.bluestacks.prop",
        "/system/bin/microvirtd",
        "/system/lib/vboxsf.ko",
        "/system/lib/vboxguest.ko",
    )

    private fun checkFiles(signals: MutableList<String>) {
        emulatorFiles.firstOrNull { File(it).exists() }?.let { signals.add("file:$it") }
    }

    private fun checkCpu(signals: MutableList<String>) {
        val cpuInfo = File("/proc/cpuinfo").takeIf { it.canRead() }?.readText()?.lowercase()
            ?: return
        if (Regex("^flags\\s*:.*\\bhypervisor\\b", RegexOption.MULTILINE).containsMatchIn(cpuInfo)) {
            signals.add("cpu:hypervisor")
        }
        if (cpuInfo.contains("genuineintel") || cpuInfo.contains("authenticamd")) {
            signals.add("cpu:x86")
        }
    }

    private fun checkSensors(context: Context, signals: MutableList<String>) {
        val manager = context.getSystemService(Context.SENSOR_SERVICE) as? SensorManager ?: return
        if (manager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER) == null) {
            signals.add("sensor:no-accelerometer")
        }
        val emulatorNames = listOf("goldfish", "ranchu", "bluestacks", "genymotion",
            "microvirt", "ldplayer", "nox", "vbox")
        val suspicious = manager.getSensorList(Sensor.TYPE_ALL).firstOrNull { sensor ->
            val text = "${sensor.name} ${sensor.vendor}".lowercase()
            emulatorNames.any { text.contains(it) }
        }
        if (suspicious != null) signals.add("sensor:emulated")
    }

    private fun systemProperty(name: String): String = try {
        val clazz = Class.forName("android.os.SystemProperties")
        (clazz.getMethod("get", String::class.java).invoke(null, name) as? String).orEmpty()
    } catch (_: Throwable) {
        ""
    }
}
