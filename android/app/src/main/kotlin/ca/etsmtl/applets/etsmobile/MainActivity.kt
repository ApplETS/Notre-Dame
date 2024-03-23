package ca.etsmtl.applets.etsmobile

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

    lateinit var flutterEngine: FlutterEngine

    override fun onCreate() {
        super.onCreate()

        // Initialize your Flutter engine
        flutterEngine = FlutterEngine(this)

        // Cache the Flutter engine
        FlutterEngineCache.getInstance().put("flutter_engine_id", flutterEngine)
    }
}