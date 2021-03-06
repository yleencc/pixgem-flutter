import 'dart:math';

import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pixgem/component/trending_tags_grid.dart';
import 'package:pixgem/model_response/illusts/illust_trending_tags.dart';
import 'package:pixgem/request/api_serach.dart';
import 'package:provider/provider.dart';

import 'search_provider.dart';

class SearchTabPage extends StatefulWidget {
  const SearchTabPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SearchTabPageState();
  }
}

class SearchTabPageState extends State<SearchTabPage> with AutomaticKeepAliveClientMixin {
  final SearchProvider _provider = SearchProvider();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider(
      create: (BuildContext context) => _provider,
      child: ExtendedNestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              title: _buildSearchBox(context),
              actions: <Widget>[
                IconButton(
                  icon: const Text("取消"),
                  onPressed: () {
                    _focusNode.unfocus();
                  },
                  tooltip: "取消",
                ),
              ],
            )
          ];
        },
        // 内容主体
        body: RefreshIndicator(
          onRefresh: () async {
            return await requestTrendingTags().catchError(((onError) {
              Fluttertoast.showToast(msg: "刷新失败$onError", toastLength: Toast.LENGTH_SHORT, fontSize: 16.0);
            }));
          },
          child: Selector(
            selector: (BuildContext context, SearchProvider provider) {
              return provider.trendTags;
            },
            builder: (BuildContext context, List<TrendTags>? tags, Widget? child) {
              if (tags == null) {
                // loading
                return SingleChildScrollView(
                  child: Container(
                    height: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(strokeWidth: 1.0, color: Theme.of(context).colorScheme.secondary),
                  ),
                );
              }
              return TrendingTagsGrid(
                tags: tags,
              );
            },
          ),
        ),
      ),
    );
  }

  // 构建搜索框
  Widget _buildSearchBox(BuildContext context) {
    return Container(
      // 搜索框
      height: 40,
      color: Colors.grey.withOpacity(0.12),
      child: Row(
        children: [
          // 框左边的搜索图标
          const Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Icon(Icons.search_outlined, size: 18),
          ),
          // 搜索框
          Expanded(
            flex: 1,
            child: TextField(
              autofocus: false,
              focusNode: _focusNode,
              controller: _textController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              // 键盘的回车键换成搜索按钮
              decoration: const InputDecoration(
                hintText: "搜索...",
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true, // 高度包裹，不会存在默认高度
              ),
              onSubmitted: (value) {
                // 跳转搜索结果页面
                Navigator.of(context).pushNamed("search_result", arguments: value);
              },
              onChanged: (value) {
                if (value == "") {
                  _provider.setIsExistText(false);
                } else {
                  _provider.setIsExistText(true);
                }
              },
            ),
          ),
          // 清空按钮
          Selector(
            builder: (BuildContext context, bool isExistText, Widget? child) {
              if (!isExistText) {
                return Container();
              }
              return InkWell(
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.clear, size: 18),
                ),
                onTap: () {
                  _textController.clear();
                  _provider.setIsExistText(false);
                },
              );
            },
            selector: (context, SearchProvider provider) {
              return provider.isExistText;
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // 获取热门标签
    requestTrendingTags().catchError(((onError) {
      Fluttertoast.showToast(msg: "加载失败$onError", toastLength: Toast.LENGTH_SHORT, fontSize: 16.0);
    }));
  }

  Future requestTrendingTags() async {
    var resModel = await ApiSearch().getTrendingTags();
    _provider.setTags(resModel.trendTags);
    return resModel;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }
}
