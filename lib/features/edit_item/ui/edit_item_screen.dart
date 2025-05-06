import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zad_aldaia/core/helpers/font_weight_helper.dart';
import 'package:zad_aldaia/core/models/languge.dart';
import 'package:zad_aldaia/core/theming/my_text_style.dart';
import 'package:zad_aldaia/core/widgets/my_dropdown_button.dart';
import 'package:zad_aldaia/core/widgets/my_text_form.dart';
import 'package:zad_aldaia/features/add_item/ui/widgets/image_item_layout.dart';
import 'package:zad_aldaia/features/add_item/ui/widgets/text_item_layout.dart';
import 'package:zad_aldaia/features/article/data/models/article_item.dart';
import 'package:zad_aldaia/features/edit_item/logic/edit_item_cubit.dart';
import 'package:zad_aldaia/features/edit_item/logic/edit_item_state.dart';
import 'package:zad_aldaia/generated/l10n.dart';

import '../../../core/models/article_type.dart';
import '../../../core/theming/my_colors.dart';

class EditItemScreen extends StatefulWidget {
  const EditItemScreen({super.key});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
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

  late final EditItemCubit cubit;
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
  late String _section = sections.first;
  late final String _title = titles.first;
  String _language = Language.english;
  File? _image;
  String? _category;
  String? _article;
  ArticleItem? _item;
  bool isFetching = false;
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
    cubit = context.read<EditItemCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        (_item != null && _item is ImageArticle)
            ? (_item! as ImageArticle).url
            : null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).editItem,
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
                children: [
                  MyTextForm(
                    title: S.of(context).itemId,
                    validatorMessage: S.of(context).required,
                    onChanged: (id) async {
                      setState(() {
                        _item = null;
                        _image = null;
                        isFetching = true;
                      });
                      ArticleItem? item = await cubit.getItem(id);
                      if (item != null) {
                        _section = item.section;
                        _language = item.language;
                        _article = item.article;
                        _category = item.category;
                        _orderController.text = item.order.toString();
                        switch (item.type) {
                          case ArticleType.Text:
                            item as TextArticle;
                            _itemContentController.text = item.content;
                            _itemTitleController.text = item.title;
                            _textItemNoteController.text = item.note;
                          case ArticleType.Image:
                            item as ImageArticle;
                            _imageItemNoteController.text = item.note;
                          case ArticleType.Video:
                            item as VideoArticle;
                            _videoIdController.text = item.videoId;
                            _videoItemNoteController.text = item.note;
                        }
                      }
                      setState(() {
                        _item = item;
                        isFetching = false;
                      });
                    },
                  ),
                  SizedBox(height: 10.h),
                  if (isFetching)
                    Center(
                      child: SizedBox(
                        width: 50.w,
                        height: 50.h,
                        child: CircularProgressIndicator(
                          color: MyColors.primaryColor,
                        ),
                      ),
                    ),
                  if (_item != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyDropdownButton(
                          initialSelection: _section,
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
                          initialSelection: _language,
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
                                displayStringForOption:
                                    (option) => option.title,
                                fieldViewBuilder: (
                                  context,
                                  textEditingController,
                                  focusNode,
                                  onFieldSubmitted,
                                ) {
                                  textEditingController.text = _category!;
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
                        FutureBuilder(
                          future: cubit.getArticles(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Autocomplete(
                                displayStringForOption:
                                    (option) => option.title,
                                fieldViewBuilder: (
                                  context,
                                  textEditingController,
                                  focusNode,
                                  onFieldSubmitted,
                                ) {
                                  textEditingController.text = _article!;
                                  return MyTextForm(
                                    title: S.of(context).article,
                                    focusNode: focusNode,
                                    validator: (val) {
                                      if (val?.isEmpty == true ||
                                          snapshot.data!.any(
                                                (e) =>
                                                    e.title == val &&
                                                    e.lang == _language &&
                                                    e.section == _section &&
                                                    e.category == _category,
                                              ) ==
                                              false) {
                                        return S
                                            .of(context)
                                            .chooseArticleFromSuggestions;
                                      }
                                      return null;
                                    },
                                    controller: textEditingController,
                                  );
                                },
                                onSelected: (option) {
                                  _article = option.title;
                                },
                                optionsBuilder: (textEditingValue) {
                                  return snapshot.data!.where(
                                    (element) =>
                                        element.title.startsWith(
                                          textEditingValue.text,
                                        ) &&
                                        element.section == _section &&
                                        element.lang == _language &&
                                        element.category == _category,
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          controller: _orderController,
                        ),
                        SizedBox(height: 20.h),
                        Builder(
                          builder: (context) {
                            switch (_item!.type) {
                              case ArticleType.Text:
                                return TextItemLayout(
                                  itemTitleController: _itemTitleController,
                                  itemContentController: _itemContentController,
                                  itemNoteController: _textItemNoteController,
                                );
                              case ArticleType.Image:
                                return ImageItemLayout(
                                  image: _image,
                                  url: imageUrl,
                                  imageItemNoteController:
                                      _imageItemNoteController,
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
                                  switch (_item!.type) {
                                    case ArticleType.Text:
                                      cubit.updateArticleItem(
                                        TextArticle(
                                          id: _item!.id,
                                          section: _section,
                                          category: _category!,
                                          article: _article!,
                                          title: _itemTitleController.text,
                                          content: _itemContentController.text,
                                          note: _textItemNoteController.text,
                                          order: int.parse(
                                            _orderController.text,
                                          ),
                                          language: _language,
                                        ),
                                      );
                                    case ArticleType.Image:
                                      String? url =
                                          _image != null
                                              ? await cubit.uploadImage(
                                                _image!,
                                                _title,
                                                imageUrl ?? '',
                                              )
                                              : (_item as ImageArticle).url;
                                      if (url == null) {
                                        return;
                                      }
                                      cubit.updateArticleItem(
                                        ImageArticle(
                                          id: _item!.id,
                                          section: _section,
                                          category: _category!,
                                          article: _article!,
                                          url: url,
                                          note: _imageItemNoteController.text,
                                          order: int.parse(
                                            _orderController.text,
                                          ),
                                          language: _language,
                                        ),
                                      );
                                    default:
                                      cubit.updateArticleItem(
                                        VideoArticle(
                                          id: _item!.id,
                                          section: _section,
                                          category: _category!,
                                          article: _article!,
                                          videoId: _videoIdController.text,
                                          note: _imageItemNoteController.text,
                                          order: int.parse(
                                            _orderController.text,
                                          ),
                                          language: _language,
                                        ),
                                      );
                                  }
                                }
                              },
                              child: BlocConsumer<EditItemCubit, EditItemState>(
                                listenWhen:
                                    (previous, current) =>
                                        previous.runtimeType !=
                                        current.runtimeType,
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
                                                child:
                                                    CircularProgressIndicator(
                                                      color:
                                                          MyColors.primaryColor,
                                                    ),
                                              ),
                                            ),
                                          ),
                                    );
                                  } else if (state is UploadFailedState) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          S.of(context).editingItemFailed,
                                        ),
                                      ),
                                    );
                                  } else if (state is UploadedState) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          S.of(context).editingItemSuccess,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  return Text(
                                    S.of(context).editItem,
                                    style: MyTextStyle.font18WhiteRegular,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15.h),
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
                                cubit.deleteItem(_item!.id);
                              },
                              child: BlocConsumer<EditItemCubit, EditItemState>(
                                listener: (context, state) {
                                  if (state is DeletingState) {
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
                                  } else if (state is DeletingFailedState) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          S.of(context).deletingItemFailed,
                                        ),
                                      ),
                                    );
                                  } else if (state is DeletedState) {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      _item = null;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          S.of(context).deletingItemSuccess,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  return Text(
                                    S.of(context).deleteItem,
                                    style: MyTextStyle.font18WhiteRegular,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
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
