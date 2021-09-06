import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pixgem/model_response/illusts/common_illust.dart';
import 'package:pixgem/model_response/illusts/illusts_search_result.dart';
import 'package:pixgem/request/api_app.dart';
import 'package:pixgem/widgets/illust_waterfall_gird.dart';
import 'package:provider/provider.dart';

class SearchResultPage extends StatefulWidget {
  late String label; // 搜索文本内容

  SearchResultPage(Object arguments, {Key? key}) : super(key: key) {
    label = arguments as String;
  }

  @override
  State<StatefulWidget> createState() => SearchResultPageState();
}

class SearchResultPageState extends State<SearchResultPage> {
  late TextEditingController _textController;
  _SearchResultProvider _provider = _SearchResultProvider();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.label);
    refresh()
        .catchError((onError) => Fluttertoast.showToast(msg: "加载失败!", toastLength: Toast.LENGTH_SHORT, fontSize: 16.0));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => _provider,
      child: Scaffold(
        appBar: AppBar(
          title: Container(
            // height: 40,
            color: Colors.grey.withOpacity(0.1),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: "搜索...",
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true, // 高度包裹，不会存在默认高度
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {},
              tooltip: "more",
            ),
          ],
        ),
        body: Container(
          child: Selector(
            selector: (BuildContext context, _SearchResultProvider provider) {
              return provider.illusts;
            },
            builder: (BuildContext context, List<CommonIllust>? illusts, Widget? child) {
              if (illusts == null) {
                // loading
                return Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(strokeWidth: 1.0),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  return await refresh();
                },
                child: IllustWaterfallGird(
                  artworkList: illusts,
                  onLazyLoad: () async {
                    await loadMore().catchError((onError) =>
                        Fluttertoast.showToast(msg: "加载失败!", toastLength: Toast.LENGTH_SHORT, fontSize: 16.0));
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future refresh() async {
    var result = await ApiApp().searchIllust(searchWord: _textController.value.text);
    _provider.setIllusts(result.illusts);
    _provider.setNextUrl(result.nextUrl);
  }

  // 加载更多
  Future loadMore() async {
    if (_provider.nextUrl == null) return false;
    var res = await ApiApp().getNextUrlData(nextUrl: _provider.nextUrl!);
    var result = IllustsSearchResult.fromJson(res);
    _provider.addIllusts(result.illusts);
    _provider.setNextUrl(result.nextUrl);
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }
}

class _SearchResultProvider with ChangeNotifier {
  List<CommonIllust>? illusts;
  String? nextUrl;

  void setIllusts(List<CommonIllust> illusts) {
    this.illusts = illusts;
    notifyListeners();
  }

  void addIllusts(List<CommonIllust> illusts) {
    this.illusts = [...?this.illusts, ...illusts];
    notifyListeners();
  }

  void setNextUrl(String nextUrl) {
    this.nextUrl = nextUrl;
    notifyListeners();
  }
}