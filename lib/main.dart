import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:zad_aldaia/core/providers/local_provider.dart';
import 'package:zad_aldaia/core/routing/app_router.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/dependency_injection.dart';
import 'generated/l10n.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';


void main() {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await ScreenUtil.ensureScreenSize();
    setupGetIt();
    await getIt.allReady();

    await initializeFirebase();
    setupFirebaseCrashlytics();

    final localProvider = LocalProvider();
    await localProvider.loadSavedLanguage();

    FlutterNativeSplash.remove();
    runApp(
      ChangeNotifierProvider(
        create: (_) => localProvider,
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

Future<void> initializeFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBdwLNGl5EqHyUrXpGAhwQLVL5jmZJzUNo",
        authDomain: "zadaldaia.firebaseapp.com",
        databaseURL: "https://zadaldaia-default-rtdb.firebaseio.com",
        projectId: "zadaldaia",
        storageBucket: "zadaldaia.firebasestorage.app",
        messagingSenderId: "830145581747",
        appId: "1:830145581747:web:a6e798dc34956ee92b75f4",
        measurementId: "G-9Q1F2200H1",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocalProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return ScreenUtilInit(
          designSize: Size(constraints.maxWidth, constraints.maxHeight),
          minTextAdapt: true,
          child: MaterialApp(
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
              Locale('fr'),
              Locale('es'),
              Locale('fil'),
              Locale('pt'),
            ],
            locale: Locale(provider.locale),
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            initialRoute: MyRoutes.languageScreen,
            theme: ThemeData(
              dividerColor: Colors.transparent,
              primaryColor: Colors.white,
              scaffoldBackgroundColor: Colors.white,
              fontFamily: "almarai_bold",
            ),
            onGenerateRoute: AppRouter().generateRoutes,
          ),
        );
      },
    );
  }
}
