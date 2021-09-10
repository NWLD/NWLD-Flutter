class TalkingData {
  String address;
  int time;
  String msg;
  String nick;

  TalkingData({this.address, this.time, this.msg, this.nick});
}

class TalkingDataList {
  List<TalkingData> list;
  BigInt lastIndex;

  TalkingDataList({this.list, this.lastIndex});
}
