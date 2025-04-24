import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/core/theming/my_colors.dart';
import 'package:zad_aldaia/core/theming/my_text_style.dart';
import 'package:zad_aldaia/generated/l10n.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {

  @override
  void didChangeDependencies() {
    titles = [
      S.of(context).addCategoryTitle,
      S.of(context).addArticleTitle,
      S.of(context).addItem,
      S.of(context).editItem,
    ];
    super.didChangeDependencies();
  }

  late final List<String> titles;

  final routes = const [
    MyRoutes.addCategoryScreen,
    MyRoutes.addArticleScreen,
    MyRoutes.addItemScreen,
    MyRoutes.editItemScreen,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).admin, style: MyTextStyle.font22primaryBold),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 10.w),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: 4,
            separatorBuilder: (context, index) => SizedBox(height: 25.h),
            itemBuilder:
                (context, index) => FractionallySizedBox(
                  widthFactor: .8,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(routes[index]);
                    },
                    style: ButtonStyle(
                      padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(vertical: 10.h),
                      ),
                      backgroundColor: WidgetStatePropertyAll(
                        MyColors.primaryColor,
                      ),
                    ),
                    child: Text(
                      titles[index],
                      style: MyTextStyle.font18WhiteRegular,
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
