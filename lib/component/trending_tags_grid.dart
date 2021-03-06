import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pixgem/config/constants.dart';
import 'package:pixgem/model_response/illusts/illust_trending_tags.dart';

class TrendingTagsGrid extends StatefulWidget {
  final List<TrendTags> tags;

  const TrendingTagsGrid({Key? key, required this.tags}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TrendingTagsGridState();
}

class TrendingTagsGridState extends State<TrendingTagsGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: widget.tags.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (BuildContext context, int index) =>
          _buildItem(context, index),
    );
  }

  Widget _buildItem(BuildContext context, index) {
    if (widget.tags.isEmpty) {
      return const Text("暂无");
    }
    var item = widget.tags[index];
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: item.illust.imageUrls.squareMedium,
            httpHeaders: const {"referer": CONSTANTS.referer},
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black26,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 8,
          child: Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  "#${item.tag}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                Text(
                  item.translatedName ?? "",
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                )
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.black12.withOpacity(0.15),
              highlightColor: Colors.black12.withOpacity(0.1),
              onTap: () {
                Navigator.of(context).pushNamed("search_result", arguments: item.tag);
              },
            ),
          ),
        ),
      ],
    );
  }
}
