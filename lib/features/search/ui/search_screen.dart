import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zad_aldaia/core/theming/my_colors.dart';
import 'package:zad_aldaia/core/theming/my_text_style.dart';
import 'package:zad_aldaia/features/article/data/models/article_item.dart';
import 'package:zad_aldaia/features/article/ui/widgets/image_item.dart';
import 'package:zad_aldaia/features/article/ui/widgets/text_item.dart';
import 'package:zad_aldaia/features/article/ui/widgets/video_item.dart';
import 'package:zad_aldaia/features/search/logic/search_cubit.dart';
import 'package:zad_aldaia/features/search/logic/search_state.dart';
import 'package:zad_aldaia/core/models/article_type.dart';
import 'package:zad_aldaia/generated/l10n.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/widgets/no_items_widget.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Column(children: [
            SearchBar(
              backgroundColor: WidgetStatePropertyAll(Colors.white),
              hintText: S.of(context).search,
              trailing: [IconButton(onPressed: () {
                Navigator.of(context).pop();
              }, icon: Icon(Icons.clear))],
              onChanged: (value) {
                context.read<SearchCubit>().search(value);
              },
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 20),
                child: BlocBuilder<SearchCubit,SearchState>(builder:(context, state) {
                  if(state is SearchLoadedState){
                    if(state.items.isEmpty) {
                      return NoItemsWidget();
                    }
                    return ListView.builder(itemCount: state.items.length,itemBuilder: (context, index) {
                      var item = state.items[index];
                      switch(state.items[index].type){
                        case ArticleType.Text:
                          return TextItem(item: item as TextArticle);
                        case ArticleType.Image:
                          return ImageItem(item: item as ImageArticle, onDownloadPressed: (url) async{
                            if(kIsWeb) {
                              await context.read<SearchCubit>().saveImageWeb(url);
                            }
                            else{
                              await context.read<SearchCubit>().saveImageAndroid(url);
                            }
                          });
                        case ArticleType.Video:
                          return VideoItem(item: item as VideoArticle);
                      }
                    },);
                  }
                  else if(state is SearchingState){
                    return Center(
                      child: SizedBox(
                          width: 40.h,
                          height: 40.h,
                          child: CircularProgressIndicator(color: MyColors.primaryColor,)),
                    );
                  }
                  return Center(child: Column(mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.library_books_rounded,color: MyColors.primaryColor,size: 35.h,),
                      Text("No Items",style: MyTextStyle.font16primaryRegular,)
                    ],
                  ));
                }, ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}