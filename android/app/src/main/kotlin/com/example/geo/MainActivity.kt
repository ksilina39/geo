package com.example.geo

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import com.yandex.mapkit.MapKitFactory
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        MapKitFactory.setLocale("ru_RU")
        MapKitFactory.setApiKey("2858baeb-1a6b-4a76-bf19-8fe762162195")
        super.configureFlutterEngine(flutterEngine)
    }
}

