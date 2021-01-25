///
//* класс описывающий игрока
//* содержит поля:
// name - имя игрока
// nickName - псевдоним игрока
// status - статус игрока в клубе
//
//* методы:
// addDate - запись посещения игрока на определенную дату
// addNowDate - запись посещения игрока на текущий день
///

class Record {
  String _name;
  String _nickName;
  PlayerStatus _status;
  DateTime _date;
  bool _isColor;

  Record(
      {String name, String nickName, int status, DateTime date, bool isColor}) {
    this._name = name;
    this._nickName = nickName;
    this._status = PlayerStatus.values[status];
    this._isColor = isColor;
    this._date = date;
  }

  String get name => _name;
  String get nickName => _nickName;
  PlayerStatus get status => _status;
  DateTime get date => _date;
  bool get isColor => _isColor;

  static String getStatus(PlayerStatus status) {
    switch (status) {
      case PlayerStatus.Anonim:
        return "Инкогнито";
      case PlayerStatus.Quest:
        return "Гость клуба";
      case PlayerStatus.Friend:
        return "Друг клуба";
      default:
        return "";
    }
  }

  static PlayerStatus getStatusFromString(String status) {
    return status.toLowerCase() == 'друг клуба'
        ? PlayerStatus.Friend
        : status.toLowerCase() == 'гость'
            ? PlayerStatus.Quest
            : PlayerStatus.Anonim;
  }

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      name: json['name'] as String,
      nickName: json['nickName'] as String,
      status: getStatusFromString((json['rang'] as String)).index,
      isColor: (json['is_color'] as String).toLowerCase() == '1',
      date: json['date']!=null?DateTime.parse((json['date'] as String)):null,
    );
  }
}

enum PlayerStatus {
  Anonim,
  Quest,
  Friend,
}
