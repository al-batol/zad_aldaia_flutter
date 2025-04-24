import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zad_aldaia/core/models/languge.dart';
import 'package:zad_aldaia/core/theming/my_colors.dart';
import 'package:zad_aldaia/features/home/logic/home_cubit.dart';
import 'package:zad_aldaia/generated/l10n.dart';

import '../../../../core/theming/my_text_style.dart';

class LanguageDropDownBottom extends StatefulWidget {
  const LanguageDropDownBottom({super.key});

  @override
  State<LanguageDropDownBottom> createState() => _LanguageDropDownBottomState();
}

class _LanguageDropDownBottomState extends State<LanguageDropDownBottom> {
  String selectedValue = Language.english;

  late Map<String,String> langs;

  @override
  void didChangeDependencies() {

    langs = Map.fromIterables([
      S.of(context).english,
      S.of(context).espanol,
      S.of(context).portuguese,
      S.of(context).francais,
      S.of(context).filipino
    ],Language.values);


    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(10),
        color: MyColors.offWhite,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.of(context).contentLanguage, style: MyTextStyle.font14primaryRegular),
              SizedBox(width: 10),
              DropdownButton(
                value: selectedValue,
                underline: Container(),
                items:
                langs.entries.map(
                          (e) => DropdownMenuItem(
                            value: e.value,
                            child: Text(
                              e.key,
                              style: MyTextStyle.font14BlackRegular,
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    context.read<HomeCubit>().language = value;
                    selectedValue = value;
                    setState(() {});
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
