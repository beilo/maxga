import 'package:flutter/material.dart';
import 'package:maxga/MangaRepoPool.dart';
import 'package:maxga/components/Card.dart';
import 'package:maxga/components/MangaCoverImage.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/manga/MangaSource.dart';
import 'package:maxga/provider/HistoryProvider.dart';
import 'package:maxga/route/error-page/EmptyPage.dart';
import 'package:maxga/route/mangaInfo/MangaInfoPage.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatefulWidget {
  final name = 'history_page';

  @override
  State<StatefulWidget> createState() => _HistToryPageState();
}

class _HistToryPageState extends State<HistoryPage> {
  GlobalKey scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    List<SimpleMangaInfo> mangaHistoryList =
        Provider.of<HistoryProvider>(context).historyMangaList;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: BackButton(),
        title: Text('历史记录'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () => deleteHistoryList(),
          )
        ],
      ),
      body: mangaHistoryList?.length != 0
          ? ListView(
              children: mangaHistoryList.map((item) {
              MangaSource source = MangaRepoPool.getInstance()
                  .getMangaSourceByKey(item.sourceKey);
              return MangaListTile(
                title: Text(item.title),
                extra: MangaListTileExtra(
                  manga: item,
                  source: source,
                ),
                cover: MangaCoverImage(
                  source: source,
                  url: item.coverImgUrl,
                  tagPrefix: widget.name,
                ),
                onTap: () => this.goMangaInfoPage(item),
              );
            }).toList())
          : EmptyPage('暂无历史记录'),
    );
  }

  goMangaInfoPage(SimpleMangaInfo item) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return MangaInfoPage(
          coverImageBuilder: (c) => MangaCoverImage(
                url: item.coverImgUrl,
                source: MangaRepoPool.getInstance()
                    .getMangaSourceByKey(item.sourceKey),
                tagPrefix: widget.name,
                fit: BoxFit.cover,
              ),
          infoUrl: item.infoUrl,
          sourceKey: item.sourceKey);
    }));
  }

  deleteHistoryList() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('是否清除历史记录'),
              actions: <Widget>[
                FlatButton(
                    child: const Text('取消'),
                    onPressed: () => Navigator.pop(context)),
                FlatButton(
                    child: const Text('清除'),
                    onPressed: () {
                      Navigator.pop(context);
                      Provider.of<HistoryProvider>(context).clearHistory();
                    }),
              ],
            ));
  }
}
