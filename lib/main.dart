import 'package:flutter/material.dart';
import 'package:vteme_player_log/qr_scanner_screen.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: QRScannerScreen());
  }
}
