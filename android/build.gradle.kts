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
