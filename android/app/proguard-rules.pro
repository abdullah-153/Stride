# Add project specific ProGuard rules here.
# (Existing comments removed for brevity, keep them if you prefer)

# Flutter Wrapper (from your existing file)
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# --- R8/Play Core Fixes ---

# 1. Keep Flutter's deferred components classes, which reference Play Core.
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# 2. Instruct R8 not to crash/warn if it can't find Play Core classes.
# This prevents the "Missing class com.google.android.play.core..." errors.
-dontwarn com.google.android.play.core.**

# --------------------------

# Keep the application's own code to prevent accidental stripping of UI widgets
-keep class com.example.fitness_tracker_frontend.** { *; }

# Keep generic attributes that might be needed by libraries
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Uncomment this to preserve the line number information for
# debugging stack traces.
-keepattributes SourceFile,LineNumberTable