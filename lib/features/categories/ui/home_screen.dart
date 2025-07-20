import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/di/dependency_injection.dart';
import 'package:zad_aldaia/core/helpers/language.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/features/auth/auth_cubit.dart';
import 'package:zad_aldaia/features/categories/logic/categories_cubit.dart';
import 'sections_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final authCubit = getIt<AuthCubit>();
  final cubit = getIt<CategoriesCubit>();
  int _selectedIndex = 1;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> adminPasswordFormKey = GlobalKey<FormState>();
  String? passwordError;
  bool checkingPassword = false;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const Placeholder(),     
      const SectionsScreen(),  
      const Placeholder(),     
      const Placeholder(),    
      const Placeholder(),     
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0FAE6),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: pages[_selectedIndex]),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHeader() {
    final user = Supabase.instance.client.auth.currentUser;
    final avatarImage = user != null
        ? 'assets/images/png/imam_icon.png'
        : 'assets/images/png/muslim_icon.png';

    return Container(
      height: 250.h,
      decoration: BoxDecoration(
        color: const Color(0xFF005A32),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50.r),
          bottomRight: Radius.circular(50.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 90.h),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assalam Alakum 👋🏼',
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Exo',
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 19.sp,
                      color: Colors.white70,
                      fontFamily: 'Exo',
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 23.r,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(avatarImage),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
          child: GNav(
            gap: 8.w,
            iconSize: 24.w,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: const Color(0xFF005A32),
            activeColor: Colors.white,
            color: Colors.black,
            tabs: const [
              GButton(icon: LineIcons.search, text: 'Search'),
              GButton(icon: LineIcons.home, text: 'Home'),
              GButton(icon: LineIcons.cog, text: 'Settings'),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              if (index == 0) {
                Navigator.of(context).pushNamed(MyRoutes.searchScreen);
              } else if (index == 2) {
                showSettingsMenu(context);
              } else {
                setState(() => _selectedIndex = index);
              }
            },
          ),
        ),
      ),
    );
  }

  void showSettingsMenu(BuildContext rootContext) {
    bool isLanguageExpanded = false;

    showModalBottomSheet(
      context: rootContext,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) {
        return FutureBuilder<String>(
          future: Lang.get(),
          builder: (context, snapshot) {
            final currentLang = snapshot.data ?? Lang.defaultLang;

            return StatefulBuilder(
              builder: (context, setState) {
                return FractionallySizedBox(
                  heightFactor: 0.6,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 243, 251, 236),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        Center(
                          child: Container(
                            width: 40.w,
                            height: 5.h,
                            margin: EdgeInsets.only(bottom: 16.h),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                        Text(
                          'Language Cible',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => isLanguageExpanded = !isLanguageExpanded),
                                behavior: HitTestBehavior.opaque,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/flags/$currentLang.png',
                                          width: 32.w,
                                          height: 32.h,
                                        ),
                                        SizedBox(width: 12.w),
                                        Text(
                                          _getLanguageDisplayName(currentLang),
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    AnimatedRotation(
                                      turns: isLanguageExpanded ? 0.5 : 0,
                                      duration: const Duration(milliseconds: 300),
                                      child: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.green.shade900,
                                        size: 28.w,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 300),
                                crossFadeState: isLanguageExpanded
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                                firstChild: Column(
                                  children: Lang.values
                                      .where((lang) => lang != currentLang)
                                      .map((lang) => ListTile(
                                            contentPadding: EdgeInsets.only(left: 0),
                                            leading: Image.asset(
                                              'assets/images/flags/$lang.png',
                                              width: 28.w,
                                              height: 28.h,
                                            ),
                                            title: Text(_getLanguageDisplayName(lang)),
                                            onTap: () async {
                                              await Lang.set(lang);
                                              setState(() => isLanguageExpanded = false);
                                              Navigator.pushReplacement(
                                                rootContext,
                                                MaterialPageRoute(
                                                  builder: (context) => const HomeScreen(),
                                                ),
                                              );
                                            },
                                          ))
                                      .toList(),
                                ),
                                secondChild: const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30.h),
                        Text(
                          'Account Settings',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 15.h),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Icon(Icons.logout, color: Colors.red, size: 24.w),
                            title: Text("Logout", style: TextStyle(color: Colors.red, fontSize: 16.sp)),
                            onTap: () async {
                              Navigator.of(sheetContext).pop();
                              await Supabase.instance.client.auth.signOut();
                              Navigator.of(rootContext).pushNamedAndRemoveUntil(
                                MyRoutes.onboarding,
                                (route) => false,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _getLanguageDisplayName(String langCode) {
    switch (langCode) {
      case 'english':
        return 'English';
      case 'espanol':
        return 'Español';
      case 'portugues':
        return 'Português';
      case 'francais':
        return 'Français';
      case 'filipino':
        return 'Filipino';
      default:
        return 'English';
    }
  }
}