///
//* класс описывающий игрока
//* содержит поля:
// @param name - имя игрока
// nickName - псевдоним игрока
// status - статус игрока в клубе
//
//* методы:
// addDate - запись посещения игрока на определенную дату
// addNowDate - запись посещения игрока на текущий день
///

class Player {
  String _name;
  String _nickName;
  String _status;
  List<DateTime> _dates;

  Player(String name, String nickName, String status) {
    this._name = name;
    this._nickName = nickName;
    this._status = status;
  }

  String get name => _name;
  String get nickName => _nickName;
  String get status => _status;
  List<DateTime> get dates => _dates;

  //TODO доделать запись в бд
  void addDate(DateTime date) {
    _dates.add(date);
  }

  void addNowDate() {
    addDate(DateTime.now());
  }
}
