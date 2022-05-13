import 'dart:convert';
import 'dart:io';

import 'package:dart_date/dart_date.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tint/tint.dart';
import 'package:uuid/uuid.dart';

import './task.dart';
import './sprint.dart';

part 'data.g.dart';

@JsonSerializable()
class Data {
  Map<DateTime, List<String>> days;
  Map<String, Task> tasks;

  Sprint? currentSprint;

  static Data? _cache;
  static DateTime? _timeModified;

  Data({required this.days, required this.tasks, this.currentSprint});

  Data.empty()
      : days = {},
        tasks = {},
        currentSprint = null;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);

  static Future<Data> loadDataFile() async {
    final dataFile = File('data.json');

    if (!await dataFile.exists()) {
      return Data.empty();
    }

    DateTime fileModified = await dataFile.lastModified();

    if (_cache != null && fileModified == _timeModified) {
      return _cache!;
    }

    if (_cache != null) {
      stdout.writeln(
          'WARNING: Reading data file again because it was modified'.red());
    }

    stdout.writeln('DEBUG: File read'.blue());
    final jsonData = await dataFile.readAsString();

    _cache = Data.fromJson(json.decode(jsonData));
    _timeModified = fileModified;
    return _cache!;
  }

  Future<void> save() async {
    final dataFile = File('data.json');

    JsonEncoder encoder = const JsonEncoder.withIndent('  ');

    await dataFile.writeAsString(encoder.convert(this));
    _timeModified = await dataFile.lastModified();
  }

  static Future<void> addTask(
      {required DateTime dateOfEntry, required Task task}) async {
    Data data = await Data.loadDataFile();

    String newTaskId = const Uuid().v4();

    var taskIds = data.days.putIfAbsent(dateOfEntry, (() => ([])));
    taskIds.add(newTaskId);

    data.tasks[newTaskId] = task;

    await data.save();
  }

  static Future<List<TaskWithId>> getTasksOnDate(
      {required DateTime date}) async {
    Data data = await Data.loadDataFile();

    return (data.days[date] ?? [])
        .map((taskId) =>
            TaskWithId.fromTask(id: taskId, task: data.tasks[taskId]!))
        .toList();
  }

  static Future<void> editTaskOnDate({required TaskWithId task}) async {
    Data data = await Data.loadDataFile();

    data.tasks[task.id] = task;

    await data.save();
  }

  static Future<void> removeTaskOnDate(
      {required DateTime date, required String taskId}) async {
    Data data = await Data.loadDataFile();

    data.days[date]!.remove(taskId);
    data.tasks.remove(taskId);

    if (data.days[date]!.isEmpty) {
      data.days.remove(date);
    }

    await data.save();
  }

  static Future<StandupInfo> getTasksForStandup() async {
    Data data = await Data.loadDataFile();

    List<DateTime> dates = data.days.keys.toList();
    dates.sort();

    var pastDateIterator =
        dates.reversed.skipWhile((date) => date.isFuture || date.isToday);

    DateTime? previousDayDate =
        pastDateIterator.isNotEmpty ? pastDateIterator.first : null;

    List<Task> previousDay = previousDayDate == null
        ? []
        : (data.days[previousDayDate] ?? [])
            .map((taskId) => data.tasks[taskId]!)
            .toList();

    List<Task> today = (data.days[Date.startOfToday] ?? [])
        .map((taskId) => data.tasks[taskId]!)
        .toList();

    return StandupInfo(
        today: today,
        previousDay: previousDay,
        previousDayDate: previousDayDate);
  }

  static Future<void> newSprint({required Sprint sprint}) async {
    Data data = await Data.loadDataFile();

    data.currentSprint = sprint;

    await data.save();
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
