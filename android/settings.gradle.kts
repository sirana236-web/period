include(":app")

val flutterProjectRoot = rootProject.projectDir.parentFile.toPath()

val localPropertiesFile = File(rootProject.projectDir, "local.properties")
if (localPropertiesFile.exists()) {
    val properties = java.util.Properties()
    localPropertiesFile.inputStream().use { properties.load(it) }
    
    val flutterSdkPath = properties.getProperty("flutter.sdk")
    if (flutterSdkPath != null) {
        apply {
            from("$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle")
        }
    }
}
