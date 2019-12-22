import 'package:flutter/material.dart';
import 'package:maxga/MangaRepoPool.dart';
import 'package:maxga/Utils/MaxgaUtils.dart';
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/model/manga/Chapter.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/manga/MangaSource.dart';
import 'package:maxga/model/maxga/MangaReadProcess.dart';
import 'package:maxga/model/maxga/MangaViewerPopResult.dart';
import 'package:maxga/provider/HistoryProvider.dart';
import 'package:maxga/route/error-page/ErrorPage.dart';
import 'package:maxga/route/mangaInfo/MaganInfoWrapper.dart';
import 'package:maxga/route/mangaInfo/MangaInfoCover.dart';
import 'package:maxga/route/mangaViewer/MangaViewer.dart';
import 'package:maxga/service/MangaReadStorage.service.dart';
import 'package:provider/provider.dart';

import 'MangaChapeter.dart';
import 'MangaInfoBottomBar.dart';
import 'MangaInfoIntro.dart';

enum _MangaInfoPageStatus {
  loading,
  over,
  error,
}

class MangaInfoPage extends StatefulWidget {
  final ReadMangaStatus manga;

  final String sourceKey;
  final String infoUrl;
  final CoverImageBuilder coverImageBuilder;

  const MangaInfoPage(
      {Key key,
      @required this.coverImageBuilder,
      @required this.sourceKey,
      @required this.infoUrl})
      : manga = null,
        super(key: key);

  MangaInfoPage.fromCollection(
      {Key key, @required this.coverImageBuilder, @required this.manga})
      : infoUrl = null,
        this.sourceKey = null,
        super(key: key);

  bool get isFromCollection => manga != null;

  @override
  State<StatefulWidget> createState() => _MangaInfoPageState();
}

class _MangaInfoPageState extends State<MangaInfoPage> {
  _MangaInfoPageStatus loading = _MangaInfoPageStatus.loading;
  ReadMangaStatus readMangaStatus;
  MangaSource source;
  List<Chapter> chapterList = [];

  String introduce;

  @override
  void initState() {
    super.initState();
    if (widget.isFromCollection) {
      _initInfo(
          url: widget.manga.infoUrl,
          sourceKey: widget.manga.sourceKey
      );
    } else {
      _initInfo(
        url: widget.infoUrl,
        sourceKey: widget.sourceKey
      );
    }
    source = MangaRepoPool.getInstance().getMangaSourceByKey(widget.sourceKey ?? widget.manga.sourceKey);
  }

  @override
  Widget build(BuildContext context) {
    Widget mangaInfoIntro;
    Widget mangaInfoChapter;
    MangaInfoBottomBar mangaInfoBottomBar;
    bool loadOver = false;
    switch (loading) {
      case _MangaInfoPageStatus.over:
        {
          mangaInfoIntro = MangaInfoIntro(intro: introduce);
          mangaInfoChapter = MangaInfoChapter(
            chapterList: chapterList,
            readStatus: readMangaStatus,
            onClickChapter: (chapter) => enjoyMangaContent(chapter),
          );
          loadOver = true;
          mangaInfoBottomBar = MangaInfoBottomBar(
            onResume: () => onResumeProcess(),
            readed: readMangaStatus.readChapterId != null,
            collected: readMangaStatus.collected,
            onCollect: () => collectManga(),
          );
          break;
        }
      case _MangaInfoPageStatus.error:
        {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(color: Colors.black45),
              elevation: 0,
              backgroundColor: Color(0xfffafafa),
            ),
            body: ErrorPage("读取漫画信息发生了错误呢~~~", onTap: () {
              debugPrint('error page on tap');
            }),
          );
        }
      case _MangaInfoPageStatus.loading:
        {
          mangaInfoIntro = MangaInfoIntroSkeleton();
          mangaInfoChapter = SkeletonMangaChapterGrid(colCount: 6);
          break;
        }
      default:
        {}
    }
    return Scaffold(
        body: MangaInfoWrapper(
      title: readMangaStatus?.title ?? '',
      appbarActions: <Widget>[
        IconButton(
          icon: Icon(Icons.share, color: Colors.white),
          onPressed: () {
            MaxgaUtils.shareUrl(readMangaStatus.infoUrl);
          },
        )
      ],
      children: [
        MangaInfoCover(
          manga: readMangaStatus,
          loadEnd: loadOver,
          source: source,
          coverImageBuilder: widget.coverImageBuilder,
        ),
        mangaInfoIntro,
        mangaInfoChapter ?? Container(),
      ],
      bottomBar: mangaInfoBottomBar ?? Container(),
    ));
  }

  Row buildChapterLoading() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Padding(
        padding: EdgeInsets.only(top: 60),
        child: SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      )
    ]);
  }

  Widget buildLoadPage() {
    return Container(
      height: 300,
      child: Center(
        child: SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  void _initInfo(
      {@required String sourceKey,
      @required String url,
      ReadMangaStatus Function(
              Manga responseManga, ReadMangaStatus previousStatus)
          filter}) async {
    MaxgaDataHttpRepo repo =
        MangaRepoPool.getInstance().getRepo(key: sourceKey);
    await Future.wait<dynamic>([
      Future.microtask(() async {
        try {
          final manga = await repo.getMangaInfo(url);
          introduce = manga.introduce;
          readMangaStatus = await MangaReadStorageService.getMangaStatus(manga);
          if (manga.chapterList.length !=
              readMangaStatus.chapterList.length) {
            readMangaStatus.chapterList = manga.chapterList
              ..forEach((item) {
                final isExist = readMangaStatus.chapterList.indexWhere(
                        (chapter) => chapter.title == item.title) !=
                    -1;
                item.isCollectionLatestUpdate = !isExist;
              });
          }
          readMangaStatus =
          filter != null ? filter(manga, readMangaStatus) : readMangaStatus;
          chapterList = readMangaStatus.chapterList;
          loading = _MangaInfoPageStatus.over;
        } catch (e) {
          loading = _MangaInfoPageStatus.error;
        }
      }),
      Future.delayed(Duration(milliseconds: 500))
    ]);
    if (mounted) {
      setState(() {});
    }
  }

  void initMangaInfoForCollection() {}

  void initMangaInfo() async {
    MaxgaDataHttpRepo repo =
        MangaRepoPool.getInstance().getRepo(key: widget.sourceKey);
    await Future.wait<dynamic>([
      Future.microtask(() async {
        try {
          final manga = await repo.getMangaInfo(widget.infoUrl);
          introduce = manga.introduce;
          readMangaStatus = await MangaReadStorageService.getMangaStatus(manga);
          if (manga.chapterList.length != readMangaStatus.chapterList.length &&
              widget.manga != null) {
            readMangaStatus.chapterList = manga.chapterList
              ..forEach((item) {
                final isExist = readMangaStatus.chapterList
                        .indexWhere((chapter) => chapter.title == item.title) !=
                    -1;
                item.isCollectionLatestUpdate = !isExist;
              });
          }
          chapterList = readMangaStatus.chapterList;
          loading = _MangaInfoPageStatus.over;
        } catch (e) {
          loading = _MangaInfoPageStatus.error;
        }
      }),
      Future.delayed(Duration(milliseconds: 500))
    ]);
    if (mounted) {
      setState(() {});
    }
  }

  void enjoyMangaContent(Chapter chapter, {int imagePage = 0}) async {
    var result = await Navigator.push<MangaViewerPopResult>(
        context,
        MaterialPageRoute(
            builder: (context) => MangaViewer(
                  manga: readMangaStatus,
                  currentChapter: chapter,
                  chapterList: chapterList,
                  initIndex: imagePage,
                )));
    if (result.loadOver) {
      readMangaStatus.readChapterId = result.chapterId;
      readMangaStatus.readImageIndex = result.mangaImageIndex;
      await Future.wait([
        MangaReadStorageService.setMangaStatus(readMangaStatus),
        Provider.of<HistoryProvider>(context).addToHistory(readMangaStatus),
      ]);
      if (mounted) setState(() {});
    }
    MaxgaUtils.showStatusBar();
  }

  onResumeProcess() {
    if (readMangaStatus.readChapterId != null) {
      var chapter = chapterList
          .firstWhere((item) => item.id == readMangaStatus.readChapterId);
      this.enjoyMangaContent(chapter,
          imagePage: readMangaStatus.readImageIndex);
    } else {
      var chapter = getFirstChapter();
      this.enjoyMangaContent(chapter, imagePage: 0);
    }
  }

  Chapter getLatestChapter() {
    Chapter latestChapter;
    for (var chapter in chapterList) {
      if (latestChapter == null || latestChapter.order < chapter.order) {
        latestChapter = chapter;
      }
    }
    return latestChapter;
  }

  Chapter getFirstChapter() {
    Chapter firstChapter;
    for (var chapter in chapterList) {
      if (firstChapter == null || firstChapter.order > chapter.order) {
        firstChapter = chapter;
      }
    }
    return firstChapter;
  }

  collectManga() async {
    readMangaStatus.collected = !readMangaStatus.collected;
    await MangaReadStorageService.setMangaStatus(readMangaStatus);
    if (mounted) setState(() {});
  }
}
