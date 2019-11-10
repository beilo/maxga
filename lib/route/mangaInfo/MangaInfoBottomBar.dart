import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef OnCollectCallBack = void Function();
typedef OnResumeCallBack = void Function();

class MangaInfoBottomBar extends StatelessWidget {
  final OnCollectCallBack onCollect;
  final OnResumeCallBack onResume;

  const MangaInfoBottomBar({Key key, this.onCollect, this.onResume})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(width: 1, color: Color(0xffeaeaea)))),
      padding: EdgeInsets.only(left: 10, top: 2, bottom: 2, right: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton.icon(
              onPressed: onCollect,
              icon: Icon(Icons.star_border),
              label: const Text('收藏')),
          buildResumeButton()
        ],
      ),
    );
  }

  FlatButton buildResumeButton() {
    return FlatButton(
      onPressed: onResume,
      textColor: Colors.white,
      color: Colors.blueAccent,
      shape:  RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(25.0)
      ),
      child: Text('  继续阅读  '),
    );
  }
}