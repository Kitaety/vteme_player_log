import 'package:vteme_player_log/data/player.dart';

class ParserQRCode {
  static Player parse(String code) {
    print("parse code");
    code = code.replaceFirst("BEGIN:VCARD\nN:", "");
    code = code.replaceFirst("\nTITLE:", ";");
    code = code.replaceFirst("END:VCARD", "");

    print(code);

    List<String> argPlayer = code.split(';');

    return new Player(argPlayer[1], argPlayer[0], argPlayer[2]);
  }
}
