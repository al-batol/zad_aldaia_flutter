import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zad_aldaia/core/di/dependency_injection.dart';
import 'package:zad_aldaia/core/helpers/language.dart';
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

class _CategoryFormScreenState extends State<CategoryFormScreen> 
    with SingleTickerProviderStateMixin {
  late final CategoriesCubit store;
  Category category = Category(id: '');
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  Category? parentCategory;
  bool _isActive = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    store = getIt<CategoriesCubit>();
    if (widget.isEditMode) {
      store.loadCategory({'id': widget.categoryId!});
    }
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void listener(BuildContext context, CategoriesState state) {
    if (state is ErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error, style: TextStyle(fontSize: 14.sp)),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
    }
    if (state is SavedState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Category ${widget.isEditMode ? "updated" : "created"} successfully!',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      if ((parentCategory?.id ?? category.parentId) != null) {
        Navigator.of(context).pushNamed(
          MyRoutes.categories, 
          arguments: {
            "id": parentCategory?.id ?? category.parentId, 
            "title": parentCategory?.title
          },
        );
      }
    }
    if (state is LoadedState) {
      category = state.item;
      fillForm();
    }
  }

  Future<void> fillForm() async {
    _titleController.text = category.title ?? '';
    _isActive = category.isActive;
    if (category.parentId != null) {
      parentCategory = await store.findCategory({'id': category.parentId!});
    }
    setState(() {});
  }

  Future<void> _selectParentCategory() async {
    final Category? result = await Navigator.push<Category?>(
      context, 
      MaterialPageRoute(
        builder: (context) => const CategorySelectionScreen(forArticles: false),
        settings: const RouteSettings(name: 'Select Parent Category'),
      ),
    );

    if (result != null) {
      setParent(result);
    }
  }

  void setParent(Category? parent) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAE6),
      appBar: AppBar(
        centerTitle: true,
        title: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Text(
                  widget.isEditMode ? 'Edit Category' : 'Create New Category',
                  style: GoogleFonts.exo(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF005A32),
                Color(0xFF008C5A),
              ],
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20.r),
          ),
        ),
        elevation: 8,
        shadowColor: Colors.green.shade800.withOpacity(0.3),
      ),
      body: BlocProvider(
        create: (context) => store,
        child: BlocListener<CategoriesCubit, CategoriesState>(
          listener: listener,
          child: BlocBuilder<CategoriesCubit, CategoriesState>(
            builder: (context, state) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(20.r),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // Title Field
                              _buildAnimatedFormField(
                                label: 'Category Title *',
                                controller: _titleController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a category title';
                                  }
                                  return null;
                                },
                                icon: Icons.title,
                              ),
                              SizedBox(height: 25.h),

                              // Parent Category Selection
                              _buildSectionHeader('Parent Category'),
                              SizedBox(height: 12.h),
                              _buildParentCategorySelector(),
                              SizedBox(height: 25.h),

                              // Active Switch
                              _buildActiveSwitch(),
                              SizedBox(height: 30.h),

                              // Image Upload
                              _buildImageUpload(),
                              SizedBox(height: 30.h),

                              // Submit Button
                              if (state is SavingState)
                                _buildLoadingIndicator()
                              else
                                _buildSubmitButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedFormField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?)? validator,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: GoogleFonts.exo(
          fontSize: 16.sp,
          color: Colors.grey.shade800,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.exo(
            color: Colors.grey.shade600,
            fontSize: 16.sp,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.green.shade700,
            size: 24.w,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Colors.green.shade700,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 16.h,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Text(
      text,
      style: GoogleFonts.exo(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildParentCategorySelector() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
              child: InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: _selectParentCategory,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.category,
                        color: Colors.green.shade700,
                        size: 24.w,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        parentCategory?.title ?? '(Top Level)',
                        style: GoogleFonts.exo(
                          fontSize: 16.sp,
                          color: parentCategory != null 
                              ? Colors.grey.shade800 
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (parentCategory != null)
            IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.red.shade400,
                size: 24.w,
              ),
              onPressed: () => setParent(null),
              tooltip: "Clear parent",
            ),
        ],
      ),
    );
  }

  Widget _buildActiveSwitch() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 8.h,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  _isActive ? Icons.check_circle : Icons.remove_circle,
                  color: _isActive ? Colors.green.shade700 : Colors.red.shade400,
                  size: 24.w,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Category Status',
                  style: GoogleFonts.exo(
                    fontSize: 16.sp,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            Switch.adaptive(
              value: _isActive,
              activeColor: Colors.green.shade700,
              activeTrackColor: Colors.green.shade200,
              inactiveThumbColor: Colors.red.shade400,
              inactiveTrackColor: Colors.red.shade100,
              onChanged: (bool value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUpload() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Image',
              style: GoogleFonts.exo(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 12.h),
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
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: Material(
        borderRadius: BorderRadius.circular(12.r),
        elevation: 6,
        shadowColor: Colors.green.shade800.withOpacity(0.3),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: _submitForm,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.shade700,
                  Colors.green.shade600,
                ],
              ),
            ),
            child: Center(
              child: Text(
                widget.isEditMode ? 'UPDATE CATEGORY' : 'CREATE CATEGORY',
                style: GoogleFonts.exo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}