import 'package:flutter/material.dart';
import 'package:zad_aldaia/core/models/languge.dart';
import 'package:zad_aldaia/core/theming/my_colors.dart';
import 'package:zad_aldaia/generated/l10n.dart';

import '../../../../core/theming/my_text_style.dart';

class LanguageDropDown extends StatefulWidget {
  final String language;
  final Function(String?) onSelect;
  const LanguageDropDown({super.key, required this.onSelect, required this.language});

  @override
  State<LanguageDropDown> createState() => _LanguageDropDownState();
}

class _LanguageDropDownState extends State<LanguageDropDown> {
  late Map<String, String> langs;

  @override
  void didChangeDependencies() {
    langs = Map.fromIterables([S.of(context).english, S.of(context).espanol, S.of(context).portuguese, S.of(context).francais, S.of(context).filipino], Language.values);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Material(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.of(context).contentLanguage),
              SizedBox(width: 10),
              DropdownButton(
                value: widget.language,
                underline: Container(),
                items: langs.entries.map((e) => DropdownMenuItem(value: e.value, child: Text(e.key))).toList(),
                onChanged: (value) {
                  widget.onSelect(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
