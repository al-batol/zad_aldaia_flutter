import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zad_aldaia/core/routing/app_router.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/core/theming/my_colors.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:zad_aldaia/firebase_options.dart';
import 'core/di/dependency_injection.dart';
import 'generated/l10n.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  ScreenUtil.ensureScreenSize();
  setupGetIt();
  await getIt.allReady();
  var widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await initializeFirebase();
  runApp(const MyApp());
}

initializeFirebase() async {
  if (kIsWeb) {
    // await Firebase.initializeApp(
    //   options: FirebaseOptions(
    //     apiKey: "AIzaSyBl2QCp40V8U0LM17x42YaRC7tE2aowqaw",
    //     authDomain: "zad-al-daia.firebaseapp.com",
    //     databaseURL: "https://zad-al-daia-default-rtdb.firebaseio.com",
    //     projectId: "zad-al-daia",
    //     storageBucket: "zad-al-daia.firebasestorage.app",
    //     messagingSenderId: "320761724189",
    //     appId: "1:320761724189:web:a6e798dc34956ee92b75f4",
    //     measurementId: "G-9Q1F2200H1",
    //   ),
    // );
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  setupFirebaseCrashlytics();
}

void setupFirebaseCrashlytics() {
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) {
        return ScreenUtilInit(
          designSize: Size(constrains.maxWidth, constrains.maxHeight),
          minTextAdapt: true,
          child: MaterialApp(
            supportedLocales: S.delegate.supportedLocales,
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            localizationsDelegates: [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            initialRoute: MyRoutes.homeScreen,
            theme: ThemeData(
              dividerColor: Colors.transparent,
              primaryColor: MyColors.primaryColor,
              fontFamily: "almarai_bold",
            ),
            onGenerateRoute: AppRouter().generateRoutes,
          ),
        );
      },
    );
  }
}
