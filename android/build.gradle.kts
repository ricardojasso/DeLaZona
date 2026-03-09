buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // La antena para recibir mensajes de Google
        classpath("com.google.gms:google-services:4.4.0")
        
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// CORRECCIÓN: Usamos file() para convertir el texto en un objeto de archivo real
rootProject.layout.buildDirectory.set(file("../build"))

subprojects {
    project.layout.buildDirectory.set(file("${rootProject.layout.buildDirectory.get()}/${project.name}"))
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register("clean", Delete::class) {
    delete(rootProject.layout.buildDirectory)
} 