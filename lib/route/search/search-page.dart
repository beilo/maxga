import 'dart:async';


import 'package:flutter/material.dart';
import 'package:maxga/http/repo/dmzj/DmzjDataRepo.dart';
import 'package:maxga/route/search/search-result-page.dart';
import 'package:maxga/service/LocalStorage.service.dart';

typedef SearchListTileOnClick = void Function(String words);

enum SearchStep { beforeInput, onInput, inputOver, searchStart }

class SearchPage extends StatefulWidget {
  final String name = 'search_page';

  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchInputController = TextEditingController();

  SearchStep searchStatus = SearchStep.beforeInput;

  List<String> suggestionList = [];

  List<String> historySearchWords = [];

  bool hasWords;

  @override
  void initState() {
    super.initState();
    this.getHistorySearchList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.black54,
        ),
        title: buildTextField(),
        backgroundColor: Colors.white,
      ),
      body: buildSearchBody(),
      floatingActionButton: this.hasWords == true
          ? FloatingActionButton(
              onPressed: () =>
                  this.toSearch(this.searchInputController.value.text),
              child: Icon(
                Icons.search,
                color: Colors.black54,
              ),
              backgroundColor: Colors.white,
            )
          : Container(),
    );
  }

  Widget buildTextField() {
    return TextField(
      controller: searchInputController,
      onChanged: (words) => this.inputChange(words),
      onEditingComplete: () =>
          this.toSearch(this.searchInputController.value.text),
      decoration: InputDecoration(
        hintText: '漫画名称、作者名字',
        hintStyle: TextStyle(color: Colors.black54),
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
      ),
    );
  }

  Widget buildSearchBody() {
    switch (searchStatus) {
      case SearchStep.onInput:
      case SearchStep.searchStart:
        return this.buildLoadingPage();
      case SearchStep.inputOver:
        return this.buildSearchList();
        break;

      case SearchStep.beforeInput:
      default:
        return this.buildHistorySearchList();
        break;
    }
  }

  Widget buildLoadingPage() {
    return Center(
      child: SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget buildSearchList() {
    final list = this.suggestionList;
    return ListView(
      children: list
          .map((item) => ListTile(
                leading: Icon(Icons.search),
                title: Text(
                  item,
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () => toSearch(item),
              ))
          .toList(),
    );
  }

  void toSearch(String words) async {
    this.goResultPage(words);

    List<String> historyList = this.historySearchWords.toList();
    historyList.removeWhere((item) => item == words);
    historyList = [words, ...historyList];
    await LocalStorage.setStringList('searchHistory', historyList);
    this.historySearchWords = historyList;
  }

  void getSuggestionAction(String words) async {
    DmzjDataRepo dmzjDataRepo = DmzjDataRepo();
    this.suggestionList = await dmzjDataRepo.getSuggestion(words);
    setState(() {
      this.searchStatus = SearchStep.inputOver;
    });
  }

  Timer _debounce;

  void inputChange(String words) {
    if (words.length != 0) {
      this.hasWords = true;

      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        this.getSuggestionAction(words);
      });
    } else {
      this.hasWords = false;
    }

    setState(() {});
  }

  void getHistorySearchList() async {
    this.historySearchWords =
        await LocalStorage.getStringList('searchHistory') ?? [];
    setState(() {});
  }

  Widget buildHistorySearchList() {
    final list = this.historySearchWords;
    var historyListTiles = list
        .map((item) => ListTile(
              title: Text(item),
              onTap: () => toSearch(item),
              leading: Icon(Icons.history),
            ))
        .toList();
    return ListView(
      children: historyListTiles,
    );
  }

  void goResultPage(String keywords) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return SearchResultPage(
        keyword: keywords,
      );
    }));
  }
}
