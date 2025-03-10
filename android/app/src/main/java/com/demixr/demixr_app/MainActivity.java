package com.demixr.demixr_app;

import androidx.annotation.NonNull;
import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    try {
      flutterEngine.getPlugins().add(new DemixingPlugin());
    } catch(Exception e) {
      Log.e("MainActivity", "Error registering plugin demixing, DemixingPlugin", e);
    }
  }
}
