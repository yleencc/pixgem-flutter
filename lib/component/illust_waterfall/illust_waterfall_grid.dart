import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pixgem/model_response/illusts/common_illust.dart';
import 'package:pixgem/pages/illust/illust_detail/illust_detail_page.dart';
import 'package:pixgem/request/api_illusts.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'illust_waterfall_card.dart';

class IllustWaterfallGrid extends StatelessWidget {
  final List<CommonIllust> artworkList; // 图片含基本信息的列表
  final Function onLazyLoad; // 触发懒加载（加载更多）的时候调用
  final int? limit; // 列表项的极限数量，为空则表示不限
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final bool isSliver; // 是否为Sliver型组件

  const IllustWaterfallGrid(
      {Key? key, required this.artworkList, required this.onLazyLoad, this.limit, this.scrollController, this.physics})
      : isSliver = false,
        super(key: key);

  const IllustWaterfallGrid.sliver(
      {Key? key, required this.artworkList, required this.onLazyLoad, this.limit, this.scrollController, this.physics})
      : isSliver = true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return isSliver
        ? SliverWaterfallFlow(
            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              collectGarbage: (List<int> garbages) {
                // print('collect garbage : $garbages');
                // 内存回收
                int end = garbages.last;
                for (int i = garbages.first; i <= end; i++) {
                  final provider = CachedNetworkImageProvider(
                    artworkList[i].imageUrls.medium,
                  );
                  provider.evict();
                }
              },
              viewportBuilder: (int firstIndex, int lastIndex) {
                // print('viewport : [$firstIndex,$lastIndex]');
              },
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) => _buildItem(context, index),
              childCount: artworkList.length + 1,
            ),
          )
        : WaterfallFlow.builder(
            padding: EdgeInsets.zero,
            controller: scrollController,
            physics: physics,
            itemCount: artworkList.length + 1,
            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              collectGarbage: (List<int> garbages) {
                // print('collect garbage : $garbages');
                for (var index in garbages) {
                  final provider = CachedNetworkImageProvider(
                    artworkList[index].imageUrls.medium,
                  );
                  provider.evict();
                }
              },
              viewportBuilder: (int firstIndex, int lastIndex) {
                // print('viewport : [$firstIndex,$lastIndex]');
              },
            ),
            itemBuilder: (BuildContext context, int index) => _buildItem(context, index),
          );
  }

  Widget _buildItem(BuildContext context, index) {
    // 如果滑动到了表尾加载更多的项
    if (index == artworkList.length) {
      // 未到列表上限，继续获取数据
      if (artworkList.length < (limit ?? double.infinity)) {
        if (artworkList.isNotEmpty) onLazyLoad(); // 列表不为空才获取数据
        //加载时显示loading
        return _buildLoading(context);
      } else {
        //已经加载足够多的数据，不再获取
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16.0),
          child: const Text(
            "没有更多了",
            style: TextStyle(color: Colors.grey),
          ),
        );
      }
    }
    return Padding(
      padding: const EdgeInsets.all(4),
      child: IllustWaterfallCard(
        illust: artworkList[index],
        isBookmarked: artworkList[index].isBookmarked,
        onTap: () => artworkList[index].restrict == 2
            ? Fluttertoast.showToast(msg: "该图片已被删除或不公开", toastLength: Toast.LENGTH_SHORT, fontSize: 16.0)
            : Navigator.of(context).pushNamed("artworks_detail",
                arguments: ArtworkDetailModel(
                    list: artworkList,
                    index: index,
                    callback: (int index, bool isBookmark) {
                      // 回调方法，传给详情页
                      artworkList[index].isBookmarked = isBookmark;
                      (context as Element).markNeedsBuild();
                    })),
        onTapBookmark: () async {
          var item = artworkList[index];
          try {
            bool result = await postBookmark(item.id.toString(), item.isBookmarked);
            if (result) {
              Fluttertoast.showToast(msg: "操作成功", toastLength: Toast.LENGTH_SHORT, fontSize: 16.0);
              artworkList[index].isBookmarked = !item.isBookmarked;
            } else {
              throw Exception("http status code is not 200.");
            }
          } catch (e) {
            Fluttertoast.showToast(msg: "操作失败！可能已经${ item.isBookmarked ? "取消" : "" }收藏了", toastLength: Toast.LENGTH_SHORT, fontSize: 16.0);
          }
        },
      ),
    );
  }

  /* 收藏或者取消收藏插画 */
  Future<bool> postBookmark(String id, bool oldIsBookmark) async {
    bool isSucceed = false; // 是否执行成功
    if (oldIsBookmark) {
      isSucceed = await ApiIllusts().deleteIllustBookmark(illustId: id);
    } else {
      isSucceed = await ApiIllusts().addIllustBookmark(illustId: id);
    }
    // 执行结果
    return isSucceed;
  }

  // 构建循环加载动画
  Widget _buildLoading(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: const CircularProgressIndicator(strokeWidth: 1.0),
    );
  }
}
