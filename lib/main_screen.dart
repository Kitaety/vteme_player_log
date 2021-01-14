import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vteme_player_log/qr_view.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    String code = "code";

    return Scaffold(
      appBar: AppBar(
        title: Text("Test"),
        actions: [IconButton(icon: Icon(Icons.camera), onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QRViewExample()),
          );
          setState(() {
            code = result.toString();
          });
        })],
      ),
      body: Center(
        child: Text(code
        ),
      ),
    );
  }
}
