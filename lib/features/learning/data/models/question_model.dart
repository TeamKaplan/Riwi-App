enum QuestionType {
  multipleChoice,
  fillInTheBlanks,
  trueFalse,
  matching,
  orderWords,
  errorCorrection,
  shortWriting,
  miniReading,
  completeDialogue,
  chooseCorrect,
  completeCode,
  completeWord,
}

class QuestionOption {
  final String text;
  final bool isCorrect;
  QuestionOption({required this.text, this.isCorrect = false});
}

class Question {
  final String id;
  final QuestionType type;
  final String prompt;
  final String? instruction;
  final List<QuestionOption>? options;
  final String? correctAnswer;
  final List<String>? matchingLeft;
  final List<String>? matchingRight;
  final String? readingText;
  final List<String>? blanksAnswers;
  final int? order;
  final String? codeSnippet;
  final String? codeLanguage;

  Question({
    required this.id,
    required this.type,
    required this.prompt,
    this.instruction,
    this.options,
    this.correctAnswer,
    this.matchingLeft,
    this.matchingRight,
    this.readingText,
    this.blanksAnswers,
    this.order,
    this.codeSnippet,
    this.codeLanguage,
  });
}
