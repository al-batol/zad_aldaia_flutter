import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zad_aldaia/core/models/languge.dart';
import 'package:zad_aldaia/core/theming/my_colors.dart';
import 'package:zad_aldaia/core/theming/my_text_style.dart';
import 'package:zad_aldaia/core/widgets/my_dropdown_button.dart';
import 'package:zad_aldaia/core/widgets/my_text_form.dart';
import 'package:zad_aldaia/features/add_category/data/models/firestore_category.dart';
import 'package:zad_aldaia/features/add_category/logic/add_category_cubit.dart';
import 'package:zad_aldaia/features/add_category/logic/add_category_state.dart';
import 'package:zad_aldaia/generated/l10n.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  late final AddCategoryCubit _cubit;
  late final titles;
  late final Map<String, String> langs;
  final GlobalKey<FormState> categoryKey = GlobalKey();
  final TextEditingController _categoryController = TextEditingController();
  late String _section = sections.first;
  String _language = Language.english;
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

    langs = Map.fromIterables([
      S.of(context).english,
      S.of(context).espanol,
      S.of(context).portuguese,
      S.of(context).francais,
      S.of(context).filipino,
    ], Language.values);

    super.didChangeDependencies();
  }

  @override
  void initState() {
    _cubit = context.read<AddCategoryCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).addCategoryTitle, style: MyTextStyle.font20primaryBold),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyDropdownButton(
                  title: S.of(context).section,
                  items: [
                    ...List.generate(
                      sections.length,
                      (index) => DropdownMenuItem(
                        value: sections[index],
                        child: Text(
                          titles[index],
                          style: MyTextStyle.font14BlackRegular,
                        ),
                      ),
                    ),
                  ],
                  onSelected: (val) {
                    _section = val;
                  },
                ),
                SizedBox(height: 15.h),
                MyDropdownButton(
                  items:
                      langs.entries
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.value,
                              child: Text(
                                e.key,
                                style: MyTextStyle.font14BlackRegular,
                              ),
                            ),
                          )
                          .toList(),
                  onSelected: (val) {
                    _language = val;
                  },
                  title: S.of(context).contentLanguage,
                ),
                SizedBox(height: 15.h),
                Form(
                  key: categoryKey,
                  child: MyTextForm(
                    title: S.of(context).categoryTitle,
                    validatorMessage: S.of(context).enterCategoryTitle,
                    controller: _categoryController,
                  ),
                ),
                SizedBox(height: 25.h),
                 Center(
                   child: FractionallySizedBox(
                    widthFactor: .8,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10.h)),
                        backgroundColor: WidgetStatePropertyAll(
                          MyColors.primaryColor,
                        ),
                      ),
                      onPressed: () {
                        if (categoryKey.currentState!.validate()) {
                          _cubit.addCategory(
                            FireStoreCategory(
                              title: _categoryController.text,
                              section: _section,
                              lang: _language,
                            ),
                          );
                        }
                      },
                      child: BlocConsumer<AddCategoryCubit, AddCategoryState>(
                        listener: (context, state) {
                          if(state is UploadingState)
                            {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder:
                                    (context) => PopScope(
                                  canPop: false,
                                  child: Center(
                                    child: SizedBox(
                                      width: 50.w,
                                      height: 50.h,
                                      child:
                                      CircularProgressIndicator(
                                        color:
                                        MyColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          else if (state is UploadFailedState) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(S.of(context).addingCategoryFailed)),
                            );
                          } else if (state is UploadedState) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(S.of(context).addingCategorySuccess),
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          return Text(
                            S.of(context).addCategoryTitle,
                            style: MyTextStyle.font18WhiteRegular,
                          );
                        },
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
