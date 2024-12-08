import 'package:weekly_todo/models/task.dart';

class Note {
  final String date;
  final List<Task> tasks;

  Note({required this.date, required this.tasks});

  factory Note.formJson(Map<String, dynamic> json) => Note(
        date: json['date'],
        tasks: (json['tasks'] as List).map<Task>((json) => Task.formJson(json)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'tasks': tasks,
      };
}
