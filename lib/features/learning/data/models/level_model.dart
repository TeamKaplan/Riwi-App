import 'question_model.dart';

class Level {
  final int id;
  final String title;
  final String description;
  final List<Question> exercises;
  final int xpReward;
  final String difficulty;

  Level({
    required this.id,
    required this.title,
    required this.description,
    required this.exercises,
    this.xpReward = 100,
    this.difficulty = 'A1',
  });
}
