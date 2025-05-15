import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/core/theming/my_colors.dart';
import 'package:zad_aldaia/features/home/logic/home_cubit.dart';
import 'package:zad_aldaia/features/home/ui/widgets/circular_image_button.dart';
import 'package:zad_aldaia/features/home/ui/widgets/home_app_bar.dart';
import 'package:zad_aldaia/generated/assets.dart';
import 'package:zad_aldaia/generated/l10n.dart';
import '../../../core/providers/local_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeCubit cubit;
  UserRole _selectedRole = UserRole.speaker;
  late final List<String> section;

  @override
  void initState() {
    super.initState();
    cubit = context.read<HomeCubit>();
    _checkForDataUpdates();
  }

  late List<String> titles;
  late List<String> sections;
  late List<String> speakerTitles;
  late List<String> teacherTitles;

  final List<Map<String, String>> _languages = [
    {"code": "ar", "label": "العربية", "flag": Assets.sudia},
    {"code": "fil", "label": "Filipino", "flag": Assets.filipino},
    {"code": "fr", "label": "Français", "flag": Assets.france},
    {"code": "pt", "label": "Português", "flag": Assets.portugal},
    {"code": "es", "label": "Español", "flag": Assets.spain},
    {"code": "en", "label": "English", "flag": Assets.unitedKingdom},
  ];



  void _onLanguageSelected(String langCode) {
    Navigator.of(context).pop();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SchedulerBinding.instance.scheduleTask(() {
        Provider.of<LocalProvider>(
          context,
          listen: false,
        ).changeLanguage(langCode);
      }, Priority.animation);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final local = S.of(context);
    speakerTitles = [
      local.introToIslam,
      local.christiansDialog,
      local.atheistDialog,
      local.otherSects,
      local.whyIslamIsTrue,
      local.teachingNewMuslims,
      local.questionsAboutIslam,
    ];
    teacherTitles = [
      local.teachingNewMuslims,
      local.questionsAboutIslam,
      local.daiaGuide,
    ];
    sections = [...speakerTitles, ...teacherTitles];

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

  @override
  Widget build(BuildContext context) {
    final currentTiles =
    _selectedRole == UserRole.speaker ? speakerTitles : teacherTitles;
    sections = _selectedRole == UserRole.speaker ? speakerTitles : teacherTitles;

    final selectedLang = context.watch<LocalProvider>().locale;
    final selected = _languages.firstWhere(
          (l) => l['code'] == selectedLang,
      orElse: () => _languages.last,
    );
    return Scaffold(
      appBar: HomeAppBar(
        selectedLangCode: selectedLang,
        selectedLang: selected,
        languages: _languages,
        onLanguageSelected: _onLanguageSelected,
        selectedRole: _selectedRole,
        onRoleSelected: (role) {
          setState(() {
            _selectedRole = role;
          });
        },
        onSearchPressed: () {
          Navigator.of(context).pushNamed(MyRoutes.searchScreen);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          shrinkWrap: false,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: currentTiles.length,
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
                      "title": currentTiles[index],
                      "section": sections[index],

                      "language": cubit.language,
                    },
                  );
                },
                title: currentTiles[index],
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
  Future<void> _checkForDataUpdates() async {
    await cubit.checkForDataUpdates();
    FlutterNativeSplash.remove();
  }
}
enum UserRole { speaker, teacher }