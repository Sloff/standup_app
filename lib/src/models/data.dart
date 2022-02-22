import 'dart:convert';
import 'dart:io';

import 'package:dart_date/dart_date.dart';
import 'package:json_annotation/json_annotation.dart';

import './task.dart';

part 'data.g.dart';

@JsonSerializable()
class Data {
  Map<DateTime, List<Task>> days;

  Data({required this.days});

  Data.empty() : days = {};

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);

  static Future<Data> loadDataFile() async {
    final dataFile = File('data.json');

    if (!await dataFile.exists()) {
      return Data.empty();
    }

    final jsonData = await dataFile.readAsString();

    return Data.fromJson(json.decode(jsonData));
  }

  Future<void> save() async {
    final dataFile = File('data.json');

    JsonEncoder encoder = const JsonEncoder.withIndent('  ');

    await dataFile.writeAsString(encoder.convert(this));
  }

  static Future<void> addTask(
      {required DateTime dateOfEntry, required Task task}) async {
    Data data = await Data.loadDataFile();

    var taskList = data.days.putIfAbsent(dateOfEntry, (() => ([])));
    taskList.add(task);

    await data.save();
  }

  static Future<List<Task>> getTasksOnDate({required DateTime date}) async {
    Data data = await Data.loadDataFile();

    return data.days[date] ?? [];
  }

  static Future<StandupInfo> getTasksForStandup() async {
    Data data = await Data.loadDataFile();

    List<DateTime> dates = data.days.keys.toList();
    dates.sort();

    var pastDateIterator =
        dates.reversed.skipWhile((date) => date.isFuture || date.isToday);

    DateTime? previousDayDate =
        pastDateIterator.isNotEmpty ? pastDateIterator.first : null;

    List<Task> previousDay =
        previousDayDate == null ? [] : data.days[previousDayDate] ?? [];

    List<Task> today = data.days[Date.startOfToday] ?? [];

    return StandupInfo(
        today: today,
        previousDay: previousDay,
        previousDayDate: previousDayDate);
  }
}

class StandupInfo {
  final List<Task> today;
  final List<Task> previousDay;
  final DateTime? previousDayDate;

  StandupInfo(
      {required this.today,
      required this.previousDay,
      required this.previousDayDate});
}
