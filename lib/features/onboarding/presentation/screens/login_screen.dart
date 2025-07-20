import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zad_aldaia/core/di/dependency_injection.dart';
import 'package:zad_aldaia/features/auth/auth_cubit.dart';
import 'package:zad_aldaia/features/languages/languages_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthCubit authCubit = getIt<AuthCubit>();
  final GlobalKey<FormState> adminPasswordFormKey = GlobalKey();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? passwordError;
  bool checkingPassword = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF005A32),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: adminPasswordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.w),
                    label: Text("Back", style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                  ),
                ),
          
                Center(
                  child: Image.asset(
                    'assets/images/png/logo_Z.png',
                    height: 350.h,
                  ),
                ),
              
                Center(
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.black),
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Please enter your email' : null,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Color(0xFF95A8BD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Colors.green)),
                    ),
                ),

                SizedBox(height: 16.h),
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscureText,
                  style: const TextStyle(color: Colors.black),
                  textInputAction: TextInputAction.done,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Please enter password' : null,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                    ),
                    errorText: passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey[700],
                        size: 24.w,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Color(0xFF95A8BD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Colors.green)),
                    ),
                ),

                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      backgroundColor: const Color(0xFFDFF6DD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                    ),
                    onPressed: () async {
                      if (adminPasswordFormKey.currentState!.validate()) {
                        setState(() {
                          checkingPassword = true;
                        });
                        if (await authCubit.signIn(
                          emailController.text,
                          passwordController.text,
                        )) {
                          passwordError = null;
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LanguagesScreen(),
                            ),
                          );
                        } else {
                          setState(() {
                            passwordError = 'Wrong password';
                          });
                        }
                        setState(() {
                          checkingPassword = false;
                        });
                      }
                    },
                    child: checkingPassword
                        ? SizedBox(
                            height: 24.h,
                            width: 24.w,
                            child: const CircularProgressIndicator(
                              color: Colors.green,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Login',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF005A32),
                              fontSize: 16.sp,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}