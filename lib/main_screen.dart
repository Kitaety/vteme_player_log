import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:relation/relation.dart' as r;
import 'calendare_screen.dart';
import 'data/record.dart';
import 'util/web_service.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  BuildContext _context;

  r.StreamedState<String> _title = new r.StreamedState();
  r.StreamedState<DateTime> _dateState = new r.StreamedState<DateTime>();

  r.Action _changeDateAction = new r.Action();

  r.EntityStreamedState<List<Record>> _recordsState =
      new r.EntityStreamedState();

  @override
  void initState() {
    _dateState.accept(DateTime.now());
    _title.accept(DateFormat('dd-MM-yyyy').format(_dateState.value));

    //* смена даты и загрузка нового списка игроков
    this._changeDateAction.stream.listen((_) async {
      DateTime date = await showDatePicker(
          context: context,
          locale: const Locale("ru", "RU"),
          initialDate: _dateState.value,
          firstDate: DateTime(2020),
          lastDate: DateTime(2222),
          builder: (contex, child) {
            return Theme(
              data: Theme.of(context),
              child: child,
            );
          });
      if (date != null) {
        _dateState.accept(date);
        _title.accept(DateFormat('dd-MM-yyyy').format(_dateState.value));
        _recordsState.loading();
        WebService.getListRecordsOnDay(_dateState.value)
            .then((value) => _recordsState.accept(
                  new r.EntityState(
                    data: value,
                  ),
                ));
      }
    });

    _recordsState.loading();
    WebService.getListRecordsOnDay(_dateState.value)
        .then((value) => _recordsState.content(value));

    super.initState();
  }

  @override
  void dispose() {
    _title.dispose();
    _dateState.dispose();
    _changeDateAction.dispose();
    _recordsState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        centerTitle: true,
        title: FlatButton(
          minWidth: 150,
          child: r.StreamedStateBuilder(
            streamedState: _title,
            builder: (context, title) => Text(
              title,
            ),
          ),
          onPressed: _changeDateAction.accept,
        ),
        actions: [
          PopupMenuButton<int>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) async {
              switch (value) {
                case 0:
                  _recordsState.loading();
                  WebService.getListRecords()
                      .then((value) => _recordsState.content(value));
                  _title.accept("Выбор даты");
                  break;
                case 1:
                  _recordsState.loading();
                  await WebService.deleteAllRecords();
                  _recordsState.content(null);
                  break;
                case 2:
                  _recordsState.loading();
                  await WebService.deleteRecordsFromDate(_dateState.value);
                  _recordsState.content(null);
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 0,
                  child: Text("Архив"),
                ),
                PopupMenuItem(
                  value: 1,
                  child: Text("Удалить все"),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Text("Удалить декущую дату"),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.amber,
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
                  child: Center(
                    child: Text(
                      "П/П",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
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
                  child: Center(
                    child: Text(
                      "ИМЯ",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
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
                  child: Center(
                    child: Text(
                      "ИГРОВОЙ НИК",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            child: r.EntityStateBuilder<List<Record>>(
              streamedState: _recordsState,
              child: (contetx, List<Record> record) => ListView.builder(
                  itemCount: record.length,
                  itemExtent: 50,
                  itemBuilder: (context, index) {
                    print(record[index].nickName);
                    return createListItem("${index + 1}", record[index]);
                  }),
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

  Widget createListItem(String index, Record record) {
    print(record.isColor);
    return Dismissible(
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete_forever),
      ),
      key: Key(record.name + ' ' + record.nickName),
      onDismissed: (direction) async {
        await WebService.deleteRecordsFromId(record);
        List<Record> records = _recordsState.value.data;
        records.remove(record);
        _recordsState.content(records);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("${record.name} ${record.nickName} удален"),
        ));
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black87)),
          color: record.isColor
              ? getColorOnPlayerStatus(record.status)
              : Colors.white,
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
                child: Text(record.name),
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
                child: Text(record.nickName),
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
                    onPressed: () => showCalendar(record),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showCalendar(Record record) {
    Navigator.of(_context).push(
      MaterialPageRoute(
        builder: (context) => CalendareScreen(record: record),
      ),
    );
  }

  Color getColorOnPlayerStatus(PlayerStatus status) {
    switch (status) {
      case PlayerStatus.Anonim:
        return Colors.red;
      case PlayerStatus.Quest:
        return Colors.yellow;
      case PlayerStatus.Friend:
        return Colors.green;
      default:
        return Colors.white;
    }
  }
}
