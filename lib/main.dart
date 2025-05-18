import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/routing/app_router.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:zad_aldaia/features/search/logic/search_cubit.dart';
import 'core/di/dependency_injection.dart';
import 'core/providers/local_provider.dart';
import 'generated/l10n.dart';
import 'dart:ui';

void main() async {
  ScreenUtil.ensureScreenSize();
  setupGetIt();
  await getIt.allReady();
  var widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await initializeSupabase();
  final localProvider = LocalProvider();
  await localProvider.loadSavedLanguage();

  //  await initializeFirebase();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocalProvider()),
        BlocProvider(create: (context) => getIt<SearchCubit>()),


      ],
      child: const MyApp(),
    ),
  );
}

Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: "https://ehzdtklsgztuglrljgdd.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVoemR0a2xzZ3p0dWdscmxqZ2RkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY1NDAwMTgsImV4cCI6MjA2MjExNjAxOH0.eqJK4bhQUV7mzgLcXE30r2bWk-tDyXtSKpVE5wVfqk8",
  );
}

/************
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
 ************/
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
    return Consumer<LocalProvider>(
      builder: (context, localProvider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return ScreenUtilInit(
              designSize: Size(constraints.maxWidth, constraints.maxHeight),
              minTextAdapt: true,
              builder: (_, __) {
                return MaterialApp(
                  supportedLocales: S.delegate.supportedLocales,
                  locale: Locale(localProvider.locale),
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
                  initialRoute: MyRoutes.roleSelectionScreen,
                  theme: ThemeData(
                    scaffoldBackgroundColor: Colors.white,
                    dividerColor: Colors.transparent,
                    primaryColor: Colors.white,
                    fontFamily: "almarai_bold",
                  ),
                  onGenerateRoute: AppRouter().generateRoutes,
                );
              },
            );
          },
        );
      },
    );
  }
}