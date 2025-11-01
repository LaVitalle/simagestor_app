# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Dio
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn kotlin.**
-keepclassmembers class * {
    @kotlin.jvm.JvmField <fields>;
}

# Preserve all Dio classes
-keep class dio.** { *; }
-dontwarn dio.**

# Preserve JSON serialization
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keep class * implements java.io.Serializable { *; }
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep all model classes
-keep class com.example.simagestor_app.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep setters in Views so animations can still work
-keepclassmembers public class * extends android.view.View {
    void set*(***);
    *** get*();
}

# Preserve enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelables
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Preserve all sqflite classes
-keep class io.flutter.plugins.** { *; }
-keep class com.example.simagestor_app.** { *; }

# Connectivity plus
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# Image picker
-keep class io.flutter.plugins.imagepicker.** { *; }

