import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/my_colors.dart';
import '../../../../core/theming/my_text_style.dart';
import '../../../../generated/l10n.dart';
import '../home_screen.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String selectedLangCode;
  final Map<String, String> selectedLang;
  final List<Map<String, String>> languages;
  final Function(String) onLanguageSelected;
  final UserRole selectedRole;
  final Function(UserRole) onRoleSelected;
  final VoidCallback onSearchPressed;

  const HomeAppBar({
    super.key,
    required this.selectedLangCode,
    required this.selectedLang,
    required this.languages,
    required this.onLanguageSelected,
    required this.selectedRole,
    required this.onRoleSelected,
    required this.onSearchPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    var local = S.of(context);
    return AppBar(
      forceMaterialTransparency: true,
      titleTextStyle: MyTextStyle.font36primaryBold,
      title: Text(
        S.of(context).home,
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
      ),
      actions: [
        Builder(
          builder:
              (innerContext) => PopupMenuButton<String>(
                color: Colors.white,

                onSelected: onLanguageSelected,
                tooltip: 'Change Language',
                position: PopupMenuPosition.under,
                icon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Image.asset(
                    selectedLang['flag']!,
                    width: 32,
                    height: 32,
                  ),
                ),
                itemBuilder:
                    (popupContext) =>
                        languages.map((lang) {
                          return PopupMenuItem<String>(
                            value: lang['code'],
                            child: Row(
                              children: [
                                Image.asset(
                                  lang['flag']!,
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(lang['label']!),
                              ],
                            ),
                          );
                        }).toList(),
              ),
        ),
        PopupMenuButton<UserRole>(
          color: Colors.white,
          onSelected: onRoleSelected,
          position: PopupMenuPosition.under,
          icon: const Icon(Icons.person_2_outlined, size: 32),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: UserRole.speaker,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Text(local.speaker),

                  if (selectedRole == UserRole.speaker)
                    const Icon(Icons.check_sharp, size: 25, color: Colors.blueAccent),
                  if (selectedRole == UserRole.speaker)
                    const SizedBox(width: 1),
                ],
              ),
            ),
            PopupMenuItem(
              value: UserRole.teacher,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(local.teacher),

                  if (selectedRole == UserRole.teacher)
                    const Icon(Icons.check_sharp, size: 25, color: Colors.blueAccent),
                  if (selectedRole == UserRole.teacher)
                    const SizedBox(width: 1),
                ],
              ),

            ),
          ],
        ),

        IconButton(
          color: MyColors.primaryColor,
          iconSize: 35,
          onPressed: onSearchPressed,
          icon: const Icon(IconData(0xe802, fontFamily: "search_icon")),
        ),
        20.horizontalSpace,
      ],
    );
  }
}
