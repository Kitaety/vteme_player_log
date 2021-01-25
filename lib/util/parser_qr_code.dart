import 'package:simple_vcard_parser/simple_vcard_parser.dart';
import 'package:vteme_player_log/data/record.dart';

class ParserQRCode {
  static Record parse(String code) {
    print("parse code:");
    print(code);

    VCard vc = VCard(code);

    PlayerStatus status;
    String statusStr = vc.title.toLowerCase();

    if (statusStr == 'друг клуба') {
      status = PlayerStatus.Friend;
    } else if (statusStr == 'гость') {
      status = PlayerStatus.Quest;
    } else {
      status = PlayerStatus.Anonim;
    }

    return new Record(
        name: vc.name[1], nickName: vc.name[0], status: status.index);
  }
}
