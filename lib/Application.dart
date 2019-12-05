
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/http/repo/manhuadui/ManhuaduiDataRepo.dart';
import 'package:maxga/model/MangaSource.dart';

import 'http/repo/dmzj/DmzjDataRepo.dart';
import 'http/repo/hanhan/HanhanDataRepo.dart';
import 'http/repo/manhuagui/ManhuaguiDataRepo.dart';

class Application {
  static Application _application = Application();

  static Application getInstance() => Application._application;

  MangaRepoPool _mangaRepoPool = MangaRepoPool();
  MangaSource _currentSource;

  Application() {
    final manhuaduiDataRepo = ManhuaduiDataRepo();
    final dmzjDataRepo = DmzjDataRepo();
    final hanhanDateRepo = HanhanDateRepo();
    final manhuaguiDateRepo = ManhuaguiDataRepo();
    _mangaRepoPool.registryRepo(manhuaduiDataRepo);
    _mangaRepoPool.registryRepo(manhuaguiDateRepo);
    _mangaRepoPool.registryRepo(dmzjDataRepo);
    _mangaRepoPool.registryRepo(hanhanDateRepo);
    _currentSource = dmzjDataRepo.mangaSource;
  }

  void changeMangaSource(MangaSource source) {
    _currentSource = source;
  }

  MaxgaDataHttpRepo getMangaSource({String key}) {
    if (key != null) {
      return _mangaRepoPool.getRepo(key: key);
    } else {
      return _mangaRepoPool.getRepo(source: _currentSource);
    }
  }
  List<MaxgaDataHttpRepo> get allDataRepo => _mangaRepoPool.getAllRepo();
  List<MangaSource> get allDataSource => _mangaRepoPool.getAllSource();
}


class MangaRepoPool {
  Map<String, MaxgaDataHttpRepo> _map = {};

  registryRepo(MaxgaDataHttpRepo repo) {
    _map.addAll({repo.mangaSource.key: repo});
  }

  getRepo({MangaSource source, String key}) {
    if (key != null) {
      return _map[key];
    }

    if (source != null) {
      return _map[source.key];
    }

    throw Error();
  }


  List<MaxgaDataHttpRepo> getAllRepo() {
    return _map.values.toList(growable: false);
  }

  List<MangaSource> getAllSource() {
    return _map.values.map((el) => el.mangaSource).toList(growable: false);
  }
}
