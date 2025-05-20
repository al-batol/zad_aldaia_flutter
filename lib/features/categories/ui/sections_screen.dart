import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/di/dependency_injection.dart';
import 'package:zad_aldaia/core/models/languge.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/features/categories/logic/categories_cubit.dart';
import 'package:zad_aldaia/features/categories/ui/category_grid_widget.dart';
import 'package:zad_aldaia/features/home/logic/home_cubit.dart';
import 'package:zad_aldaia/features/home/ui/widgets/language_drop_down_bottom.dart';
import '../../../core/theming/my_text_style.dart';
import 'package:zad_aldaia/generated/l10n.dart';

class SectionsScreen extends StatefulWidget {
  const SectionsScreen({super.key});

  @override
  State<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen> {
  late final CategoriesCubit cubit = getIt<CategoriesCubit>();
  late final HomeCubit authCubit = getIt<HomeCubit>();
  String language = Language.english;
  final GlobalKey<FormState> adminPasswordFormKey = GlobalKey();
  final TextEditingController passwordController = TextEditingController();
  String? passwordError;
  bool checkingPassword = false;
  bool _obscureText = true;

  @override
  void initState() {
    loadData();
    super.initState();

    FlutterNativeSplash.remove();
  }

  loadData() {
    cubit.getChildCategories(null, language);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).home),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed(MyRoutes.searchScreen);
          },
          icon: Icon(Icons.search),
        ),
        actions: [
          // if (Supabase.instance.client.auth.currentUser != null)
          //   IconButton(
          //     icon: const Icon(Icons.add),
          //     onPressed: () {
          //       Navigator.of(context).pushNamed(MyRoutes.addCategoryScreen, arguments: {"parent_id": widget.parentId});
          //     },
          //   ),
          LanguageDropDown(
            language: language,
            onSelect:
                (p0) => setState(() {
                  language = p0 ?? Language.english;
                  loadData();
                }),
          ),
          IconButton(
            icon: (Supabase.instance.client.auth.currentUser != null) ? Icon(Icons.logout) : Icon(Icons.admin_panel_settings),
            onPressed: () async {
              if (await authCubit.isAuthenticated()) {
                passwordError = null;
                await Supabase.instance.client.auth.signOut();
                setState(() {});
              } else {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder:
                        (context) => BlocProvider.value(
                          value: cubit,
                          child: Dialog(
                            backgroundColor: Colors.white,
                            child: Container(
                              padding: EdgeInsetsDirectional.symmetric(vertical: 10, horizontal: 20),
                              child: StatefulBuilder(
                                builder: (builderContext, setStateX) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(S.of(context).enterPassword, style: MyTextStyle.font18BlackBold),
                                      SizedBox(height: 20),
                                      Form(
                                        key: adminPasswordFormKey,
                                        child: TextFormField(
                                          controller: passwordController,
                                          obscureText: _obscureText,
                                          decoration: InputDecoration(
                                            errorText: passwordError,
                                            hintText: S.of(context).password,
                                            suffixIcon: IconButton(
                                              icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                                              onPressed: () {
                                                setStateX(() {
                                                  _obscureText = !_obscureText;
                                                });
                                              },
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return S.of(context).pleaseEnterPassword;
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(S.of(context).dismiss),
                                          ),
                                          SizedBox(width: 15),
                                          ElevatedButton(
                                            onPressed: () async {
                                              if (adminPasswordFormKey.currentState!.validate()) {
                                                setStateX(() {
                                                  checkingPassword = true;
                                                });
                                                if (await authCubit.signIn(passwordController.text)) {
                                                  passwordError = null;
                                                  Navigator.of(context).pop();
                                                  setState(() {});
                                                } else {
                                                  setStateX(() {
                                                    passwordError = S.of(context).wrongPassword;
                                                  });
                                                }
                                                checkingPassword = false;
                                              }
                                            },
                                            child:
                                                checkingPassword == true
                                                    ? Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)))
                                                    : Text(S.of(context).continu),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => cubit,
        child: BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, state) {
            if (state is ErrorState) {
              return Center(child: Text(state.error));
            }
            if (state is LoadingState) {
              return Center(child: CircularProgressIndicator());
            }
            if (state is ListLoadedState) {
              if (state.items.isEmpty) {
                return Center(child: Text('Empty'));
              }
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return CategoryGridWidget(
                    category: item,
                    onTap: () {
                      if (item.childrenCount > 0) {
                        Navigator.of(context).pushNamed(MyRoutes.categories, arguments: {"category_id": item.id, "title": item.title});
                      } else {
                        Navigator.of(context).pushNamed(MyRoutes.articles, arguments: {"category_id": item.id, "title": item.title});
                      }
                    },
                    onArticleItemUp: (category) async {
                      if (index > 0) {
                        await cubit.swapCategoriesOrder(item.id, state.items[index - 1].id);
                        loadData();
                      }
                    },
                    onArticleItemDown: (category) async {
                      if (index < state.items.length - 1) {
                        await cubit.swapCategoriesOrder(item.id, state.items[index + 1].id);
                        loadData();
                      }
                    },
                  );
                },
              );
            }
            return Center(child: Text('STATE: ${state.runtimeType}'));
          },
        ),
      ),
    );
  }
}
