plugins {
    id("com.android.application")
    id("kotlin-android")

    // Flutter Gradle Plugin
    id("dev.flutter.flutter-gradle-plugin")
}


android {

    namespace = "com.example.cartkaro_delivery_partner"

    compileSdk = flutter.compileSdkVersion

    ndkVersion = flutter.ndkVersion


    defaultConfig {

        applicationId = "com.example.cartkaro_delivery_partner"

        minSdk = flutter.minSdkVersion

        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode

        versionName = flutter.versionName
    }


    compileOptions {

        // Required for flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_17

        targetCompatibility = JavaVersion.VERSION_17
    }


    kotlinOptions {

        jvmTarget = JavaVersion.VERSION_17.toString()

    }


    buildTypes {

        release {

            signingConfig = signingConfigs.getByName("debug")

        }

    }

}


dependencies {

    // Required for flutter_local_notifications
    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.1.5"
    )

}


flutter {

    source = "../.."

}
