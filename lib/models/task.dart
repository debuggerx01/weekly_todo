import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum Priority {
  emergency,
  high,
  normal,
  low,
}

extension PriorityExt on Priority {
  Color get color => {
        Priority.emergency: const Color(0xffe03131),
        Priority.high: const Color(0xfff08c00),
        Priority.normal: const Color(0xff40c057),
        Priority.low: const Color(0xff228be6),
      }[this]!;
}

enum Status {
  todo,
  wip,
  done,
}

extension StatusExt on Status {
  String get timeStr => {
        Status.todo: '创建',
        Status.wip: '开始',
        Status.done: '完成',
      }[this]!;
}

class Task {
  final String id;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String title;
  final String? content;
  final Priority priority;
  final Status status;

  Task({
    String? id,
    DateTime? createdAt,
    this.startedAt,
    this.completedAt,
    required this.title,
    this.content,
    this.priority = Priority.normal,
    this.status = Status.todo,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Task.formJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        startedAt: DateTime.tryParse(json['startedAt'] ?? ''),
        completedAt: DateTime.tryParse(json['completedAt'] ?? ''),
        title: json['title'] as String,
        content: json['content'] as String?,
        priority: Priority.values.byName(json['priority'] as String),
        status: Status.values.byName(json['status'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'startedAt': startedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'title': title,
        'content': content,
        'priority': priority.name,
        'status': status.name,
      };

  Task copyWith({
    String? title,
    String? content,
    Priority? priority,
    Status? status,
  }) {
    DateTime? startedAt;
    DateTime? completedAt;
    if (status == null) {
      startedAt = this.startedAt;
      completedAt = this.completedAt;
    } else {
      switch (status) {
        case Status.todo:
          startedAt = null;
          completedAt = null;
          break;
        case Status.wip:
          startedAt = this.startedAt ?? DateTime.now();
          completedAt = null;
          break;
        case Status.done:
          startedAt = this.startedAt ?? DateTime.now();
          completedAt = this.completedAt ?? DateTime.now();
          break;
      }
    }

    return Task(
      id: id,
      createdAt: createdAt,
      startedAt: startedAt,
      completedAt: completedAt,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      status: status ?? this.status,
    );
  }
}
