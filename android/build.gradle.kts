allprojects {
    repositories {
        google()
        mavenCentral()
    }
    afterEvaluate {
        // Check if the sub-project is an Android library (like a Flutter plugin) or an App
        if (plugins.hasPlugin("com.android.library") || plugins.hasPlugin("com.android.application")) {
            // Safely cast to the Android extension and force the NDK version
            extensions.configure<com.android.build.gradle.BaseExtension>("android") {
                ndkVersion = "29.0.14206865"
                // device_safety_info 1.5.x asks for compileSdk 37, which AGP 8.11 cannot use
                // (SDK 37 is installed as "android-37.0", a layout AGP 8.11 does not read:
                // "Failed to find target with hash string 'android-37'"). The plugin uses
                // nothing newer than API 35, so it builds against 36 like the app.
                // Remove once AGP is upgraded.
                if (project.name == "device_safety_info") {
                    compileSdkVersion(36)
                }
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
