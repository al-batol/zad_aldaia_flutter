import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/features/categories/data/models/category.dart';

class CategoryGridWidget extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;
  final Function(Category)? onArticleItemUp;
  final Function(Category)? onArticleItemDown;

  const CategoryGridWidget({super.key, required this.category, this.onTap, this.onArticleItemUp, this.onArticleItemDown});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: category.isActive ? 1.0 : 0.5,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        elevation: 5,
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        margin: EdgeInsets.all(10),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              // Positioned.fill(child: (category.image == null) ? Icon(Icons.category) : CachedNetworkImage(imageUrl: category.image!, height: 50, width: 50, fit: BoxFit.cover)),
              Positioned.fill(
                child:
                    (category.image == null)
                        ? Icon(Icons.category)
                        : Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(category.image!),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.4), BlendMode.darken),
                            ),
                          ),
                        ),
              ),
              Positioned.fill(child: Center(child: Text(category.title ?? '-', style: TextStyle(color: Colors.white, fontSize: 24)))),
              // Positioned.fill(child: Container(color: Colors.black, op)),
              if (Supabase.instance.client.auth.currentUser != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.amber),
                          onPressed: () {
                            Navigator.of(context).pushNamed(MyRoutes.addCategoryScreen, arguments: {"id": category.id});
                          },
                        ),

                        IconButton(onPressed: () => onArticleItemUp?.call(category), icon: Icon(Icons.arrow_circle_up, color: Colors.white)),
                        IconButton(onPressed: () => onArticleItemDown?.call(category), icon: Icon(Icons.arrow_circle_down, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
