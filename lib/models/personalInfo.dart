import 'package:password_manager/models/rowState.dart';

class PersonalInfo {
  final int personalInfoId;
  final int websiteId;
  String _infoType;
  String _infoValue;
  int _lineOrder;
  RowState rowState = RowState.unchanged;

  PersonalInfo(this.personalInfoId, this.websiteId, this._infoType,
      this._infoValue, this._lineOrder);

  String get infoType {
    return this._infoType;
  }

  set infoType(String value){
    if (this.rowState == RowState.unchanged){
      this.rowState = RowState.modified;
    }
    this._infoType = value;
  }

  String get infoValue {
    return this._infoValue;
  }

  set infoValue(String value){
    if (this.rowState == RowState.unchanged){
      this.rowState = RowState.modified;
    }
    this._infoValue = value;
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
    return 'PersonalInfo{PersonalInfoId: $personalInfoId, WebsiteId: $websiteId, '
        'InfoType: $_infoType, InfoValue: $_infoValue, LineOrder: $_lineOrder,'
        'RowState: $rowState}';
  }
}
