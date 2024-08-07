## Flutter wrapper
 -keep class io.flutter.app.** { *; }
 -keep class io.flutter.plugin.** { *; }
 -keep class io.flutter.util.** { *; }
 -keep class io.flutter.view.** { *; }
 -keep class io.flutter.** { *; }
 -keep class io.flutter.plugins.** { *; }
 -keep class com.google.firebase.** { *; }
 -keep class com.builttoroam.devicecalendar.** { *; }
 -keepattributes SourceFile,LineNumberTable        # Keep file names and line numbers.
 -keep public class * extends java.lang.Exception  # Optional: Keep custom exceptions.
 -dontwarn io.flutter.embedding.**
 -ignorewarnings