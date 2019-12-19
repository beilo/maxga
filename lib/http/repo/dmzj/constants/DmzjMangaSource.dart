import 'package:maxga/model/manga/MangaSource.dart';

// ignore: non_constant_identifier_names
final DmzjMangaSource = MangaSource(
    name: '动漫之家',
    key: 'dmzj',
    domain: 'https://v3api.dmzj.com',
    iconUrl: 'https://www.dmzj.com/favicon.ico',
    headers: {
      'referer': 'http://m.dmzj.com/latest.html',
    });
