plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("kotlin-android")
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.YamanKartal.coursaty_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
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
    buildTypes {
        release {
            // Use the debug keystore until a production release key is available.
            signingConfig = signingConfigs.getByName("debug")
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
