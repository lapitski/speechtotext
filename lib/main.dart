import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(
        useMaterial3: true,
      ),
      home: const SpeechToTextScreen(),
    );
  }
}

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({super.key});

  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  final List<String> _recognizedWords = [];
  String _currentPhrase = '';
  List<LocaleName> locales = [];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    locales = await _speechToText.locales();
    for (final l in locales) {
      log(l.localeId);
    }
    _speechEnabled = await _speechToText.initialize(onStatus: onStatus);
    setState(() {});
  }

  onStatus(String status) {
    log('Status - $status');
  }

  void _startListening() async {
    _recognizedWords.add(_currentPhrase);
    _currentPhrase = '';

    await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: 'en_US',
        listenOptions: SpeechListenOptions(
          autoPunctuation: true,
          listenMode: ListenMode.dictation,
          partialResults: true,
        ));
    log('DONE');
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _currentPhrase = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech to text'),
      ),
      body: _speechEnabled
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      'Recognized words:',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: ListView.builder(
                          itemCount: _recognizedWords.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Text('Me: ${_recognizedWords[index]}'),
                                if (index == _recognizedWords.length - 1 &&
                                    _currentPhrase.isNotEmpty)
                                  Text('Me: $_currentPhrase'),
                              ],
                            );
                          }),
                    ),
                  ),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
      floatingActionButton: _speechEnabled
          ? FloatingActionButton(
              onPressed:
                  // If not yet listening for speech start, otherwise stop
                  _speechToText.isNotListening
                      ? _startListening
                      : _stopListening,
              tooltip: 'Listen',
              child: Icon(_speechToText.isListening ? Icons.stop : Icons.mic),
            )
          : null,
    );
  }
}
