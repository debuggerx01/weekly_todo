import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_effect.g.dart';

@riverpod
class TaskEffect extends _$TaskEffect {
  @override
  String? build() {
    return null;
  }

  Timer? _timer;

  void shake(String taskId) {
    if (_timer?.isActive == true) {
      _timer?.cancel();
    }

    // 留出切换到任务所在周，并滚动到任务所在位置的时间
    Future.delayed(const Duration(milliseconds: 300), () {
      state = taskId;
      _timer = Timer(const Duration(seconds: 2), () {
        state = null;
      });
    });
  }
}
