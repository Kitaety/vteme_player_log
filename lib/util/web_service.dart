import 'package:vteme_player_log/data/player.dart';

class WebService {
  //TODO получить список игроков на выбранный день
  static List<Player> getListPlayersOnDay(DateTime date) {
    List<Player> players = {
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
    }.toList();

    return players;
  }

  //TODO получить список игроков
  static List<Player> getListPlayers(DateTime date) {
    List<Player> players = {
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
      new Player("1", "2", "3"),
    }.toList();

    return players;
  }

  static bool addPlayerNowDate(Player player) {
    //TODO добавление игрока на текущую дату в бд
    player.addNowDate();
    return true;
  }
}
