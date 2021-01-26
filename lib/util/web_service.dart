import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:vteme_player_log/data/package.dart';
import 'package:vteme_player_log/data/record.dart';

class WebService {
  //TODO получить список игроков на выбранный день
  static Future<List<Record>> getListRecordsOnDay(DateTime date) async {
    DateFormat dateFormated = DateFormat("yyyy-MM-dd");
    try {
      Response response = await Dio().get(
          "https://anika-cs.by/appnew/record/${dateFormated.format(date)}");
      final parsed = jsonDecode(response.data);

      print(parsed);

      Package p = Package.fromJson(parsed);

      print(p.data[0].name);

      List<Record> records = p.data;

      return records;
    } catch (e) {
      print(e);
      return null;
    }
  }

  //TODO получить список игроков
  static Future<List<Record>> getListRecords() async {
    Response response = await Dio()
        .get("https://anika-cs.by/appnew/player");
    final parsed = jsonDecode(response.data);

    print(parsed);

    Package p = Package.fromJson(parsed);

    List<Record> records = p.data;

    return records;
  }

  static Future<bool> addRecordNowDate(Record record) async {
    //TODO добавление игрока на текущую дату в бд
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");

    Response response = await Dio().post(
        "https://anika-cs.by/appnew/record/${record.name}/${record.nickName}/${Record.getStatus(record.status)}/${dateFormat.format(DateTime.now())}");
    final parsed = jsonDecode(response.data);

    print(parsed);

    Package p = Package.fromJson(parsed);

    return !p.error;
  }

  //TODO получить все даты посещения данного игрока
  static Future<List<DateTime>> getDateRecord(Record record) async {
    Response response = await Dio().get(
        "https://anika-cs.by/appnew/player/${record.name}/${record.nickName}");
    final parsed = jsonDecode(response.data);

    print(parsed);

    Package p = Package.fromJson(parsed);

    print(p.data[0].name);

    List<Record> records = p.data;

    List<DateTime> dates = List();

    for (Record record in records) {
      dates.add(record.date);
    }

    return dates;
  }

  static void deleteAllRecords() async{
    await Dio().get(
        "https://anika-cs.by/appnew/record/0");
  }
}
