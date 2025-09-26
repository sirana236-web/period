plugins {
    id("com.android.application")
    id("kotlin-android")
}

android {
    namespace = "com.example.period_tracker"
    compileSdk = 33

    defaultConfig {
        applicationId = "com.example.period_tracker"
        minSdk = 21
        targetSdk = 33
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }
}

val flutterRoot = localProperties.getProperty("flutter.sdk")
if (flutterRoot == null) {
    throw GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
}

apply(from = "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle")

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.7.10")
}
