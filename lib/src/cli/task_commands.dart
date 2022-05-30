import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_date/dart_date.dart';
import 'package:interact/interact.dart';
import 'package:tint/tint.dart';

import '/src/models/models.dart';
import '/src/utils/utils.dart' as utils;
import 'print.dart';
import 'utils.dart';

Future<void> add(ArgResults? argResults) async {
  var entryDescription = argResults?.rest.isNotEmpty ?? false
      ? argResults!.rest.join(' ')
      : Input(prompt: 'Description', validator: isRequired).interact();

  var dateOfEntry = DateTime.parse(argResults!['date']);

  var task = Task(description: entryDescription);

  await Data.addTask(dateOfEntry: dateOfEntry, task: task);

  await _printTasksOnDate(dateOfEntry);
}

Future<void> view(ArgResults? argResults) async {
  if (argResults?['date'] != null) {
    return _printTasksOnDate(DateTime.parse(argResults!['date']));
  }

  return _viewTasksForStandup();
}

Future<void> _viewTasksForStandup() async {
  var standupTasks = await Data.getTasksForStandup();

  if (standupTasks.previousDayDate != null) {
    printHeadingAndList(
        heading: utils.getRelativeDateHeading(standupTasks.previousDayDate!),
        list: standupTasks.previousDay.map((e) => e.description));
  }

  printHeadingAndList(
      heading: "Today I'm working on",
      list: standupTasks.today.map((e) => e.description));
}

Future<void> edit(ArgResults? argResults) async {
  DateTime dateOfEntryToEdit = DateTime.parse(argResults!['date']);

  List<TaskWithId> tasks = await Data.getTasksOnDate(date: dateOfEntryToEdit);

  if (tasks.isEmpty) {
    stdout.writeln('Nothing to edit'.yellow());
    return;
  }

  stdout.writeln('');
  int entryToEditIndex = _selectedEntry(argResults, tasks);

  String newDescription = argResults.rest.isNotEmpty
      ? argResults.rest.join(' ')
      : Input(
              prompt: 'New Description',
              initialText: tasks[entryToEditIndex].description,
              validator: isRequired)
          .interact();

  await Data.editTaskOnDate(
      task: TaskWithId(
          id: tasks[entryToEditIndex].id, description: newDescription));

  await _printTasksOnDate(dateOfEntryToEdit);
}

Future<void> remove(ArgResults? argResults) async {
  DateTime dateOfEntryToRemove = DateTime.parse(argResults!['date']);

  List<TaskWithId> tasks = await Data.getTasksOnDate(date: dateOfEntryToRemove);

  if (tasks.isEmpty) {
    stdout.writeln('Nothing to remove'.yellow());
    return;
  }

  int entryToRemoveIndex = _selectedEntry(argResults, tasks);

  await Data.removeTaskOnDate(
    date: dateOfEntryToRemove,
    taskId: tasks[entryToRemoveIndex].id,
  );

  await _printTasksOnDate(dateOfEntryToRemove);
}

Future<void> copy(ArgResults? argResults) async {
  DateTime dateOfEntryToCopy = DateTime.parse(argResults?['dateFrom'] ??
      Input(
              prompt: 'Date to copy from',
              validator: isRequired,
              initialText: DateTime.now().format('yyyy-MM-dd'))
          .interact());

  List<TaskWithId> tasks = await Data.getTasksOnDate(date: dateOfEntryToCopy);

  if (tasks.isEmpty) {
    stdout.writeln('Nothing to copy'.yellow());
    return;
  }

  int entryToCopyIndex = _selectedEntry(argResults, tasks);

  DateTime dateToCopyEntryTo = DateTime.parse(argResults?['dateTo'] ??
      Input(
              prompt: 'Date to copy to',
              validator: isRequired,
              initialText: DateTime.now().format('yyyy-MM-dd'))
          .interact());

  await Data.addTask(
    dateOfEntry: dateToCopyEntryTo,
    task: tasks[entryToCopyIndex],
  );

  await _printTasksOnDate(dateToCopyEntryTo);
}

Future<void> _printTasksOnDate(DateTime date) async {
  List<Task> tasks = await Data.getTasksOnDate(date: date);

  printHeadingAndList(
      heading: date.format('yyyy-MM-dd'),
      list: tasks.map((task) => task.description));
}

int _selectedEntry(ArgResults? argResults, List<Task> tasks) {
  return getSelectedEntryIndex(
      argResults?['index'], tasks.map((task) => task.description).toList());
}
