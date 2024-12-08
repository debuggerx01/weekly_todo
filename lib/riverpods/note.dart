import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weekly_todo/models/note.dart';
import 'package:weekly_todo/models/task.dart';
import 'package:weekly_todo/utils/extensions.dart';
import 'package:weekly_todo/utils/fs.dart';

part 'note.g.dart';

@riverpod
class CurrentNote extends _$CurrentNote {
  @override
  Note build() {
    // 默认加载最新一周的数据
    var latestNoteDate = ref.read(allNotesProvider).firstOrNull;
    // 第一次使用APP
    if (latestNoteDate == null) {
      return createNote(null);
    }
    return Note.formJson(json.decode(fs.loadNoteContent(latestNoteDate)));
  }

  /// 创建本周数据，如果存在上周数据，则继承其状态不为DONE的任务
  Note createNote(Note? note) {
    var newNote = Note(
      date: DateTime.now().startDateStrOfWeek,
      tasks: note?.tasks
              .where(
                (task) => task.status != Status.done,
              )
              .toList() ??
          [],
    );
    // 落盘并更新所有数据列表
    fs.createNote(newNote);
    ref.read(allNotesProvider.notifier).refresh();
    return newNote;
  }

  void changeNote(String date) {
    state = Note.formJson(json.decode(fs.loadNoteContent(date)));
  }

  /// 任务的增删改
  void updateTask(Task task, {isDelete = false}) {
    if (isDelete) {
      state.tasks.removeWhere(
        (ele) => ele.id == task.id,
      );
    } else {
      var existTaskIndex = state.tasks.indexWhere(
        (ele) => ele.id == task.id,
      );

      if (existTaskIndex < 0) {
        state.tasks.add(task);
      } else {
        state.tasks[existTaskIndex] = task;
      }
    }
    // 通知界面更新并落盘
    ref.notifyListeners();
    fs.saveNote(state);
  }
}

@riverpod
class AllNotes extends _$AllNotes {
  @override
  List<String> build() {
    return fs.loadAllNoteName();
  }

  refresh() {
    ref.invalidateSelf();
  }

  List<SearchResult> search(String text) => state
      // 循环查询
      .map(
        (date) => fs.search(date, text),
      )
      // 将查询结果从二维数组拍平为一维数组
      .flattened
      // 根据taskId分组
      .groupSetsBy((task) => task.id)
      // 只取第一个
      .values
      .map((ele) => ele.first)
      .toList();
}
