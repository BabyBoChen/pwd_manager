import 'package:flutter/material.dart';
import 'package:password_manager/models/rowState.dart';
import 'package:password_manager/models/website.dart';
import 'package:password_manager/pages/websiteInfo.dart';



class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Website> viewModels = [];
  TextEditingController textController = TextEditingController();

  void _addWebsite() {
    var newId = DateTime.now().millisecondsSinceEpoch;
    var w = new Website(newId, "untitled", "account", "password", this.viewModels.length);
    w.rowState = RowState.added;
    websites.add(w);
    this.viewModels.add(w);
    this.setState(() {});
  }

  void _deleteWebsite(Website w){
    if (w.rowState == RowState.added){
      w.rowState = RowState.detached;
    }else if (w.rowState == RowState.unchanged ||
        w.rowState == RowState.modified){
      w.rowState = RowState.deleted;
    }
    this.viewModels.remove(w);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    for(var i = 0; i < websites.length; i++){
      this.viewModels.add(websites[i]);
    }
  }

  @override
  void dispose() {
    this.textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child:Text(widget.title)
        ),
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
              var export = PopupMenuItem(
                value: 2,
                child: Text('匯出檔案'),
              );
              items.add(export);
              var importDB = PopupMenuItem(
                value: 3,
                child: Text('匯入檔案'),
              );
              items.add(importDB);
              var setPin = PopupMenuItem(
                value: 4,
                child: Text('設定PIN碼'),
              );
              items.add(setPin);
              return items;
            },
            onSelected: (selected) async{
              switch(selected){
                case 0:
                  if(!token.isLogin || token.isExpired()){
                    token.isLogin = false;
                    await this._displayLoginDialog(context);
                  }
                  if(!token.isLogin) return;
                  var newWebsites = await saveWebsites(this.viewModels);
                  setState(() {
                    websites = newWebsites;
                    this.viewModels.clear();
                    for(var i = 0; i < websites.length; i++){
                      this.viewModels.add(websites[i]);
                    }
                  });
                  break;
                case 1:
                  var newWebsites = await getAllWebsites();
                  setState(() {
                    websites = newWebsites;
                    this.viewModels.clear();
                    for(var i = 0; i < websites.length; i++){
                      this.viewModels.add(websites[i]);
                    }
                  });
                  break;
                case 2:
                  token.isLogin = false;
                  await _displayLoginDialog(context);
                  if (token.isLogin == false){
                    return;
                  }
                  String filename = await exportDB();
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('匯出成功！'),
                        content: SingleChildScrollView(
                          child: Text('檔案名稱：$filename'),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('確定'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  var newWebsites = await getAllWebsites();
                  setState(() {
                    websites = newWebsites;
                    this.viewModels.clear();
                    for(var i = 0; i < websites.length; i++){
                      this.viewModels.add(websites[i]);
                    }
                  });
                  break;
                case 3:
                  token.isLogin = false;
                  await _displayLoginDialog(context);
                  if (token.isLogin == false){
                    return;
                  }
                  String resultMsg = await importDB(context);
                  var newWebsites = await getAllWebsites();
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(resultMsg),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('確定'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  setState(() {
                    websites = newWebsites;
                    this.viewModels.clear();
                    for(var i = 0; i < websites.length; i++){
                      this.viewModels.add(websites[i]);
                    }
                  });
                  break;
                case 4:
                  token.isLogin = false;
                  await _displayLoginDialog(context);
                  if (token.isLogin == false){
                    return;
                  }
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) =>
                          SetPIN()
                      )
                  );
                  break;
              }
            },
          ),
        ],
      ),
      body: ReorderableListView(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 80.0),
        children:_reorderableListViewBuilder(context, this.viewModels),
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final Website w = this.viewModels.removeAt(oldIndex);
            this.viewModels.insert(newIndex, w);
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWebsite,
        tooltip: '新增帳號',
        child: Icon(Icons.add),
      ),
    );
  }

  List<Widget> _reorderableListViewBuilder(BuildContext context,
      List<Website> ws){
    List<Widget> items = [];
    for(int i = 0; i < ws.length; i++){
      var item = Container(
        key: UniqueKey(),
        child: InkWell(
          child: Card(
            child:ListTile(
              title: Text(ws[i].websiteName),
              trailing: PopupMenuButton(
                icon: Icon(Icons.more_vert),
                itemBuilder: (context) {
                  List<PopupMenuItem> items = [];
                  var rename = PopupMenuItem(
                    value: 0,
                    child: Text('重新命名'),
                  );
                  items.add(rename);
                  var del = PopupMenuItem(
                    value: 1,
                    child: Text('刪除'),
                  );
                  items.add(del);
                  return items;
                },
                onSelected: (value) {
                  switch(value){
                    case 0:
                      this._displayTextInputDialog(context, ws[i]);
                    break;
                    case 1:
                      this._deleteWebsite(ws[i]);
                    break;
                  }
                },
              ),
            ),
          ),
          onTap: () async {
            if(!token.isLogin || token.isExpired()){
              token.isLogin = false;
              await this._displayLoginDialog(context);
            }
            if (!token.isLogin || token.isExpired()){
              return;
            }else{
              print(ws[i]);
              Navigator.push(context,
                MaterialPageRoute(builder: (context) =>
                  WebsiteInfo(website:ws[i])
                )
              );
            }
          }
        ),
      );
      items.add(item);
    }
    return items;
  }

  Future<void> _displayTextInputDialog(BuildContext context, Website w)
  async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('重新命名'),
          content: TextField(
            decoration: InputDecoration(hintText: '${w.websiteName}'),
            controller: this.textController,
          ),
          actions: <Widget>[
            TextButton(
              child:Text('確定'),
              onPressed:(){
                w.websiteName = this.textController.text;
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

  Future<void> _displayLoginDialog(BuildContext context){
    this.textController = new TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('請輸入PIN碼'),
          content: TextField(
            decoration: InputDecoration(hintText: token.hint),
            controller: this.textController,
            obscureText: true,
          ),
          actions: <Widget>[
            TextButton(
                child:Text('確定'),
                onPressed: (){
                  if (this.textController.text == token.pin){
                    token.isLogin = true;
                    token.lastLoginTime = DateTime.now();
                  }else{
                    token.isLogin = false;
                  }
                  this.textController = new TextEditingController();
                  Navigator.pop(context);
                  if(token.isLogin == false){
                    showDialog<void>(
                      context: context,
                      barrierDismissible: false, // user must tap button!
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('解鎖失敗！'),
                          content: SingleChildScrollView(
                            child: Text('請輸入正確的PIN碼'),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('取消'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
            ),
            TextButton(
                child:Text('取消'),
                onPressed:(){
                  this.textController = new TextEditingController();
                  token.isLogin = false;
                  Navigator.pop(context);
                }
            ),
          ],
        );
      }
    );
  }
}