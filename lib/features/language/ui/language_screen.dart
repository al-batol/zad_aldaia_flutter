import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/providers/local_provider.dart';
import '../../../core/routing/routes.dart';
import '../../../generated/assets.dart';
import '../../../generated/l10n.dart';
import '../../home/logic/home_cubit.dart';
import '../widgets/language_container.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  //void _onLanguageSelected(BuildContext context, String langCode) {
    //context.read<HomeCubit>().language = langCode;
  //  Navigator.pushReplacementNamed(context, MyRoutes.homeScreen);
//  }
  void _onLanguageSelected(BuildContext context, String langCode) async {
    final localProvider = context.read<LocalProvider>();
    await localProvider.changeLanguage(langCode);
    Navigator.pushNamed(context, MyRoutes.homeScreen);

  }

  @override
  Widget build(BuildContext context) {
    var local=S.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              20.verticalSpace,
              Text(
                local.selectLanguage,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              10.verticalSpace,
              Center(
                child: Text(
                  textAlign: TextAlign.center,
                 local.chooseTheLanguageYouWant,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              20.verticalSpace,

              LanguageContainer(
                flagAsset: Assets.sudia,
                languageName: 'العربية',
                onTap: () => _onLanguageSelected(context, 'ar'),
              ),
              LanguageContainer(
                flagAsset: Assets.filipino,
                languageName: 'Filipino',
                onTap: () => _onLanguageSelected(context, 'fil'),
              ),
              LanguageContainer(
                flagAsset: Assets.france,
                languageName: 'Français',
                onTap: () => _onLanguageSelected(context, 'fr'),
              ),
              LanguageContainer(
                flagAsset: Assets.portugal,
                languageName: 'Português',
                onTap: () => _onLanguageSelected(context, 'pt'),
              ),
              LanguageContainer(
                flagAsset: Assets.spain,
                languageName: 'Español',
                onTap: () => _onLanguageSelected(context, 'es'),
              ),
              LanguageContainer(
                flagAsset: Assets.unitedKingdom,
                languageName: 'English',
                onTap: () => _onLanguageSelected(context, 'en'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
