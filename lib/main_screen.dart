import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:relation/relation.dart' as r;
import 'data/player.dart';
import 'util/web_service.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String code = "code";
  List<Player> _players;
  r.StreamedState<DateTime> _dateState = new r.StreamedState<DateTime>();

  r.Action _changeDateAction = new r.Action();

  r.EntityStreamedState<List<Player>> _playersState =
      new r.EntityStreamedState();

  // DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    _dateState.accept(DateTime.now());

    _playersState.loading();
    this._players = WebService.getListPlayersOnDay(_dateState.value);
    _playersState.content(this._players);

    this._changeDateAction.stream.listen((_) async {
      DateTime date = await showDatePicker(
        context: context,
        initialDate: _dateState.value,
        firstDate: DateTime(2020),
        lastDate: DateTime(2222),
      );
      if (date != null) {
        _dateState.accept(date);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: FlatButton(
          minWidth: 150,
          //TODO смена даты
          child: r.StreamedStateBuilder(
            streamedState: _dateState,
            builder: (context, date) => Text(
              DateFormat('dd-MM-yyyy').format(date),
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          onPressed: _changeDateAction.accept,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.today),
            //TODO загрузка списка всех игроков
            onPressed: () {},
          )
        ],
      ),
      body: Column(children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.amber[900],
            border: Border(
              bottom: BorderSide(color: Colors.black87),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: Colors.black87))),
                  alignment: Alignment.center,
                  child: Text("п/п"),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: Colors.black87))),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 5),
                  child: Text("Имя"),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: Colors.black87))),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 5),
                  child: Text("Псевдоним"),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: Icon(Icons.calendar_today),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            child: r.EntityStateBuilder<List<Player>>(
              streamedState: _playersState,
              child: (contetx, players) => ListView.builder(
                itemCount: players.length,
                itemExtent: 50,
                //TODO окраска в зависимости от статуса
                itemBuilder: (context, index) => createListItem(
                  index: "${index + 1}",
                  name: _playersState.value.data[index].name,
                  nickName: _playersState.value.data[index].nickName,
                  action: () => {
                    //TODO показать календарь с отметками посещения
                  },
                ),
              ),
              loadingChild: Center(
                  child: CircularProgressIndicator(
                backgroundColor: Colors.amber[900],
              )),
            ),
          ),
        ),
      ]),
    );
  }

  Widget createListItem(
      {String index, String name, String nickName, void action}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black87)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.black87)),
              ),
              alignment: Alignment.center,
              child: Text(index),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.black87)),
              ),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 5),
              child: Text(name),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.black87)),
              ),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 5),
              child: Text(nickName),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 50,
              padding: EdgeInsets.only(right: 5),
              child: Center(
                child: IconButton(
                  icon: Icon(Icons.today),
                  onPressed: () => action,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
