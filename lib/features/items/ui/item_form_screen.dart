import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zad_aldaia/core/di/dependency_injection.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/features/items/data/models/item.dart';
import 'package:zad_aldaia/features/items/logic/items_cubit.dart';
import 'package:zad_aldaia/features/upload/image_upload.dart';
import 'package:zad_aldaia/generated/l10n.dart';

class ItemFormScreen extends StatefulWidget {
  final String? itemId;
  final String? articleId;

  const ItemFormScreen({super.key, this.itemId, this.articleId}) : assert(itemId != null || articleId != null);

  bool get isEditMode => itemId != null;

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  late final ItemsCubit store = getIt<ItemsCubit>();
  Item item = Item(id: '');
  var toggleSelections = <bool>[true, false, false];
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final backgroundColorController = TextEditingController();
  final noteController = TextEditingController();
  final contentController = TextEditingController();
  final youtubeUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      store.loadItem({'id': widget.itemId!});
    } else {
      fillForm();
    }
  }

  onToggle(index) {
    for (int i = 0; i < toggleSelections.length; i++) {
      toggleSelections[i] = i == index;
    }
    item.type = ItemType.values[index];
    setState(() {});
  }

  listener(context, state) {
    if (state is ErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
    }
    if (state is SavedState) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item ${widget.isEditMode ? "updated" : "created"} successfully!')));
      if (item.articleId != null) {
        Navigator.of(context).pushNamed(MyRoutes.items, arguments: {"id": item.articleId});
      }
    }
    if (state is LoadedState) {
      item = state.item;
      fillForm();
    }
  }

  fillForm() async {
    titleController.text = item.title ?? '';
    noteController.text = item.note ?? '';
    contentController.text = item.content ?? '';
    youtubeUrlController.text = item.youtubeUrl ?? '';
    toggleSelections = ItemType.values.map((e) => e == item.type).toList();
    setState(() {});
  }

  bool validate() {
    if (item.type == ItemType.image && item.imageIdentifier == null) {
      return false;
    }
    return true;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && validate()) {
      item.articleId = item.articleId ?? widget.articleId;
      item.title = titleController.text.trim();
      item.content = contentController.text.trim();
      item.youtubeUrl = youtubeUrlController.text.trim();
      item.note = noteController.text.trim();

      await store.saveItem(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.isEditMode ? 'Edit Item' : 'Create New Item',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
      body: BlocProvider(
        create: (context) => store,
        child: BlocListener<ItemsCubit, ItemsState>(
          listener: listener,
          child: BlocBuilder<ItemsCubit, ItemsState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 15.h),
                      Center(
                        child: ToggleButtons(
                          onPressed: onToggle,
                          isSelected: toggleSelections,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 32.w),
                              child: Text(S.of(context).text, style: TextStyle(fontSize: 14.sp)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 32.w),
                              child: Text(S.of(context).image, style: TextStyle(fontSize: 14.sp)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 32.w),
                              child: Text(S.of(context).video, style: TextStyle(fontSize: 14.sp)),
                            ),
                          ],
                        ),
                      ),
                      if (item.type == ItemType.text) ...[
                        SizedBox(height: 20.h),
                        TextFormField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: TextStyle(fontSize: 16.sp),
                          ),
                          style: TextStyle(fontSize: 16.sp),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a item title';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        TextFormField(
                          controller: contentController,
                          decoration: InputDecoration(
                            labelText: 'Content',
                            labelStyle: TextStyle(fontSize: 16.sp),
                          ),
                          style: TextStyle(fontSize: 16.sp),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a item content';
                            }
                            return null;
                          },
                        ),
                      ],
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: noteController,
                        decoration: InputDecoration(
                          labelText: 'Note',
                          labelStyle: TextStyle(fontSize: 16.sp),
                        ),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: backgroundColorController,
                        decoration: InputDecoration(
                          labelText: 'Background color',
                          labelStyle: TextStyle(fontSize: 16.sp),
                        ),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      if (item.type == ItemType.video) ...[
                        SizedBox(height: 16.h),
                        TextFormField(
                          controller: youtubeUrlController,
                          decoration: InputDecoration(
                            labelText: 'Youtube url',
                            labelStyle: TextStyle(fontSize: 16.sp),
                          ),
                          style: TextStyle(fontSize: 16.sp),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a Youtube url';
                            }
                            return null;
                          },
                        ),
                      ],
                      if (item.type == ItemType.image) ...[
                        SizedBox(height: 30.h),
                        ImageUpload(
                          url: item.imageUrl,
                          onImageUpdated: (identifier, image) {
                            setState(() {
                              item.imageIdentifier = identifier;
                              item.imageUrl = image;
                            });
                          },
                        ),
                      ],
                      SizedBox(height: 30.h),
                      if (state is SavingState)
                        Center(child: CircularProgressIndicator())
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                            ),
                            child: Text(
                              widget.isEditMode ? 'Update Item' : 'Create Item',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}