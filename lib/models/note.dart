import 'dart:convert';

class Note {
  final String id;
  final String question;
  final String answer;
  final DateTime timestamp;

  Note({
    String? id,
    required this.question,
    required this.answer,
    DateTime? timestamp,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();

  String toJsonString() {
    return jsonEncode({
      'id': id,
      'question': question,
      'answer': answer,
      'timestamp': timestamp.toIso8601String(),
    });
  }

  factory Note.fromJsonString(String jsonString) {
    final map = jsonDecode(jsonString);
    return Note(
      id: map['id'],
      question: map['question'],
      answer: map['answer'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  String get formattedDate {
    return '${timestamp.month}月${timestamp.day}日 ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
