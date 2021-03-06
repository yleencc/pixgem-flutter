import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pixgem/config/constants.dart';
import 'package:pixgem/model_response/illusts/common_illust.dart';

class IllustWaterfallCard extends StatefulWidget {
  final CommonIllust illust;
  final bool isBookmarked; // 是否被收藏
  final Function onTap; // 点击卡片的事件
  final Function onTapBookmark; // 点击收藏的事件，会自动刷新收藏按钮的UI

  @override
  State<StatefulWidget> createState() => IllustWaterfallCardState();

  const IllustWaterfallCard(
      {Key? key, required this.illust, required this.isBookmarked, required this.onTap, required this.onTapBookmark})
      : super(key: key);
}

class IllustWaterfallCardState extends State<IllustWaterfallCard> {
  @override
  Widget build(BuildContext context) {
    // LayoutBuilder能获取到父组件的最大支撑宽度
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SizedBox(
          width: double.infinity,
          height: (widget.illust.height * constraints.maxWidth) / widget.illust.width,
          child: Card(
            elevation: 2.0,
            margin: EdgeInsets.zero,
            shadowColor: Colors.grey.shade600,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.loose,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    width: widget.illust.width.toDouble(),
                    height: widget.illust.height.toDouble(),
                    imageUrl: widget.illust.imageUrls.medium,
                    httpHeaders: const {"Referer": CONSTANTS.referer},
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.black12.withOpacity(0.15),
                      highlightColor: Colors.black12.withOpacity(0.1),
                      onTap: () => widget.onTap(),
                    ),
                  ),
                ),
                // 收藏按钮
                Builder(builder: (BuildContext context) {
                  return Positioned(
                    right: 4,
                    bottom: 4,
                    child: GestureDetector(
                      onTap: () async {
                        await widget.onTapBookmark();
                        (context as Element).markNeedsBuild();
                      },
                      child: Icon(
                        widget.illust.isBookmarked ? Icons.favorite : Icons.favorite_rounded,
                        color: widget.illust.isBookmarked ? Colors.red.shade600 : Colors.grey,
                        size: 32,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
