import 'package:vteme_player_log/data/record.dart';

class Package {
  bool error;
  List<Record> data;

  Package({this.error, this.data});

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      error: json['error'] as bool,
      data: (json['data'] as List).map((e) => Record.fromJson(e)).toList(),
    );
  }
}
