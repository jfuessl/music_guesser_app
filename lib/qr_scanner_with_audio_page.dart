import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;

class QRScannerWithAudioPage extends StatefulWidget {
  @override
  _QRScannerWithAudioPageState createState() => _QRScannerWithAudioPageState();
}


class _QRScannerWithAudioPageState extends State<QRScannerWithAudioPage> {
  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio-Player-Instanz
  bool isPlaying = false; // Zum Anzeigen des Audio-Status

  @override
  void dispose() {
    _audioPlayer.dispose(); // AudioPlayer beim Verlassen der Seite freigeben
    super.dispose();
  }

  Future<void> _handleQRCode(String link) async {
    try {
      // Überprüfen, ob der Link gültig ist
      final uri = Uri.tryParse(link);
      print(uri);
      if (uri == null || !uri.isAbsolute) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ungültiger QR-Code: $link')),
        );
        return;
      }

      // Optional: Überprüfen, ob der Server antwortet
      final response = await http.head(uri);
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Keine Verbindung zum Server möglich')),
        );
        return;
      }

      // Audio-Stream starten
      await _audioPlayer.setUrl(link);
      await _audioPlayer.play();
      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Streamen des Liedes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR-Code Scanner mit Audio'),
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: (BarcodeCapture capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    final link = barcode.rawValue!;
                    _handleQRCode(link); // Verarbeite den Link
                    break;
                  }
                }
              },
            ),
          ),
          if (isPlaying)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Audio wird abgespielt...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ElevatedButton(
            onPressed: () async {
              if (isPlaying) {
                await _audioPlayer.pause();
                setState(() {
                  isPlaying = false;
                });
              }
            },
            child: Text(isPlaying ? 'Stopp' : 'Nichts läuft'),
          ),
        ],
      ),
    );
  }
}
