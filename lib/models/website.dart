import 'package:password_manager/models/rowState.dart';

class Website {
  int websiteId;
  String _websiteName;
  String _account;
  String _password;
  int _lineOrder = 0;
  RowState rowState = RowState.unchanged;


  Website(this.websiteId, this._websiteName, this._account, this._password,
      this._lineOrder);

  String get websiteName{
    return this._websiteName;
  }

  set websiteName (String value){
    if (this.rowState == RowState.unchanged){
      this.rowState = RowState.modified;
    }
    this._websiteName = value;
  }

  String get account{
    return this._account;
  }

  set account (String value){
    if (this.rowState == RowState.unchanged){
      this.rowState = RowState.modified;
    }
    this._account = value;
  }

  String get password{
    return this._password;
  }

  set password (String value){
    if (this.rowState == RowState.unchanged){
      this.rowState = RowState.modified;
    }
    this._password = value;
  }

  int get lineOrder {
    return this._lineOrder;
  }

  set lineOrder(int value){
    if (this.rowState == RowState.unchanged){
      this.rowState = RowState.modified;
    }
    this._lineOrder = value;
  }

  @override
  String toString() {
    return 'Website{WebsiteId: $websiteId, WebsiteName: $websiteName, '
        'Account: $account, Password: $password, LineOrder: $lineOrder, '
        'RowState: $rowState}';
  }
}
