buildscript {
    val kotlinVersion by extra("1.7.10")
    
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:7.3.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:${kotlinVersion}")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val buildDir by extra(file("../build"))

subprojects {
    project.buildDir = file("${rootProject.extra["buildDir"]}/${project.name}")
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.extra["buildDir"])
}
