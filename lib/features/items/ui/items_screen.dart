import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/di/dependency_injection.dart';
import 'package:zad_aldaia/core/helpers/share.dart';
import 'package:zad_aldaia/core/helpers/storage.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/features/items/data/models/item.dart';
import 'package:zad_aldaia/features/items/logic/items_cubit.dart';
import 'package:zad_aldaia/features/items/ui/widgets/image_item.dart';
import 'package:zad_aldaia/features/items/ui/widgets/text_item.dart';
import 'package:zad_aldaia/features/items/ui/widgets/video_item.dart';
import '../../../core/theming/my_text_style.dart';
import 'package:zad_aldaia/generated/l10n.dart';

class ItemsScreen extends StatefulWidget {
  final String? articleId;
  final String? title;

  const ItemsScreen({super.key, required this.articleId, this.title});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  late final ItemsCubit cubit = getIt<ItemsCubit>();
  // bool _isSearching = false;

  @override
  void initState() {
    loadData();
    super.initState();
  }

  loadData() {
    cubit.loadItems(eqMap: {'article_id': widget.articleId}..removeWhere((key, value) => value == null));
  }

  List<Item> selectedItems = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   onPressed: () {
        //     if (_isSearching) {
        //       setState(() {
        //         _isSearching = false;
        //       });
        //     } else {
        //       Navigator.of(context).pop();
        //     }
        //   },
        //   icon: Icon(Icons.arrow_back),
        // ),
        titleTextStyle: MyTextStyle.font22primaryBold,
        centerTitle: true,
        title: Text(widget.title ?? 'Items'),
        // _isSearching
        //     ? TextField(
        //       autofocus: true,
        //       decoration: InputDecoration(hintText: S.of(context).search, border: InputBorder.none),
        //       style: const TextStyle(color: Colors.black),
        //       onChanged: (query) {
        //         // cubit.search(query);
        //       },
        //     )
        //     : Text(widget.title ?? 'Items'),
        actions: [
          // _isSearching
          //     ? IconButton(
          //       icon: const Icon(Icons.close),
          //       onPressed: () {
          //         _isSearching = false;
          //         setState(() {});
          //       },
          //     )
          //     : IconButton(
          //       icon: Icon(Icons.search),
          //       onPressed: () {
          //         _isSearching = true;
          //         setState(() {});
          //       },
          //     ),
          if (selectedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                Share.multi(selectedItems);
              },
            ),
          if (Supabase.instance.client.auth.currentUser != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(MyRoutes.addItemScreen, arguments: {"article_id": widget.articleId});
              },
            ),
        ],
      ),
      body: BlocProvider(
        create: (context) => cubit,
        child: BlocBuilder<ItemsCubit, ItemsState>(
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
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        var prevItemId = index > 0 ? state.items[index - 1].id : null;
                        var item = state.items[index];
                        var nextItemId = index < state.items.length - 1 ? state.items[index + 1].id : null;
                        switch (item.type) {
                          case ItemType.text:
                            return TextItem(
                              item: item,
                              isSelected: selectedItems.contains(item),
                              onSelect: (article) {
                                if (selectedItems.contains(article)) {
                                  selectedItems.remove(article);
                                } else {
                                  selectedItems.add(article);
                                }
                                setState(() {});
                              },
                              onItemUp: (item) {
                                cubit.swapItemsOrder(item.id, prevItemId ?? "");
                              },
                              onItemDown: (item) {
                                cubit.swapItemsOrder(item.id, nextItemId ?? "");
                              },
                            );
                          case ItemType.image:
                            return ImageItem(
                              item: item,
                              isSelected: selectedItems.contains(item),
                              onSelect: (article) {
                                if (selectedItems.contains(article)) {
                                  selectedItems.remove(article);
                                } else {
                                  selectedItems.add(article);
                                }
                                setState(() {});
                              },
                              onItemUp: (item) {
                                cubit.swapItemsOrder(item.id, prevItemId ?? "");
                              },
                              onItemDown: (item) {
                                cubit.swapItemsOrder(item.id, nextItemId ?? "");
                              },
                              onDownloadPressed: (url) async {
                                Storage.download(url);
                              },
                            );
                          case ItemType.video:
                            return VideoItem(
                              item: item,
                              isSelected: selectedItems.contains(item),
                              onSelect: (article) {
                                if (selectedItems.contains(article)) {
                                  selectedItems.remove(article);
                                } else {
                                  selectedItems.add(article);
                                }
                                setState(() {});
                              },
                              onItemUp: (item) {
                                cubit.swapItemsOrder(item.id, prevItemId ?? "");
                              },
                              onItemDown: (item) {
                                cubit.swapItemsOrder(item.id, nextItemId ?? "");
                              },
                            );
                        }
                      },
                    ),
                  ),
                ],
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
