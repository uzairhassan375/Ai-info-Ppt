import 'package:api_key_pool/api_key_pool.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infography/app/data/services/remote-config-service.dart';
import 'app/routes/app_pages.dart';

void main() {
WidgetsFlutterBinding.ensureInitialized();
  //Api Key Package Initialization
  ApiKeyPool.init('Ai_Visualizer');

  // Initialize Firebase
  Firebase.initializeApp();

  // Initialize Remote Config
  RemoteConfigService().initialize();

  // Firebase Analytics instance
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);

  runApp(
    GetMaterialApp(
      title: "Infographic Generator",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    ),
  );
}
