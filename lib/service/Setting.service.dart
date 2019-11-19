import 'dart:convert';

import 'package:maxga/base/setting/Setting.model.dart';
import 'package:maxga/base/setting/SettingValue.dart';

import 'LocalStorage.service.dart';

class SettingService {
  static String _key = 'Setting_Value';

  static Future<List<MaxgaSettingItem>> getInitValue() async {
    final List<MaxgaSettingItem> settingList = [];

    for (var item in SettingItemList) {
      final settingItem = MaxgaSettingItem.copy(item);
      final value = await LocalStorage.getString('$_key${item.name}');
      settingItem.setValue(value);
      settingList.add(settingItem);
    }
    return settingList;
  }

  static Future<bool> saveItem(String name, String value) {
    return LocalStorage.setString('$_key$name', value);
  }
}
