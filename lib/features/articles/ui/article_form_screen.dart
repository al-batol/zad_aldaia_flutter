import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zad_aldaia/core/di/dependency_injection.dart'; // For getIt
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/features/articles/data/models/article.dart'; // Assuming your Article model
import 'package:zad_aldaia/features/articles/logic/articles_cubit.dart';
import 'package:zad_aldaia/features/categories/data/models/category.dart';
import 'package:zad_aldaia/features/categories/logic/categories_cubit.dart' as C;
import 'package:zad_aldaia/features/categories/ui/CategorySelectionScreen.dart';

class ArticleFormScreen extends StatefulWidget {
  final String? id;
  final String? categoryId;

  const ArticleFormScreen({super.key, this.id, required this.categoryId});

  bool get isEditMode => id != null;

  @override
  State<ArticleFormScreen> createState() => _ArticleFormScreenState();
}

class _ArticleFormScreenState extends State<ArticleFormScreen> {
  late final ArticlesCubit store;
  late final C.CategoriesCubit categoryStore;
  Article article = Article(id: '');
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  Category? category;

  @override
  void initState() {
    super.initState();
    store = getIt<ArticlesCubit>();
    categoryStore = getIt<C.CategoriesCubit>();
    if (widget.isEditMode) {
      store.loadArticle({'id': widget.id!});
    } else {
      fillForm();
    }
  }

  listener(context, state) {
    if (state is SavedState) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Article ${widget.isEditMode ? "updated" : "created"} successfully!')));
      if ((article.categoryId ?? category?.id) != null) {
        Navigator.of(context).pushNamed(MyRoutes.articles, arguments: {"category_id": article.categoryId ?? category?.id, "title": category?.title});
      }
    }
    if (state is LoadedState) {
      article = state.item;
      fillForm();
    }
    if (state is ErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
    }
  }

  fillForm() async {
    _titleController.text = article.title ?? '';
    if (article.categoryId != null) {
      category = await categoryStore.findCategory({'id': article.categoryId!});
    }
    if (widget.categoryId != null) {
      category = await categoryStore.findCategory({'id': widget.categoryId!});
    }
    setState(() {});
  }

  Future<void> _selectCategory() async {
    final Category? result = await Navigator.push<Category?>(context, MaterialPageRoute(builder: (context) => CategorySelectionScreen(forArticles: true)));

    if (result != null) {
      setParent(result);
    }
  }

  setParent(Category? parent) {
    setState(() {
      category = parent;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      article.title = _titleController.text.trim();
      article.categoryId = widget.categoryId ?? article.categoryId ?? category?.id;
      // articleData.lang = _langController.text.trim().isNotEmpty ? _langController.text.trim() : null;
      // articleData.isActive = _isActive;

      await store.saveArticle(article);
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
      appBar: AppBar(centerTitle: true, title: Text(widget.isEditMode ? 'Edit Article' : 'Create New Article')),
      body: BlocProvider(
        create: (context) => store,
        child: BlocListener<ArticlesCubit, ArticlesState>(
          listener: listener,
          child: BlocBuilder<ArticlesCubit, ArticlesState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Category:', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      AbsorbPointer(
                        absorbing: (widget.categoryId != null),
                        child: Opacity(
                          opacity: (widget.categoryId != null ? 0.7 : 1),
                          child: Row(
                            children: [
                              Expanded(child: ElevatedButton(onPressed: _selectCategory, child: Text(category?.title ?? '(Top Level)'))),
                              if (category != null && (widget.categoryId == null))
                                IconButton(icon: const Icon(Icons.clear), onPressed: () => setParent(null), tooltip: "Clear parent"),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Article Title *'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a article title';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 100),
                      if (state is SavingState)
                        const Center(child: CircularProgressIndicator())
                      else
                        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _submitForm, child: Text(widget.isEditMode ? 'Update Article' : 'Create Article'))),
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
