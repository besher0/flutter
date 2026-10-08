import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("kotlin-android")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

fun requiredKeystoreProperty(name: String): String {
    return keystoreProperties.getProperty(name)
        ?: throw GradleException("Missing '$name' in android/key.properties")
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

android {
    namespace = "com.example.coursaty_student_and_teacher"
    compileSdk = 36
    ndkVersion = "29.0.14206865"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        applicationId = "com.YamanKartal.coursaty_app"
        minSdk = 28
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true

        val playIntegrityProjectNumber =
            (project.findProperty("GOOGLE_PLAY_INTEGRITY_PROJECT_NUMBER") as String?) ?: "0"

        buildConfigField(
            "long",
            "GOOGLE_PLAY_INTEGRITY_PROJECT_NUMBER",
            "${playIntegrityProjectNumber}L"
        )
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = requiredKeystoreProperty("keyAlias")
                keyPassword = requiredKeystoreProperty("keyPassword")
                storeFile = rootProject.file(requiredKeystoreProperty("storeFile"))
                storePassword = requiredKeystoreProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("com.google.android.play:integrity:1.6.0")
}
