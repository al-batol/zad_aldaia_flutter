import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import 'package:zad_aldaia/core/helpers/font_weight_helper.dart';
import 'package:zad_aldaia/core/models/languge.dart';
import 'package:zad_aldaia/core/theming/my_text_style.dart';
import 'package:zad_aldaia/core/widgets/my_dropdown_button.dart';
import 'package:zad_aldaia/core/widgets/my_text_form.dart';
import 'package:zad_aldaia/features/add_item/logic/add_item_cubit.dart';
import 'package:zad_aldaia/features/add_item/logic/add_item_state.dart';
import 'package:zad_aldaia/features/add_item/ui/widgets/image_item_layout.dart';
import 'package:zad_aldaia/features/add_item/ui/widgets/text_item_layout.dart';
import 'package:zad_aldaia/features/article/data/models/article_item.dart';
import 'package:zad_aldaia/generated/l10n.dart';

import '../../../core/theming/my_colors.dart';

class AddItemScreen extends StatefulWidget {
  final String? section;
  final String? language;
  final String? category;
  final String? article;
  final int? order;
  const AddItemScreen({
    super.key,
    this.section,
    this.language,
    this.category,
    this.article,
    this.order,
  });

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
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

  var toggleSelections = <bool>[true, false, false];

  late final AddItemCubit cubit;
  late final List<String> titles;
  late final Map<String, String> langs;
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController _itemTitleController = TextEditingController();
  final TextEditingController _itemContentController = TextEditingController();
  final TextEditingController _videoIdController = TextEditingController();
  final TextEditingController _textItemNoteController = TextEditingController();
  final TextEditingController _imageItemNoteController =
      TextEditingController();
  final TextEditingController _videoItemNoteController =
      TextEditingController();
  final TextEditingController _orderController = TextEditingController();

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _articleController = TextEditingController();

  late String _section = sections.first;
  late String _title = titles.first;
  String _language = Language.english;
  File? _image;
  /*  String? _category;
  String? _article;*/
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
    cubit = context.read<AddItemCubit>();
    if (widget.section != null) {
      _section = widget.section!;
    }
    if (widget.language != null) {
      _language = widget.language!;
    }
    if (widget.category != null) {
      print('category: ${widget.category}');
      // _category = widget.category!;
      _categoryController.text = widget.category!;
    }
    if (widget.article != null) {
      print('article: ${widget.article}');
      // _article = widget.article!;
      _articleController.text = widget.article!;
    }
    if (widget.order != null) {
      _orderController.text = widget.order.toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).addItem,
          style: MyTextStyle.font20primaryBold,
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
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
                      _title = titles[sections.indexOf(val)];
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
                  FutureBuilder(
                    future: cubit.getCategories(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Autocomplete(
                          displayStringForOption: (option) => option.title,
                          fieldViewBuilder: (
                            context,
                            textEditingController,
                            focusNode,
                            onFieldSubmitted,
                          ) {
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
                                  return S
                                      .of(context)
                                      .chooseCategoryFromSuggestions;
                                }
                                return null;
                              },
                              controller: _categoryController,
                            );
                          },
                          onSelected: (option) {
                            // _category = option.title;
                            _categoryController.text = option.title;
                          },
                          optionsBuilder: (textEditingValue) {
                            if (textEditingValue.text.isEmpty &&
                                widget.category != null) {
                              // 4. إذا كانت هناك قيمة مبدئية، اعرضها كخيار أول
                              return snapshot.data!.where(
                                (element) =>
                                    element.title == widget.category &&
                                    element.section == _section &&
                                    element.lang == _language,
                              );
                            }
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
                  FutureBuilder(
                    future: cubit.getArticles(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Autocomplete(
                          displayStringForOption: (option) => option.title,
                          fieldViewBuilder: (
                            context,
                            textEditingController,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            return MyTextForm(
                              title:
                                  widget.article != null
                                      ? widget.article!
                                      : S.of(context).article,
                              focusNode: focusNode,
                              validator: (val) {
                                if (val?.isEmpty == true ||
                                    snapshot.data!.any(
                                          (e) =>
                                              e.title == val &&
                                              e.lang == _language &&
                                              e.section == _section &&
                                              e.category ==
                                                  _categoryController.text,
                                        ) ==
                                        false) {
                                  return S
                                      .of(context)
                                      .chooseArticleFromSuggestions;
                                }
                                return null;
                              },
                              controller: _articleController,
                            );
                          },
                          onSelected: (option) {
                            // _article = option.title;
                            _articleController.text = option.title;
                          },
                          optionsBuilder: (textEditingValue) {
                            if (textEditingValue.text.isEmpty &&
                                widget.article != null) {
                              // 4. إذا كانت هناك قيمة مبدئية، اعرضها كخيار أول
                              return snapshot.data!.where(
                                (element) =>
                                    element.title == widget.article &&
                                    element.section == _section &&
                                    element.lang == _language &&
                                    element.category ==
                                        _categoryController.text,
                              );
                            }
                            return snapshot.data!.where(
                              (element) =>
                                  element.title.startsWith(
                                    textEditingValue.text,
                                  ) &&
                                  element.section == _section &&
                                  element.lang == _language &&
                                  element.category == _categoryController.text,
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
                  SizedBox(height: 10.h),
                  MyTextForm(
                    title: S.of(context).order,
                    validatorMessage: S.of(context).required,
                    inputType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: _orderController,
                  ),
                  SizedBox(height: 15.h),
                  Center(
                    child: ToggleButtons(
                      selectedColor: Colors.white,
                      fillColor: MyColors.primaryColor,
                      onPressed: (index) {
                        for (int i = 0; i < toggleSelections.length; i++) {
                          if (i == index) {
                            toggleSelections[i] = true;
                          } else {
                            toggleSelections[i] = false;
                          }
                        }
                        setState(() {});
                      },
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeightHelper.bold,
                      ),
                      isSelected: toggleSelections,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: Text(S.of(context).text),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: Text(S.of(context).image),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: Text(S.of(context).video),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Builder(
                    builder: (context) {
                      switch (toggleSelections.indexOf(true)) {
                        case 0:
                          return TextItemLayout(
                            itemTitleController: _itemTitleController,
                            itemContentController: _itemContentController,
                            itemNoteController: _textItemNoteController,
                          );
                        case 1:
                          return ImageItemLayout(
                            image: _image,
                            imageItemNoteController: _imageItemNoteController,
                            onImagePicked: (image) {
                              setState(() {
                                _image = image;
                              });
                            },
                          );
                        default:
                          return Column(
                            children: [
                              MyTextForm(
                                controller: _videoIdController,
                                validatorMessage: S.of(context).required,
                                title: S.of(context).videoId,
                              ),
                              SizedBox(height: 10.h),
                              MyTextForm(
                                controller: _videoItemNoteController,
                                title: S.of(context).itemNote,
                              ),
                            ],
                          );
                      }
                    },
                  ),
                  SizedBox(height: 25.h),
                  Center(
                    child: FractionallySizedBox(
                      widthFactor: .8,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          padding: WidgetStatePropertyAll(
                            EdgeInsets.symmetric(vertical: 10.h),
                          ),
                          backgroundColor: WidgetStatePropertyAll(
                            MyColors.primaryColor,
                          ),
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            var id = Uuid().v4();
                            switch (toggleSelections.indexOf(true)) {
                              case 0:
                                cubit.addArticleItem(
                                  TextArticle(
                                    id: id,
                                    section: _section,
                                    category: _categoryController.text,
                                    article: _articleController.text,
                                    title: _itemTitleController.text,
                                    content: _itemContentController.text,
                                    note: _textItemNoteController.text,
                                    order: int.parse(_orderController.text),
                                    language: _language,
                                  ),
                                );
                              case 1:
                                if (_image == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        S.of(context).addImageBeforeSubmitting,
                                      ),
                                    ),
                                  );
                                } else {
                                  String? url = await cubit.uploadImage(
                                    _image!,
                                    _title,
                                  );
                                  if (url == null) {
                                    return;
                                  }
                                  cubit.addArticleItem(
                                    ImageArticle(
                                      id: id,
                                      section: _section,
                                      category: _categoryController.text,
                                      article: _articleController.text,
                                      url: url,
                                      note: _imageItemNoteController.text,
                                      order: int.parse(_orderController.text),
                                      language: _language,
                                    ),
                                  );
                                }
                              default:
                                cubit.addArticleItem(
                                  VideoArticle(
                                    id: id,
                                    section: _section,
                                    category: _categoryController.text,
                                    article: _articleController.text,
                                    videoId: _videoIdController.text,
                                    note: _imageItemNoteController.text,
                                    order: int.parse(_orderController.text),
                                    language: _language,
                                  ),
                                );
                            }
                          }
                        },
                        child: BlocConsumer<AddItemCubit, AddItemState>(
                          listenWhen:
                              (previous, current) =>
                                  previous.runtimeType != current.runtimeType,
                          listener: (context, state) {
                            if (state is UploadingState) {
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
                                          child: CircularProgressIndicator(
                                            color: MyColors.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                              );
                            } else if (state is UploadFailedState) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(S.of(context).addingItemFailed),
                                ),
                              );
                            } else if (state is UploadedState) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    S.of(context).addingItemSuccess,
                                  ),
                                ),
                              );
                            }
                          },
                          builder: (context, state) {
                            return Text(
                              S.of(context).addItem,
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
