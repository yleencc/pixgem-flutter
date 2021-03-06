import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pixgem/component/illusts_grid_tabpage.dart';
import 'package:pixgem/config/ranking_mode_constants.dart';
import 'package:pixgem/model_response/illusts/common_illust_list.dart';
import 'package:pixgem/request/api_base.dart';
import 'package:pixgem/request/api_illusts.dart';

class ArtworksLeaderboardPage extends StatefulWidget {
  const ArtworksLeaderboardPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ArtworksLeaderboardPageState();
}

class ArtworksLeaderboardPageState extends State<ArtworksLeaderboardPage> with TickerProviderStateMixin {
  late TabController _tabController;
  ScrollController scrollController = ScrollController();
  // tab分页的对应模式与字段
  final Map<String, String> _tabsMap = {
    RankingModeConstants.illust_day: "每日",
    RankingModeConstants.illust_week: "每周",
    RankingModeConstants.illust_month: "每月",
    RankingModeConstants.illust_day_male: "男性向",
    RankingModeConstants.illust_day_female: "女性向",
    RankingModeConstants.illust_week_original: "原创",
    RankingModeConstants.illust_week_rookie: "新人",
    RankingModeConstants.illust_day_r18: "每日R18",
    RankingModeConstants.illust_week_r18: "每周R18",
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 0, length: _tabsMap.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExtendedNestedScrollView(
        floatHeaderSlivers: true,
        onlyOneScrollInBody: true,
        controller: scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              snap: true,
              floating: true,
              title: const Text("排行榜"),
              bottom: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                controller: _tabController,
                isScrollable: true,
                tabs: [
                  for (String name in _tabsMap.values)
                    Tab(
                      text: name,
                    ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up),
                  onPressed: () {
                    scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.decelerate,
                    );
                  },
                  tooltip: "回到顶部",
                ),
              ],
            ),
          ];
        },
        body: Builder(
          builder: (context) {
            return TabBarView(
              controller: _tabController,
              children: [
                for (String mode in _tabsMap.keys)
                  IllustGridTabPage(
                    physics: const BouncingScrollPhysics(),
                    onRefresh: () async {
                      return await ApiIllusts().getIllustRanking(mode: mode).catchError((onError) {
                        Fluttertoast.showToast(msg: "获取排行失败$onError", toastLength: Toast.LENGTH_SHORT, fontSize: 16.0);
                      });
                    },
                    onLazyLoad: (String nextUrl) async {
                      var result = await ApiBase().getNextUrlData(nextUrl: nextUrl);
                      return CommonIllustList.fromJson(result);
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }
}
