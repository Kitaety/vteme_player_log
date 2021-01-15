import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vteme_player_log/main_screen.dart';
import 'package:vteme_player_log/util/parser_qr_code.dart';
import 'package:vteme_player_log/util/web_service.dart';

import 'data/player.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  BuildContext _context;

  @override
  Widget build(BuildContext context) {
    this._context = context;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(8),
                  child: IconButton(
                      onPressed: () async {
                        await controller?.toggleFlash();
                        setState(() {});
                      },
                      icon: FutureBuilder(
                        future: controller?.getFlashStatus(),
                        builder: (context, snapshot) {
                          return Icon(
                            snapshot.data != null
                                ? snapshot.data
                                    ? Icons.flash_on
                                    : Icons.flash_off
                                : Icons.flash_off,
                            color: Colors.white,
                          );
                        },
                      )),
                ),
                Container(
                  margin: EdgeInsets.all(8),
                  child: IconButton(
                    color: Colors.white,
                    onPressed: () async {
                      await controller?.flipCamera();
                      setState(() {});
                    },
                    icon: Icon(Icons.cached),
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 5, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                child: MaterialButton(
                  onPressed: () async {
                    await controller.pauseCamera();
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen()),
                    );
                    controller.resumeCamera();
                  },
                  child: Text(
                    "Список",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = min(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height) -
        100;
    return QRView(
      key: qrKey,
      cameraFacing: CameraFacing.front,
      onQRViewCreated: _onQRViewCreated,
      formatsAllowed: [BarcodeFormat.qrcode],
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      await this.controller.pauseCamera();
      print(scanData.code);
      Player player = ParserQRCode.parse(scanData.code);
      bool isAddPlayer = await _showDialoge(this._context, player);

      if (isAddPlayer) {
        WebService.addPlayerNowDate(player);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Игрок добавлен"),
        ));
      }

      await this.controller.resumeCamera();
    });
  }

  //
  Future<bool> _showDialoge(BuildContext context, Player player) async {
    return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Информация о игроке"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${player.name} ${player.nickName}",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  Container(
                    height: 10,
                  ),
                  Text(
                    "${player.status}",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
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
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            ));
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
