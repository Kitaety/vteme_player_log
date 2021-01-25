import 'dart:io';

import 'package:flutter/material.dart';
import 'package:relation/relation.dart';
import 'package:table_calendar/table_calendar.dart';
import 'data/record.dart';
import 'util/web_service.dart';

class CalendareScreen extends StatefulWidget {
  final Record record;

  CalendareScreen({Key key, @required this.record}) : super(key: key);

  @override
  _CalendareScreenState createState() => _CalendareScreenState();
}

class _CalendareScreenState extends State<CalendareScreen> {
  Map<DateTime, List> _events = Map();
  CalendarController _calendarController;

  StreamedState<int> _countVisitsOnMonth = StreamedState();

  @override
  void initState() {
    super.initState();
    WebService.getDateRecord(widget.record).then((value) {
      int countVisits = 0;

      for (final date in value) {
        setState(() {
          _events[date] = ['q'];
        });
        if (date.month == DateTime.now().month) countVisits++;
      }

      _countVisitsOnMonth.accept(countVisits);
    });

    _calendarController = CalendarController();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    int countVisits = 0;
    WebService.getDateRecord(widget.record).then((value) {
      for (final date in value) {
        if (date.month == first.month) countVisits++;
      }
      _countVisitsOnMonth.accept(countVisits);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text(
          "${widget.record.name} ${widget.record.nickName}",
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          SizedBox(
            height: 350,
            child: _buildTableCalendar(),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            alignment: Alignment.centerLeft,
            child: Text(
              '${widget.record.name} ${widget.record.nickName}',
              style: TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(Record.getStatus(widget.record.status)),
                ]),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Кол-во посещенийв месяце"),
                  StreamedStateBuilder(
                    streamedState: _countVisitsOnMonth,
                    builder: (context, count) => Text(count.toString()),
                  ),
                ]),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Всего посещений"),
                  Text(_events.length.toString()),
                ]),
          )
        ],
      ),
    );
  }

  // Simple TableCalendar configuration (using Styles)
  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      events: _events,
      startingDayOfWeek: StartingDayOfWeek.monday,
      initialCalendarFormat: CalendarFormat.month,
      availableCalendarFormats: {CalendarFormat.month: ""},
      locale: Platform.localeName,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.deepOrange[400],
        todayColor: Colors.deepOrange[200],
        markersColor: Colors.brown[700],
        outsideDaysVisible: false,
      ),
      initialSelectedDay: DateTime.now(),
      headerStyle: HeaderStyle(
        formatButtonTextStyle:
            TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.deepOrange[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onDaySelected: (day, events, holidays) {
        _calendarController.setSelectedDay(DateTime.now());
      },
    );
  }
}
