import 'package:flutter/material.dart';
import 'package:maxga/model/manga/MangaSource.dart';
import 'package:maxga/model/maxga/MangaReadProcess.dart';

import 'MangaCoverImage.dart';

class MangaGridItem extends StatelessWidget {
  final ReadMangaStatus manga;
  final String tagPrefix;

  final MangaSource source;

  const MangaGridItem(
      {Key key, @required this.manga, @required this.tagPrefix,@required this.source})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              width: 130,
              height: 150,
              margin: EdgeInsets.only(bottom: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: MangaCoverImage(
                  url: manga.coverImgUrl,
                  source: source,
                  fit: BoxFit.fitWidth,
                  tagPrefix: tagPrefix,
                ),
              )),
          Text(manga.title,
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(manga.lastUpdateChapter.title,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, textBaseline: TextBaseline.alphabetic, color: Colors.black45)),
                ),
                Text(source.name,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 12, textBaseline: TextBaseline.alphabetic, color: Colors.black45))
              ],
            ),
          )
        ],
      ),
    );
  }
}