import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _toggleListening() async {
    if (_isListening) {
      _stopListening();
    } else {
      await _startListening();
    }
  }

  /* Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        print('onStatus: $val');
        if (val == 'done') {
          // Check if we should restart listening after a pause
          if (_isListening) {
            Future.delayed(Duration(milliseconds: 100), _startListening);
          }
        }
      },
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      _speech.listen(
        onResult: (val) => setState(() {
          _text +=
              (val.recognizedWords.isNotEmpty ? " " : "") + val.recognizedWords;
        }),
        listenFor: Duration(seconds: 30),
        partialResults: true,
      );
      setState(() => _isListening = true);
    }
  }*/
  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        print('onStatus: $val');
        if (val == 'done') {
          // Check if we should restart listening after a pause
          if (_isListening) {
            Future.delayed(Duration(milliseconds: 100), _startListening);
          }
        }
      },
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      _speech.listen(
        onResult: (val) => setState(() {
          // Append the recognized words only if the result is final.
          /* if (val.recognizedWords.isNotEmpty && val.finalResult) {
            _text += " " +
                val.recognizedWords; // Append the new words to the existing text.
          }*/
          _text += " " + val.recognizedWords;
        }),
        listenFor: const Duration(seconds: 30),
        partialResults: true,
      );
      setState(() => _isListening = true);
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
    print("result:>>>>>>     $_text");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Speech to Text Example'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: _toggleListening,
          child: Icon(_isListening ? Icons.mic_off : Icons.mic),
        ),
        body: SingleChildScrollView(
          reverse: true,
          child: Container(
            padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
            child: Text(
              _text,
              style: const TextStyle(
                fontSize: 24.0,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
