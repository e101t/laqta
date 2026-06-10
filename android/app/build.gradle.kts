import java.util.Properties
import org.gradle.api.GradleException

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}
val releaseSigningConfigured = listOf(
    "storeFile",
    "storePassword",
    "keyAlias",
    "keyPassword"
).all { keystoreProperties[it] != null }

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

val googleMapsApiKey: String =
    (findProperty("googleMapsApiKey") as String?)
        ?: localProperties.getProperty("googleMapsApiKey")
        ?: System.getenv("GOOGLE_MAPS_API_KEY")
        ?: ""

val expectedSignatureSha256: String =
    (findProperty("expectedSignatureSha256") as String?)
        ?: localProperties.getProperty("expectedSignatureSha256")
        ?: System.getenv("EXPECTED_SIGNATURE_SHA256")
        ?: ""

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android/Kotlin plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.laqta.laqta"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.laqta.laqta"
        // Keep the plugin-resolved minSdk; apksigner is invoked with --min-sdk-version 23 in the audit signing script to verify v1 + v2 + v3 compatibility.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Avoid committing API keys into the repo. Provide via:
        // - android/local.properties: googleMapsApiKey=...
        // - env var: GOOGLE_MAPS_API_KEY
        // - gradle prop: -PgoogleMapsApiKey=...
        resValue("string", "google_maps_key", googleMapsApiKey)
        resValue("string", "app_name", "LAQTA")
        buildConfigField("String", "EXPECTED_SIGNATURE_SHA256", "\"$expectedSignatureSha256\"")
    }

    flavorDimensions += "environment"

    productFlavors {
        create("development") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "LAQTA Dev")
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "LAQTA Staging")
        }
        create("production") {
            dimension = "environment"
            resValue("string", "app_name", "LAQTA")
        }
    }

    buildFeatures {
        buildConfig = true
    }

    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
            version = "3.22.1"
        }
    }

    packaging {
        resources {
            excludes += setOf(
                "assets/ds-test-ec.txt",
                "assets/ds-test-rsa.txt",
                "DebugProbesKt.bin",
                "kotlin-tooling-metadata.json",
                "META-INF/AL2.0",
                "META-INF/LGPL2.1"
            )
        }
    }

    androidResources {
        ignoreAssetsPattern = "ds-test-ec.txt:ds-test-rsa.txt"
    }

    signingConfigs {
        create("release") {
            if (releaseSigningConfigured) {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                enableV1Signing = true
                enableV2Signing = true
                enableV3Signing = true
            }
        }
    }

    buildTypes {
        release {
            if (!releaseSigningConfigured) {
                throw GradleException("Missing android/key.properties for release signing.")
            }
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    implementation("com.google.android.play:integrity:1.4.0")
}

flutter {
    source = "../.."
}
