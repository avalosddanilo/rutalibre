import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Credenciales de firma. Viven en android/key.properties, que está en
// .gitignore y NUNCA se commitea: si la clave de subida se filtra, cualquiera
// puede publicar una actualización de esta app en nombre nuestro.
//
// El archivo puede no existir —en la máquina de otro, en CI, o simplemente
// antes de generar el keystore—. En ese caso `release` cae a la firma de
// debug, que sirve para `flutter run --release` y NO sirve para publicar:
// Play rechaza un AAB firmado con la clave de debug. Ver docs/publicacion.md.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseSigning = keystorePropertiesFile.exists()
if (hasReleaseSigning) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "com.rutalibre.rutalibre"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // El identificador con el que la app queda registrada en Play PARA
        // SIEMPRE: no se puede cambiar después de la primera publicación.
        applicationId = "com.rutalibre.rutalibre"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Los dos salen de `version:` en pubspec.yaml (1.0.0+3 → versionName
        // "1.0.0", versionCode 3). Se cambian ahí y en ningún otro lado.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                // Sin key.properties se sigue pudiendo compilar y probar en
                // release; lo que NO se puede es publicar.
                signingConfigs.getByName("debug")
            }
            // Se deja el shrinking en los valores por defecto de Flutter a
            // propósito: activar minify/R8 sin reglas propias es la forma
            // clásica de romper en producción algo que anda en debug, y esta
            // app no tiene un problema de tamaño que lo justifique.
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
