import 'package:flutter/material.dart';
import '../staticVariables.dart';
import 'package:password_manager/models/personalInfo.dart';
import 'package:sqflite/sqflite.dart';
import '../models/pwdContext.dart';
import '../models/website.dart';
import '../models/rowState.dart';

class WebsiteInfo extends StatefulWidget{
  WebsiteInfo({required this.website}) : super();

  final Website website;


  @override
  _WebsiteInfo createState() => _WebsiteInfo(website:this.website);
}

class _WebsiteInfo extends State<WebsiteInfo> {

  _WebsiteInfo({required this.website}) : super();

  final Website website;

  late Future<List<PersonalInfo>> personalInfosF;

  TextEditingController textController = TextEditingController();

  Future<List<PersonalInfo>> _getPersonalInfos() async {
    return getPersonalInfosByWebsiteId(this.website.websiteId);
  }

  @override
  void initState() {
    super.initState();
    this.personalInfosF = _getPersonalInfos();
  }

  @override
  void dispose() {
    super.dispose();
    this.textController.dispose();
    personalInfos = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.website.websiteName),
        actions: <Widget>[
          PopupMenuButton(
            icon: Icon(Icons.menu),
            itemBuilder: (context) {
              List<PopupMenuItem> items = [];
              var save = PopupMenuItem(
                value: 0,
                child: Text('儲存'),
              );
              items.add(save);
              var refresh = PopupMenuItem(
                value: 1,
                child: Text('重新整理'),
              );
              items.add(refresh);
              return items;
            },
            onSelected: (selected) async {
              switch (selected) {
                case 0:
                  this.personalInfosF = savePersonalInfos(
                      this.website, personalInfos);
                  setState(() {});
                  break;
                case 1:
                  this.personalInfosF = getPersonalInfosByWebsiteId(
                      this.website.websiteId);
                  setState(() {});
                  break;
              }
            },
          ),
        ],
      ),
      body: FutureBuilder(
          future: this.personalInfosF,
          builder: (BuildContext context,
              AsyncSnapshot<List<PersonalInfo>> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/loading.gif"),
                  ),
                ),
              );
            } else {
              personalInfos = snapshot.data!;
              return _buildInfoList(snapshot.data!);
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var newInfo = new PersonalInfo(-1, this.website.websiteId, "InfoType"
              , "InfoValue", 0);
          newInfo.rowState = RowState.added;
          personalInfos.add(newInfo);
          setState(() {});
        },
        tooltip: '新增資訊',
        child: Icon(Icons.add),
      ),
    );
  }

  _buildInfoList(List<PersonalInfo> infos) {
    return Column(
      children: <Widget>[
        Container(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(child: Text('帳號資訊'),),
                Card(
                  child: ListTile(
                    leading: Text('帳號: '),
                    title: SelectableText(website.account),
                    trailing: GestureDetector(
                      child: Icon(Icons.edit),
                      onTap: () {
                        _editAccountOrPassword(
                            context, website, AccountOrPassword.account);
                      },
                    ),
                  ),

                ),
                Card(
                  child: ListTile(
                    leading: Text('密碼: '),
                    title: SelectableText(website.password),
                    trailing: GestureDetector(
                      child: Icon(Icons.edit),
                      onTap: () {
                        _editAccountOrPassword(
                            context, website, AccountOrPassword.password);
                      },
                    ),
                  ),
                ),
              ]
          ),
        ),
        Center(child: Text('個人資料'),),
        Container(
          child: Expanded(
            child: ReorderableListView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 80.0),
              children: _reorderableListView(context, infos),
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final PersonalInfo info = infos.removeAt(oldIndex);
                  infos.insert(newIndex, info);
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _editAccountOrPassword(BuildContext context,
      Website w, AccountOrPassword aop) async {
    String originalText = "";
    if (aop == AccountOrPassword.account) {
      originalText = w.account;
    } else {
      originalText = w.password;
    }
    this.textController = new TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('更改帳號'),
            content: TextField(
              decoration: InputDecoration(hintText: "$originalText"),
              controller: this.textController,
            ),
            actions: <Widget>[
              TextButton(
                  child: Text('確定'),
                  onPressed: () {
                    if (aop == AccountOrPassword.account) {
                      w.account = this.textController.text;
                    } else {
                      w.password = this.textController.text;
                    }
                    this.textController = new TextEditingController();
                    Navigator.pop(context);
                    this.setState(() {});
                  }
              ),
              TextButton(
                  child: Text('取消'),
                  onPressed: () {
                    this.textController = new TextEditingController();
                    Navigator.pop(context);
                  }
              ),
            ],
          );
        });
  }

  List<Widget> _reorderableListView(BuildContext context,
      List<PersonalInfo> infos) {
    List<Widget> tiles = [];

    for (var i = 0; i < infos.length; i++) {
      if (infos[i].rowState == RowState.deleted ||
          infos[i].rowState == RowState.detached) {
        continue;
      }
      var c = new Card(
        key: UniqueKey(),
        child: ListTile(
          key: UniqueKey(),
          leading: Text(infos[i].infoType + ':'),
          title: Text(infos[i].infoValue),
          trailing: PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) {
              List<PopupMenuItem> items = [];
              var rename = PopupMenuItem(
                value: 0,
                child: Text('修改欄位'),
              );
              items.add(rename);
              var edit = PopupMenuItem(
                value: 1,
                child: Text('修改資料'),
              );
              items.add(edit);
              var del = PopupMenuItem(
                value: 2,
                child: Text('刪除資料'),
              );
              items.add(del);
              return items;
            },
            onSelected: (value) {
              switch (value) {
                case 0:
                  this._editInfoTypeOrInfoValue(context, infos[i], InfoTypeOrInfoValue.infoType);
                  break;
                case 1:
                  this._editInfoTypeOrInfoValue(context, infos[i], InfoTypeOrInfoValue.infoValue);
                  break;
                case 2:
                  infos[i].rowState = RowState.deleted;
                  setState((){ });
                  break;
              }
            },
          ),
        ),
      );
      tiles.add(c);
    }

    return tiles;
  }

  Future<void> _editInfoTypeOrInfoValue(BuildContext context, PersonalInfo info
      , InfoTypeOrInfoValue tov) async{
    String editingTov = "";
    String originalText = "";
    if (tov == InfoTypeOrInfoValue.infoType){
      originalText = info.infoType;
      editingTov = "資料欄位";
    }else{
      originalText = info.infoValue;
      editingTov = "個人資料";
    }
    this.textController = new TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('修改$editingTov'),
          content: TextField(
            decoration: InputDecoration(hintText: "$originalText"),
            controller: this.textController,
          ),
          actions: <Widget>[
            TextButton(
                child:Text('確定'),
                onPressed: (){
                  if (tov == InfoTypeOrInfoValue.infoType){
                    info.infoType = this.textController.text;
                  }else{
                    info.infoValue = this.textController.text;
                  }
                  this.textController = new TextEditingController();
                  Navigator.pop(context);
                  this.setState((){ });
                }
            ),
            TextButton(
                child:Text('取消'),
                onPressed:(){
                  this.textController = new TextEditingController();
                  Navigator.pop(context);
                }
            ),
          ],
        );
      });
  }


}

enum AccountOrPassword{
  account, password
}

enum InfoTypeOrInfoValue{
  infoType, infoValue
}
