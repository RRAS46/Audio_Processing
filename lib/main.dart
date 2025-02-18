import 'package:audio_processing/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://nrjhxpoacydouyivyexm.supabase.co', // Replace with your Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5yamh4cG9hY3lkb3V5aXZ5ZXhtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ5OTQ3MjAsImV4cCI6MjA1MDU3MDcyMH0.T7K8bb26dbaIrVD3FXTbbu_aTGnNbtJWpwWbK4nslX0', // Replace with your Supabase anon key
  );


  runApp(
    MyApp()
  );
}


enum AudioProcessingMode {
  all,
  vocalSplit,
  speakerDiarization,
  shazam,
  aiRecognition,
}

extension AudioProcessingModeExtension on AudioProcessingMode {
  String get value {
    switch (this) {
      case AudioProcessingMode.all:
        return 'all';
      case AudioProcessingMode.vocalSplit:
        return 'vocal_split';
      case AudioProcessingMode.speakerDiarization:
        return 'speaker_diarization';
      case AudioProcessingMode.shazam:
        return 'shazam';
      case AudioProcessingMode.aiRecognition:
        return 'ai_recognition';
    }
  }

  static AudioProcessingMode fromString(String value) {
    switch (value) {
      case 'all':
        return AudioProcessingMode.all;
      case 'vocal_split':
        return AudioProcessingMode.vocalSplit;
      case 'speaker_diarization':
        return AudioProcessingMode.speakerDiarization;
      case 'shazam':
        return AudioProcessingMode.shazam;
      case 'ai_recognition':
        return AudioProcessingMode.aiRecognition;
      default:
        throw ArgumentError('Invalid AudioProcessingMode value: $value');
    }
  }
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'File Upload to Supabase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthPage(),
    );
  }
}