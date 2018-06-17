package com.jw.monsters;

import android.util.Log;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.WindowManager.LayoutParams;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.view.FlutterView;


public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
  }

  @Override
  public FlutterView createFlutterView(Context context) {
    final FlutterView view = new FlutterView(this);
    view.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
    setContentView(view);
    final String route = getRouteFromIntent();
    if (route != null) {
      view.setInitialRoute(route);
    }
    return view;
  }

  // https://github.com/flutter/flutter/issues/10884
  //  https://github.com/theyakka/fluro
  private String getRouteFromIntent() {
    final Intent intent = getIntent();
    if (Intent.ACTION_VIEW.equals(intent.getAction()) && intent.getData() != null) {
      Log.d("test", intent.getData().getPath());
      return intent.getData().getPath();
    }
    return null;
  }
}
