import 'dart:math';

import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/core/theming/my_colors.dart';
import 'package:zad_aldaia/core/theming/my_text_style.dart';
import 'package:zad_aldaia/features/home/logic/home_cubit.dart';
import 'package:zad_aldaia/features/home/ui/widgets/circular_image_button.dart';
import 'package:zad_aldaia/features/home/ui/widgets/language_drop_down_bottom.dart';
import 'package:zad_aldaia/generated/assets.dart';
import 'package:zad_aldaia/generated/l10n.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeCubit cubit;
  final GlobalKey<FormState> adminPasswordFormKey = GlobalKey();
  final TextEditingController passwordController = TextEditingController();
  String? passwordError;
  bool checkingPassword = false;

  @override
  void initState() {
    super.initState();
    cubit = context.read<HomeCubit>();
    _checkForDataUpdates(context);
  }

  @override
  void didChangeDependencies() {
    titles = [
      S.of(context).introToIslam,
      S.of(context).christiansDialog,
      S.of(context).atheistDialog,
      S.of(context).otherSects,
      S.of(context).whyIslamIsTrue,
      S.of(context).teachingNewMuslims,
      S.of(context).questionsAboutIslam,
      S.of(context).daiaGuide,
    ];
    super.didChangeDependencies();
  }

  late final titles;

  final sections = const [
    "التعريف بالإسلام",
    "محاورة النصاري",
    "محاورة الملحدين",
    "الطوائف الأخرى",
    "براهين صحة الإسلام",
    "شبهات وأسئلة حول الإسلام",
    "تعليم المسلم الجديد",
    "دليل الداعية",
  ];

  final colors = const [
    Color(0xff7E4D5A),
    Color(0xff51B8E1),
    Color(0xff364666),
    Color(0xff4A71EC),
    Color(0xff5B2D3E),
    Color(0xff3E586D),
    Color(0xff3E2A30),
    MyColors.primaryColor,
  ];

  final images = const [
    Assets.svgCresentMoon,
    Assets.svgCross,
    Assets.svgAtheist,
    Assets.svgReligion,
    Assets.svgIslam,
    Assets.svgTeachings,
    Assets.svgQuestionSign,
    Assets.svgIntegrity,
  ];

  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: MyTextStyle.font36primaryBold,
        title: Text(S.of(context).home),
        actions: [
          IconButton(
            color: MyColors.primaryColor,
            iconSize: 40.h,
            onPressed: () {
              Navigator.of(context).pushNamed(MyRoutes.searchScreen);
            },
            icon: Icon(const IconData(0xe802, fontFamily: "search_icon")),
          ),
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text(S.of(context).admin),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => BlocProvider.value(
                            value: cubit,
                            child: Dialog(
                              backgroundColor: Colors.white,
                              child: Container(
                                padding: EdgeInsetsDirectional.symmetric(
                                  vertical: 10.h,
                                  horizontal: 20.w,
                                ),
                                child: StatefulBuilder(
                                  builder: (builderContext, setState) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          S.of(context).enterPassword,
                                          style: MyTextStyle.font18BlackBold,
                                        ),
                                        SizedBox(height: 20.h),
                                        Form(
                                          key: adminPasswordFormKey,
                                          child: TextFormField(
                                            controller: passwordController,
                                            obscureText: _obscureText,
                                            decoration: InputDecoration(
                                              errorText: passwordError,
                                              contentPadding:
                                                  EdgeInsetsDirectional.only(
                                                    start: 16.0,
                                                    end: 4.0,
                                                  ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: MyColors.primaryColor,
                                                  style: BorderStyle.solid,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(15.h),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15.h),
                                              ),
                                              hintText:  S.of(context).password,
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscureText
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscureText =
                                                        !_obscureText;
                                                  });
                                                },
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return  S.of(context).pleaseEnterPassword;
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 20.h),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    MyColors.primaryColor,
                                              ),
                                              child: Text(
                                                S.of(context).dismiss,
                                                style:
                                                    MyTextStyle.font16WhiteBold,
                                              ),
                                            ),
                                            SizedBox(width: 15.w),
                                            ElevatedButton(
                                              onPressed: () async {
                                                if (adminPasswordFormKey
                                                    .currentState!
                                                    .validate()) {
                                                  setState(() {
                                                    checkingPassword = true;
                                                  },);
                                                  if (await cubit
                                                      .validatePassword(
                                                        passwordController.text,
                                                      )) {
                                                    passwordError = null;
                                                    Navigator.of(
                                                      context,
                                                    ).popAndPushNamed(
                                                      MyRoutes.adminScreen,
                                                    );
                                                  } else {
                                                    setState(() {
                                                      passwordError =
                                                          S.of(context).wrongPassword;
                                                    });
                                                  }
                                                  checkingPassword = false;
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    MyColors.primaryColor,
                                              ),
                                              child:
                                                  checkingPassword == true
                                                      ? Center(
                                                        child: SizedBox(
                                                          width: 24.h,
                                                          height: 24.h,
                                                          child: CircularProgressIndicator(
                                                            color:
                                                                Colors.white,
                                                          ),
                                                        ),
                                                      )
                                                      : Text(
                                                    S.of(context).continu,
                                                        style:
                                                            MyTextStyle
                                                                .font16WhiteBold,
                                                      ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                    );
                  },
                ),
              ];
            },
            child: Icon(
              Icons.more_vert,
              size: 40.h,
              color: MyColors.primaryColor,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: DeferredPointerHandler(
          child: Container(
            margin: EdgeInsets.all(10.h),
            padding: EdgeInsets.only(bottom: 170.h),
            child: Column(
              children: [
                LanguageDropDownBottom(),
                Container(
                  margin: EdgeInsets.only(top: 180.h),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Material(
                        color: Color(0xff453F92),
                        elevation: 2,
                        shape: CircleBorder(),
                        child: Container(
                          width: 120.w,
                          height: 120.h,
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            Assets.svgZadLogo,
                            width: 90.w,
                            height: 90.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Circular Positioned Items
                      ...List.generate(8, (index) {
                        final double angle = 2 * pi * index / 8;
                        final double dx;
                        final double dy;
                        if ([1, 5].contains(index + 1)) {
                          dx = 120 * cos(angle);
                          dy = 120 * sin(angle);
                        } else {
                          dx = 150 * cos(angle);
                          dy = 150 * sin(angle);
                        }

                        return Transform.translate(
                          offset: Offset(dx, dy),
                          child: DeferPointer(
                            child: CircularImageButton(
                              image: images[index],
                              color: colors[index],
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  MyRoutes.sectionsScreen,
                                  arguments: {
                                    "title": titles[index],
                                    "section": sections[index],
                                    "language": cubit.language,
                                  },
                                );
                              },
                              title: titles[index],
                            ),
                          ),
                        );
                      }),
                    ].animate(
                      interval: .1.seconds,
                      effects: [SlideEffect(), FadeEffect()],
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

  Future<void> _checkForDataUpdates(BuildContext context) async {
    await context.read<HomeCubit>().checkForDataUpdates();
    FlutterNativeSplash.remove();
  }
}
