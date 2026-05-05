import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqService {
  static final String _apiKey = dotenv.env['GROQ_API_KEY']!;
  static const String _apiUrl =
      'https://api.groq.com/openai/v1/audio/transcriptions';
  static const String _chatUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  final AudioRecorder _record = AudioRecorder();
  String? _currentPath;

  Future<String?> generateTutorResponse(String userText) async {
    try {
      final response = await http.post(
        Uri.parse(_chatUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama3-8b-8192',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Eres un tutor amigable y educativo. Responde siempre de manera concisa (no más de 2 o 3 oraciones cortas), clara y motivadora.',
            },
            {'role': 'user', 'content': userText},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        debugPrint(
          'Error from Groq LLM: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error generating response: $e');
    }
    return null;
  }

  Future<void> startRecording() async {
    try {
      if (await _record.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        _currentPath = '${directory.path}/temp_audio.m4a';

        await _record.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: _currentPath!,
        );
      }
    } catch (e) {
      debugPrint('Error starting record: $e');
    }
  }

  Future<Map<String, dynamic>?> stopRecordingAndTranscribe() async {
    try {
      final path = await _record.stop();
      if (path != null) {
        return await _transcribeAudio(path);
      }
    } catch (e) {
      debugPrint('Error stopping record: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> _transcribeAudio(String filePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      request.headers.addAll({'Authorization': 'Bearer $_apiKey'});
      request.fields['model'] = 'whisper-large-v3-turbo'; // Groq whisper model
      request.fields['response_format'] = 'json';

      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseData);
        // Save to provisional JSON file
        await _saveToProvisionalJson(jsonResponse);
        return jsonResponse;
      } else {
        debugPrint(
          'Error transcribing: ${response.statusCode} - $responseData',
        );
      }
    } catch (e) {
      debugPrint('Error sending audio: $e');
    }
    return null;
  }

  Future<void> _saveToProvisionalJson(
    Map<String, dynamic> newTranscription,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/provisional_transcriptions.json');

      List<dynamic> currentData = [];
      if (await file.exists()) {
        final contents = await file.readAsString();
        if (contents.isNotEmpty) {
          currentData = jsonDecode(contents);
        }
      }

      currentData.add({
        'timestamp': DateTime.now().toIso8601String(),
        'text': newTranscription['text'],
        'full_response': newTranscription,
      });

      await file.writeAsString(jsonEncode(currentData));
      debugPrint('Saved to provisional json: ${file.path}');
    } catch (e) {
      debugPrint('Error saving json: $e');
    }
  }
}
