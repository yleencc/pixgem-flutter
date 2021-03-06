import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pixgem/common_provider/illusts_provider.dart';
import 'package:pixgem/component/illust_waterfall/illust_waterfall_grid.dart';
import 'package:pixgem/model_response/illusts/common_illust_list.dart';
import 'package:provider/provider.dart';

typedef IllustRefreshCallback = Future<CommonIllustList> Function();
typedef IllustLazyLoadCallback = Future<CommonIllustList> Function(String nextUrl);

/// 适用于放在TabView里的插画列表页面
/// @parma
///    scrollController
/// @required parma
///    onLazyLoad(String nextUrl)
///    onRefresh()
///
/// For example:
///  IllustGridTabPage(
///    onRefresh: () async {
///      return await ApiNewArtWork().getFollowsNewIllusts(ApiNewArtWork.restrict_all);
///    },
///    onLazyLoad: (String nextUrl) async {
///      var result = await ApiBase().getNextUrlData(nextUrl: nextUrl);
///      return CommonIllustList.fromJson(result);
///    },
///  ),
///
class IllustGridTabPage extends StatefulWidget {
  final IllustLazyLoadCallback onLazyLoad; // 懒加载
  final IllustRefreshCallback onRefresh; // 刷新（包含首次加载）
  final Widget? withoutIllustWidget; // 列表为空时的展示组件
  final ScrollController? scrollController; // 滚动控制器
  final ScrollPhysics? physics; // 滚动物理效果

  @override
  State<StatefulWidget> createState() => IllustGridTabPageState();

  /// 适用于放在TabView里的插画列表页面
  const IllustGridTabPage({
    Key? key,
    required this.onLazyLoad,
    required this.onRefresh,
    this.withoutIllustWidget,
    this.scrollController,
    this.physics,
  }) : super(key: key);
}

class IllustGridTabPageState extends State<IllustGridTabPage> with AutomaticKeepAliveClientMixin {
  final IllustListProvider _provider = IllustListProvider();
  String? nextUrl; // 下一页的地址

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider(
      create: (context) => _provider,
      child: RefreshIndicator(
        onRefresh: () async {
          var result = await widget.onRefresh();
          _provider.setList(result.illusts);
          nextUrl = result.nextUrl;
        },
        child: Consumer(
          builder: (context, IllustListProvider provider, Widget? child) {
            if (provider.list == null) {
              return Container(
                height: min(MediaQuery.of(context).size.height, MediaQuery.of(context).size.width),
                alignment: Alignment.center,
                child: CircularProgressIndicator(strokeWidth: 1.0, color: Theme.of(context).colorScheme.secondary),
              );
            }
            if (provider.list!.isEmpty) {
              // 列表为空时展示
              return SingleChildScrollView(
                physics: widget.physics,
                child: widget.withoutIllustWidget ??
                    // 默认展示的样式
                    Container(
                      height: MediaQuery.of(context).size.height / 1.5,
                      alignment: Alignment.center,
                      child: const Text("暂无", style: TextStyle(fontSize: 18)),
                    ),
              );
            }
            return IllustWaterfallGrid(
              physics: widget.physics,
              artworkList: provider.list!,
              onLazyLoad: () async {
                if (nextUrl == null) {
                  return Fluttertoast.showToast(msg: "已经加载到底了", toastLength: Toast.LENGTH_SHORT, fontSize: 16.0);
                }
                CommonIllustList moreIllustList = await widget.onLazyLoad(nextUrl!); // 懒加载传入下一页地址
                nextUrl = moreIllustList.nextUrl; // 替换新的nextUrl
                provider.addNextIllust(list: moreIllustList.illusts);
                (context as Element).markNeedsBuild();
              },
              scrollController: widget.scrollController,
            );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.onRefresh().then((value) {
      _provider.setList(value.illusts);
      nextUrl = value.nextUrl;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
