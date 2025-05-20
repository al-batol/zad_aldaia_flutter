// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:zad_aldaia/core/routing/routes.dart';
// import 'package:zad_aldaia/features/items/data/models/item.dart';

// class ItemWidget extends StatelessWidget {
//   final Item item;
//   final VoidCallback? onTap;
//   final Function(Item)? onArticleItemUp;
//   final Function(Item)? onArticleItemDown;

//   const ItemWidget({super.key, required this.item, this.onTap, this.onArticleItemUp, this.onArticleItemDown});

//   @override
//   Widget build(BuildContext context) {
//     return Opacity(
//       opacity: item.isActive ? 1.0 : 0.5,
//       child: Card(
//         elevation: 2.0,
//         child: ListTile(
//           onTap: onTap,
//           leading: (item.image == null) ? null : CachedNetworkImage(imageUrl: item.image!, height: 50, width: 50, fit: BoxFit.cover),
//           title: Text(item.title ?? '---'),
//           // subtitle: Text(item.lang ?? ''),
//           subtitle: Text('${item.childrenCount} - ${item.articlesCount}'),
//           trailing:
//               (Supabase.instance.client.auth.currentUser == null)
//                   ? null
//                   : SizedBox(
//                     width: 80,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.edit),
//                           onPressed: () {
//                             Navigator.of(context).pushNamed(MyRoutes.addItemScreen, arguments: {"id": item.id});
//                           },
//                         ),
//                         Column(
//                           children: [
//                             InkWell(onTap: () => onArticleItemUp?.call(item), child: Icon(Icons.arrow_circle_up)),
//                             InkWell(onTap: () => onArticleItemDown?.call(item), child: Icon(Icons.arrow_circle_down)),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//         ),
//       ),
//     );
//   }
// }
