import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zad_aldaia/core/di/dependency_injection.dart'; // For getIt
import 'package:zad_aldaia/core/models/languge.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/core/theming/my_text_style.dart';
import 'package:zad_aldaia/core/widgets/my_dropdown_button.dart';
import 'package:zad_aldaia/features/categories/data/models/category.dart'; // Assuming your Category model
import 'package:zad_aldaia/features/categories/logic/categories_cubit.dart';
import 'package:zad_aldaia/features/categories/ui/CategorySelectionScreen.dart';
import 'package:zad_aldaia/features/upload/image_upload.dart';
import 'package:zad_aldaia/generated/l10n.dart'; // Your CategoriesCubit

class CategoryFormScreen extends StatefulWidget {
  final String? categoryId;

  const CategoryFormScreen({super.key, this.categoryId});

  bool get isEditMode => categoryId != null;

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  late final CategoriesCubit store;
  Category? category;
  final _formKey = GlobalKey<FormState>();
  late final langs = Map.fromIterables([S.of(context).english, S.of(context).espanol, S.of(context).portuguese, S.of(context).francais, S.of(context).filipino], Language.values);

  final _titleController = TextEditingController();
  Category? parentCategory;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    store = getIt<CategoriesCubit>();
    if (widget.isEditMode) {
      store.loadCategory({'id': widget.categoryId!});
    }
  }

  listener(context, state) {
    if (state is ErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
    }
    if (state is SavedState) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category ${widget.isEditMode ? "updated" : "created"} successfully!')));
      if ((parentCategory?.id ?? category?.parentId) != null) {
        Navigator.of(context).pushNamed(MyRoutes.categories, arguments: {"id": parentCategory?.id ?? category?.parentId, "title": parentCategory?.title});
      }
    }
    if (state is LoadedState) {
      category = state.item;
      fillForm();
    }
  }

  fillForm() async {
    _titleController.text = category?.title ?? '';
    _isActive = category?.isActive ?? true;
    if (category?.parentId != null) {
      parentCategory = await store.findCategory({'id': category!.parentId!});
    }
    setState(() {});
  }

  Future<void> _selectParentCategory() async {
    final Category? result = await Navigator.push<Category?>(context, MaterialPageRoute(builder: (context) => CategorySelectionScreen()));

    if (result != null) {
      setParent(result);
    }
  }

  setParent(Category? parent) {
    setState(() {
      parentCategory = parent;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final categoryData = category ?? Category(id: '');
      categoryData.title = _titleController.text.trim();
      categoryData.parentId = parentCategory?.id;
      // categoryData.lang = _langController.text.trim().isNotEmpty ? _langController.text.trim() : null;
      categoryData.isActive = _isActive;

      await store.saveCategory(categoryData);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditMode ? 'Edit Category' : 'Create New Category')),
      body: BlocProvider(
        create: (context) => store,
        child: BlocListener<CategoriesCubit, CategoriesState>(
          listener: listener,
          child: BlocBuilder<CategoriesCubit, CategoriesState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Category Title *'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a category title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Parent Category Selection
                      Text('Parent Category:', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: ElevatedButton(onPressed: _selectParentCategory, child: Text(parentCategory?.title ?? '(Top Level)'))),
                          if (parentCategory != null) IconButton(icon: const Icon(Icons.clear), onPressed: () => setParent(null), tooltip: "Clear parent"),
                        ],
                      ),
                      const SizedBox(height: 20),

                      MyDropdownButton(
                        items: langs.entries.map((e) => DropdownMenuItem(value: e.value, child: Text(e.key, style: MyTextStyle.font14BlackRegular))).toList(),
                        onSelected: (val) {
                          category?.lang = val;
                        },
                        title: S.of(context).contentLanguage,
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          const Text('Is Active:'),
                          Spacer(),
                          Switch(
                            value: _isActive,
                            onChanged: (bool value) {
                              setState(() {
                                _isActive = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      ImageUpload(
                        url: category?.image,
                        identifier: category?.imageIdentifier,
                        onImageUpdated: (identifier, image) {
                          setState(() {
                            category?.imageIdentifier = identifier;
                            category?.image = image;
                          });
                        },
                      ),
                      const SizedBox(height: 30),

                      if (state is SavingState)
                        const Center(child: CircularProgressIndicator())
                      else
                        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _submitForm, child: Text(widget.isEditMode ? 'Update Category' : 'Create Category'))),
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
