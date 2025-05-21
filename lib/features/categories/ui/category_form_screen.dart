import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zad_aldaia/core/di/dependency_injection.dart';
import 'package:zad_aldaia/core/helpers/Language.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/features/categories/data/models/category.dart';
import 'package:zad_aldaia/features/categories/logic/categories_cubit.dart';
import 'package:zad_aldaia/features/categories/ui/CategorySelectionScreen.dart';
import 'package:zad_aldaia/features/upload/image_upload.dart';

class CategoryFormScreen extends StatefulWidget {
  final String? categoryId;

  const CategoryFormScreen({super.key, this.categoryId});

  bool get isEditMode => categoryId != null;

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  late final CategoriesCubit store;
  Category category = Category(id: '');
  final _formKey = GlobalKey<FormState>();
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
      if ((parentCategory?.id ?? category.parentId) != null) {
        Navigator.of(context).pushNamed(MyRoutes.categories, arguments: {"id": parentCategory?.id ?? category.parentId, "title": parentCategory?.title});
      }
    }
    if (state is LoadedState) {
      category = state.item;
      fillForm();
    }
  }

  fillForm() async {
    _titleController.text = category.title ?? '';
    _isActive = category.isActive;
    if (category.parentId != null) {
      parentCategory = await store.findCategory({'id': category.parentId!});
    }
    setState(() {});
  }

  Future<void> _selectParentCategory() async {
    final Category? result = await Navigator.push<Category?>(context, MaterialPageRoute(builder: (context) => CategorySelectionScreen(forArticles: false)));

    if (result != null) {
      setParent(result);
    }
  }

  setParent(Category? parent) {
    setState(() {
      category.parentId = parent?.id;
      parentCategory = parent;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      category.title = _titleController.text.trim();
      category.parentId = parentCategory?.id;
      category.isActive = _isActive;
      category.lang = await Lang.get();

      await store.saveCategory(category);
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
      appBar: AppBar(centerTitle: true, title: Text(widget.isEditMode ? 'Edit Category' : 'Create New Category')),
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
                      // if ((category.parentId) == null) ...[
                      //   const SizedBox(height: 20),
                      //   Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Text(S.of(context).contentLanguage),
                      //       LanguageDropDown(
                      //         language: category.lang ?? Language.english,
                      //         onSelect: (val) {
                      //           category.lang = val ?? Language.english;
                      //         },
                      //       ),
                      //     ],
                      //   ),
                      // ],
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
                        url: category.image,
                        identifier: category.imageIdentifier,
                        onImageUpdated: (identifier, image) {
                          setState(() {
                            category.imageIdentifier = identifier;
                            category.image = image;
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
