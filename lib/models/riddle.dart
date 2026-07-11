class Riddle {
  final String id;
  final String question;
  final String answer;
  final String category;
  final String difficulty;
  final String? hint;
  bool isFavorite;

  Riddle({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.difficulty,
    this.hint,
    this.isFavorite = false,
  });

  factory Riddle.fromJson(Map<String, dynamic> json) {
    return Riddle(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      question: json['question'] ?? json['content'] ?? '',
      answer: json['answer'] ?? '',
      category: json['category'] ?? '字谜',
      difficulty: json['difficulty'] ?? '中等',
      hint: json['hint'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category,
      'difficulty': difficulty,
      'hint': hint,
    };
  }

  Riddle copyWith({
    String? id,
    String? question,
    String? answer,
    String? category,
    String? difficulty,
    String? hint,
    bool? isFavorite,
  }) {
    return Riddle(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      hint: hint ?? this.hint,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
