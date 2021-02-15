import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';
import 'package:vteme_player_log/main_screen.dart';
import 'package:vteme_player_log/util/parser_qr_code.dart';
import 'package:vteme_player_log/util/web_service.dart';

import 'data/record.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  BuildContext _context;
  bool isCam = false;
  bool isProccesAdd = false;

  _qrCallback(String code) async {
    setState(() {
      isCam = true;
    });
    print(code);
    Record record = ParserQRCode.parse(code);
    bool isAddPlayer = await _showDialoge(this._context, record);

    if (isAddPlayer) {
      await WebService.addRecordNowDate(record).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(value ? "Игрок добавлен" : "Не удалось добавить игрока"),
        ));
        if (value) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        }
      }).catchError((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Ошибка сети"),
        ));
      });
    }
    isCam = false;
  }

  @override
  Widget build(BuildContext context) {
    this._context = context;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "VTEME Журнал посещения",
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(flex: 5, child: _buildQrView(context)),
            Expanded(
              flex: 1,
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.black,
                child: Center(
                  child: Container(
                    width: 120,
                    height: 45,
                    child: FlatButton(
                      height: 50,
                      color: Theme.of(context).accentColor,
                      onPressed: () async {
                        isCam = true;
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MainScreen()),
                        );
                        isCam = false;
                      },
                      child: Text(
                        "Список",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = min(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height) -
        100;

    return QRBarScannerCamera(
        onError: (context, error) => Text(
              error.toString(),
              style: TextStyle(color: Colors.red),
            ),
        qrCodeCallback: (code) {
          if (!isCam) {
            _qrCallback(code);
          }
        },
        child: Stack(
          children: [
            Center(
              child: Container(
                width: scanArea,
                height: scanArea,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.black54, BlendMode.srcOut),
              child: Stack(
                children: [
                  Container(
                    color: Colors.transparent,
                  ),
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width - 100,
                      height: MediaQuery.of(context).size.width - 100,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  //
  Future<bool> _showDialoge(BuildContext context, Record record) async {
    return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Информация о игроке"),
              content: !isProccesAdd
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "${record.name} ${record.nickName}",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        Container(
                          height: 10,
                        ),
                        Text(
                          Record.getStatus(record.status),
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
              actions: [
                FlatButton(
                  child: Text("Отмена"),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                FlatButton(
                  child: Text("Добавить"),
                  onPressed: () async {
                    setState(() {
                      this.isProccesAdd = true;
                    });
                    bool a = await WebService.checkPlayer(record);
                    if (a)
                      Navigator.of(context).pop(true);
                    else {
                      Navigator.of(context).pop(false);
                      await _showDialogeError(context, record);
                    }
                  },
                ),
              ],
            ));
  }

  Future<void> _showDialogeError(BuildContext context, Record record) async {
    return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Ошибка"),
              content:
                  Text("Игрок ${record.name} ${record.nickName} уже добавлен"),
              actions: [
                FlatButton(
                  child: Text("ОК"),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
