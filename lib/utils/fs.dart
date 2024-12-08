import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' show join, basenameWithoutExtension;
import 'package:path_provider/path_provider.dart';
import 'package:weekly_todo/models/note.dart';
import 'package:weekly_todo/utils/extensions.dart';

const _appDirName = 'weekly_todo';

final fs = _FS();

class _FS {
  late final Directory appDir;
  File? currentNoteFile;

  Future init() async {
    var directory = await getApplicationDocumentsDirectory();
    appDir = Directory(join(directory.path, _appDirName));
    if (!appDir.existsSync()) {
      appDir.createSync();
    }
  }

  List<String> loadAllNoteName() => appDir.listSync().where((file) => file.path.endsWith('.json')).map((file) => basenameWithoutExtension(file.path)).toList()
    ..sort(
      (a, b) => b.compareTo(a),
    );

  String loadNoteContent(String date) {
    currentNoteFile = File(join(appDir.path, '$date.json'));
    return currentNoteFile!.readAsStringSync();
  }

  saveNote(Note note) => currentNoteFile?.writeAsStringSync(json.encode(note));

  createNote(Note note) {
    currentNoteFile = File(join(appDir.path, '${note.date}.json'));
    saveNote(note);
  }

  List<SearchResult> search(String date, String text) {
    text = text.trim().toLowerCase();
    var content = File(join(appDir.path, '$date.json')).readAsStringSync();

    var results = <SearchResult>[];
    // 搜索时忽略大小写
    if (content.toLowerCase().contains(text)) {
      var note = Note.formJson(json.decode(content));
      for (var task in note.tasks) {
        // 优先展示标题含有关键词的任务记录
        if (task.title.toLowerCase().contains(text)) {
          results.insert(0, SearchResult(date: date, id: task.id, title: task.title));
        } else if ((task.content ?? '').toLowerCase().contains(text)) {
          results.add(SearchResult(date: date, id: task.id, title: task.title));
        }
      }
    }
    return results;
  }
}

class SearchResult {
  final String date;
  final String id;
  final String title;

  SearchResult({
    required this.date,
    required this.id,
    required this.title,
  });

  @override
  String toString() => '【${date.weekRange}】 $title';
}
