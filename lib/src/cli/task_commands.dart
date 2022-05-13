import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dart_date/dart_date.dart';
import 'package:interact/interact.dart';
import 'package:tint/tint.dart';

import '/src/models/models.dart';
import '/src/utils/utils.dart' as utils;
import './print.dart';
import './sprint_commands.dart';
import './utils.dart';

class AddCommand extends Command {
  @override
  final name = 'add';

  @override
  final aliases = ['a'];

  @override
  final description = 'Create a new entry';

  AddCommand() {
    argParser.addOption('date',
        abbr: 'd',
        help: 'The date of the entry.',
        valueHelp: 'YYYY-MM-DD',
        defaultsTo: DateTime.now().format('yyyy-MM-dd'));
  }

  @override
  void run() async {
    if (await Data.sprintStatus() != SprintStatus.active) {
      await noActiveSprint();
    }

    var entryDescription = argResults?.rest.isNotEmpty ?? false
        ? argResults!.rest.join(' ')
        : Input(prompt: 'Description:', validator: isRequired).interact();

    var dateOfEntry = DateTime.parse(argResults!['date']);

    var task = Task(description: entryDescription);

    await Data.addTask(dateOfEntry: dateOfEntry, task: task);

    _printTasksOnDate(dateOfEntry);
  }
}

class ViewCommand extends Command {
  @override
  final name = 'view';

  @override
  final aliases = ['v'];

  @override
  final description = 'View entries';

  ViewCommand() {
    argParser.addOption(
      'date',
      abbr: 'd',
      help: 'The date of the entry.',
      valueHelp: 'YYYY-MM-DD',
    );
  }

  @override
  void run() async {
    if (argResults?['date'] != null) {
      return _printTasksOnDate(DateTime.parse(argResults!['date']));
    }

    return _viewTasksForStandup();
  }

  void _viewTasksForStandup() async {
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
}

class EditCommand extends Command {
  @override
  final name = 'edit';

  @override
  final aliases = ['e'];

  @override
  final description = 'Edit an Entry';

  EditCommand() {
    argParser.addOption(
      'date',
      abbr: 'd',
      help: 'The date of the entry.',
      valueHelp: 'YYYY-MM-DD',
      defaultsTo: DateTime.now().format('yyyy-MM-dd'),
    );
    argParser.addOption(
      'index',
      abbr: 'i',
      help: 'The zero based index of the entry',
    );
  }

  @override
  void run() async {
    DateTime dateOfEntryToEdit = DateTime.parse(argResults!['date']);

    List<TaskWithId> tasks = await Data.getTasksOnDate(date: dateOfEntryToEdit);

    if (tasks.isEmpty) {
      stdout.writeln('Nothing to edit'.yellow());
      return;
    }

    stdout.writeln('');
    int entryToEditIndex = _selectedEntry(argResults, tasks);

    String newDescription = argResults?.rest.isNotEmpty ?? false
        ? argResults!.rest.join(' ')
        : Input(
                prompt: 'New Description:',
                initialText: tasks[entryToEditIndex].description,
                validator: isRequired)
            .interact();

    await Data.editTaskOnDate(
        task: TaskWithId(
            id: tasks[entryToEditIndex].id, description: newDescription));

    _printTasksOnDate(dateOfEntryToEdit);
  }
}

class RemoveCommand extends Command {
  @override
  final name = 'remove';

  @override
  final aliases = ['r', 'delete', 'd'];

  @override
  final description = 'Remove an Entry';

  RemoveCommand() {
    argParser.addOption('date',
        abbr: 'd',
        help: 'The date of the entry.',
        valueHelp: 'YYYY-MM-DD',
        defaultsTo: DateTime.now().format('yyyy-MM-dd'));
    argParser.addOption(
      'index',
      abbr: 'i',
      help: 'The zero based index of the entry',
    );
  }

  @override
  void run() async {
    DateTime dateOfEntryToRemove = DateTime.parse(argResults!['date']);

    List<TaskWithId> tasks =
        await Data.getTasksOnDate(date: dateOfEntryToRemove);

    if (tasks.isEmpty) {
      stdout.writeln('Nothing to remove'.yellow());
      return;
    }

    int entryToRemoveIndex = _selectedEntry(argResults, tasks);

    await Data.removeTaskOnDate(
      date: dateOfEntryToRemove,
      taskId: tasks[entryToRemoveIndex].id,
    );

    _printTasksOnDate(dateOfEntryToRemove);
  }
}

void _printTasksOnDate(DateTime date) async {
  List<Task> tasks = await Data.getTasksOnDate(date: date);

  printHeadingAndList(
      heading: date.format('yyyy-MM-dd'),
      list: tasks.map((task) => task.description));
}

int _selectedEntry(ArgResults? argResults, List<Task> tasks) {
  int selectedEntryIndex;

  if ((argResults?['index'] ?? '').isNotEmpty) {
    selectedEntryIndex = int.parse(argResults!['index']);
  } else {
    stdout.writeln('');
    selectedEntryIndex = Select(
      prompt: 'Please select an entry:',
      options: tasks.map((task) => task.description).toList(),
    ).interact();
  }

  return selectedEntryIndex;
}
