import 'package:flutter/material.dart';
import 'qr_scanner_with_audio_page.dart'; // Passe diesen Import an, falls die Datei anders heißt.

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR-Code Scanner mit Audio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QRScannerWithAudioPage(),
    );
  }
}
