import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:zad_aldaia/core/helpers/language.dart';
import 'package:zad_aldaia/core/routing/routes.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({super.key});

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  String? selectedLang = 'english';

  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAE6),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Text(
              'Select Language',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
            SizedBox(
              height: 0.33.sh,
              child: Image.asset(
                'assets/images/png/onboarding1.png',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                children: Lang.values.map((lang) {
                  final flagPath = 'assets/images/flags/$lang.png';
                  final isSelected = selectedLang == lang;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedLang = lang;
                      });
                    },
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isSelected ? 1.0 : 0.9,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(50.r),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 5),
                                  )
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              flagPath,
                              width: 32.w,
                              height: 32.h,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              lang[0].toUpperCase() + lang.substring(1),
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            const Spacer(),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: isSelected ? 1.0 : 0.0,
                              child: Icon(
                                Icons.check,
                                color: Colors.green.shade900,
                                size: 24.w,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedLang != null
                      ? () async {
                          await Lang.set(selectedLang!);
                          Navigator.of(context).pushNamed(MyRoutes.homeScreen);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade900,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(fontSize: 16.sp, color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}