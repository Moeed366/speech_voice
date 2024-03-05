import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AudioToTextPage extends StatefulWidget {
  @override
  _AudioToTextPageState createState() => _AudioToTextPageState();
}

class _AudioToTextPageState extends State<AudioToTextPage> {
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isRecording = false;
  List<String> _transcriptions = [];
  late Record audioRecord;
  @override
  void initState() {
    super.initState();
    _initSpeechRecognizer();
  }

  Future<void> _initSpeechRecognizer() async {
    bool isAvailable = await _speech.initialize();
    if (!isAvailable) {
      print("Speech recognition is not available");
    }
  }

  Future<void> _startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      Directory appDocDirectory = await getApplicationDocumentsDirectory();
      String filePath = appDocDirectory.path +
          '/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await audioRecord.start(
        path: filePath,
        encoder: AudioEncoder.aacEld,
        bitRate: 128000,
      );

      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _stopRecording() async {
    if (await audioRecord.isRecording()) {
      await audioRecord.stop();

      setState(() {
        _isRecording = false;
      });

      _convertAudioToText();
    }
  }

  Future<void> _convertAudioToText() async {
    if (!_speech.isAvailable) return;

    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    String filePath = appDocDirectory.path +
        '/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

    File audioFile = File(filePath);
    if (!audioFile.existsSync()) return;

    List<int> audioBytes = await audioFile.readAsBytes();

    String transcription = await _speech.listen(
        /*   bytes: audioBytes,
      timeout: Duration(seconds: 30), */

        );

    setState(() {
      _transcriptions.add(transcription);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio to Text'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _transcriptions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_transcriptions[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
