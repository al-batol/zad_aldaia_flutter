import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zad_aldaia/core/models/languge.dart';
import 'package:zad_aldaia/core/theming/my_text_style.dart';
import 'package:zad_aldaia/core/widgets/my_dropdown_button.dart';
import 'package:zad_aldaia/core/widgets/my_text_form.dart';
import 'package:zad_aldaia/features/add_article/data/models/article.dart';
import 'package:zad_aldaia/features/add_article/logic/add_article_cubit.dart';
import 'package:zad_aldaia/features/add_article/logic/add_article_state.dart';
import 'package:zad_aldaia/generated/l10n.dart';

import '../../../core/theming/my_colors.dart';

class AddArticleScreen extends StatefulWidget {
  const AddArticleScreen({super.key});

  @override
  State<AddArticleScreen> createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends State<AddArticleScreen> {
  @override
  void didChangeDependencies() {
    titles = [
      S
          .of(context)
          .introToIslam,
      S
          .of(context)
          .christiansDialog,
      S
          .of(context)
          .atheistDialog,
      S
          .of(context)
          .otherSects,
      S
          .of(context)
          .whyIslamIsTrue,
      S
          .of(context)
          .teachingNewMuslims,
      S
          .of(context)
          .questionsAboutIslam,
      S
          .of(context)
          .daiaGuide,
    ];

    langs = Map.fromIterables([
      S
          .of(context)
          .english,
      S
          .of(context)
          .espanol,
      S
          .of(context)
          .portuguese,
      S
          .of(context)
          .francais,
      S
          .of(context)
          .filipino,
    ], Language.values);

    super.didChangeDependencies();
  }

  late final AddArticleCubit cubit;
  late final titles;
  late final Map<String, String> langs;
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController _articleController = TextEditingController();
  late String _section = sections.first;
  String _language = Language.english;
  String? _category;
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
  void initState() {
    cubit = context.read<AddArticleCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).addArticleTitle, style: MyTextStyle.font20primaryBold),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                MyDropdownButton(
                title: S.of(context).section,
                items: [
                  ...List.generate(
                    sections.length,
                        (index) =>
                        DropdownMenuItem(
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
                      (e) =>
                      DropdownMenuItem(
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
              FutureBuilder(
                future: cubit.getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Autocomplete(
                      displayStringForOption: (option) => option.title,
                      fieldViewBuilder: (context,
                          textEditingController,
                          focusNode,
                          onFieldSubmitted,) {
                        return MyTextForm(
                          title: S.of(context).category,
                          focusNode: focusNode,
                          validator: (val) {
                            if (val?.isEmpty == true ||
                                snapshot.data!.any(
                                      (e) =>
                                  e.title == val &&
                                      e.lang == _language &&
                                      e.section == _section,
                                ) ==
                                    false) {
                              return S.of(context).chooseCategoryFromSuggestions;
                            }
                            return null;
                          },
                          controller: textEditingController,
                        );
                      },
                      onSelected: (option) {
                        _category = option.title;
                      },
                      optionsBuilder: (textEditingValue) {
                        return snapshot.data!.where(
                              (element) =>
                          element.title.startsWith(
                            textEditingValue.text,
                          ) &&
                              element.section == _section &&
                              element.lang == _language,
                        );
                      },
                    );
                  }
                  return Center(
                    child: SizedBox(
                      height: 24.h,
                      width: 24.w,
                      child: CircularProgressIndicator(
                        color: MyColors.primaryColor,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 15.h),
              MyTextForm(
                title: S.of(context).articleTitle,
                validatorMessage: S.of(context).enterArticleTitle,
                controller: _articleController,
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
                        if (formKey.currentState!.validate()) {
                          cubit.addArticle(
                            Article(
                              title: _articleController.text,
                              section: _section,
                              category: _category!,
                              lang: _language,
                            ),
                          );
                        }
                      },
                      child: BlocConsumer<AddArticleCubit, AddArticleState>(
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
                              SnackBar(content: Text(S.of(context).addingArticleFailed)),
                            );
                          } else if (state is UploadedState) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(S.of(context).addingArticleSuccess),
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          return Text(
                            S.of(context).addArticleTitle,
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
      ),
    );
  }
}
