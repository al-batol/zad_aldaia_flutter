import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/core/theming/my_colors.dart';
import 'package:zad_aldaia/core/theming/my_text_style.dart';
import 'package:zad_aldaia/features/home/logic/home_cubit.dart';
import 'package:zad_aldaia/features/home/ui/widgets/circular_image_button.dart';
import 'package:zad_aldaia/generated/assets.dart';
import 'package:zad_aldaia/generated/l10n.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = context.read<HomeCubit>();
    _checkForDataUpdates(context);
  }

  late final titles;

  @override
  void didChangeDependencies() {
    var local = S.of(context);
    titles = [
      local.introToIslam,
      local.christiansDialog,
      local.atheistDialog,
      local.otherSects,
      local.whyIslamIsTrue,
      local.teachingNewMuslims,
      local.questionsAboutIslam,
      local.daiaGuide,
    ];
    super.didChangeDependencies();
  }

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
        forceMaterialTransparency: true,
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
          50.horizontalSpace,
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          shrinkWrap: false,
          physics: const AlwaysScrollableScrollPhysics(),

          itemCount: 8,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            return DeferredPointerHandler(
              child: RectangularImageButton(
                    image: images[index],
                    color: colors[index],
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        MyRoutes.sectionsScreen,
                        arguments: {
                          "title": titles[index],
                          "language": cubit.language,
                        },
                      );
                    },
                    title: titles[index],
                  )
                  .animate(delay: Duration(milliseconds: index * 100))
                  .slide(
                    begin: Offset(0, 0.3),
                    duration: Duration(milliseconds: 400),
                  )
                  .fadeIn(duration: Duration(milliseconds: 400)),
            );
          },
        ),
      ),
    );
  }

  Future<void> _checkForDataUpdates(BuildContext context) async {
    await context.read<HomeCubit>().checkForDataUpdates();
    FlutterNativeSplash.remove();
  }
}
