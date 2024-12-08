import 'package:flutter/material.dart';

extension WeekExt on DateTime {
  DateTime get startDateOfWeek => DateTime(
        year,
        month,
        day + 1 - weekday,
      );

  String get startDateStrOfWeek {
    DateTime start = startDateOfWeek;

    return '${start.year}_${start.month.pad}_${start.day.pad}';
  }

  DateTime get endDateOfWeek => DateTime(
        year,
        month,
        day + 7 - weekday,
      );

  String get endDateStrOfWeek {
    DateTime end = endDateOfWeek;

    return '${end.year}_${end.month.pad}_${end.day.pad}';
  }
}

extension on int {
  String get pad => toString().padLeft(2, '0');
}

extension TimeStrExt on DateTime {
  String get desc {
    var now = DateTime.now();
    var weekName = [
      '',
      '周一',
      '周二',
      '周三',
      '周四',
      '周五',
      '周六',
      '周日',
    ][weekday];
    if (now.startDateStrOfWeek == startDateStrOfWeek) {
      return weekName;
    } else if (now.subtract(const Duration(days: 7)).startDateStrOfWeek == startDateStrOfWeek) {
      return '上$weekName';
    }

    var weekDiff = now.startDateOfWeek.difference(startDateOfWeek).inDays ~/ 7;
    if (weekDiff < 10) {
      return '$weekDiff周前';
    }

    var monthDiff = (now.year * 12 + now.month) - (year * 12 + month);
    if (monthDiff < 10) {
      return '$monthDiff月前';
    }
    if (now.year == year) {
      return '年初';
    }
    if (now.year - year == 1) {
      return '去年';
    }
    return '${now.year - year}年前';
  }

  String get timeStr => '$year/${month.pad}/${day.pad} ${hour.pad}:${minute.pad}:${second.pad} ($desc)';
}

extension DateStrExt on String {
  DateTime get date {
    var parts = split('_');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  String get weekRange {
    var start = date.startDateStrOfWeek;
    var end = date.endDateStrOfWeek;
    return '${start.replaceAll('_', '/')} ~ ${end.replaceAll('_', '/')}';
  }
}

extension CtxExt on BuildContext {
  Size get screenSize => MediaQuery.of(this).size;

  double get screenWidth => screenSize.width;

  void pop() => Navigator.of(this).pop();
}
