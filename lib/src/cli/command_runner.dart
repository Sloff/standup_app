import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dart_date/dart_date.dart';
import 'package:interact/interact.dart';
import 'package:tint/tint.dart';

import '/src/models/models.dart';
import '/src/utils/utils.dart' as utils;
import './print.dart';

void commandRunner(List<String> args) {
  var runner =
      CommandRunner('standup', 'Assists with keeping track of work for standup')
        ..addCommand(AddCommand())
        ..addCommand(ViewCommand())
        ..addCommand(EditCommand())
        ..addCommand(RemoveCommand());

  runner.run(args).catchError((error) {
    switch (error.runtimeType) {
      case UsageException:
        {
          stderr.writeln(error);
          exit(64); // Exit code 64 indicates a usage error.
        }
      case FormatException:
        {
          stderr.writeln('${error.message}: ${error.source}'.red());
          exit(64);
        }
      default:
        throw error;
    }
  });
}

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
    var entryDescription = argResults?.rest.isNotEmpty ?? false
        ? argResults!.rest.join(' ')
        : Input(prompt: 'Description:', validator: isRequired).interact();

    var dateOfEntry = DateTime.parse(argResults!['date']);

    var task = Task(description: entryDescription);

    await Data.addTask(dateOfEntry: dateOfEntry, task: task);

    stdout.writeln('Entry added'.green());
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
      return _viewTasksOnDate();
    }

    return _viewTasksForStandup();
  }

  void _viewTasksOnDate() async {
    var date = DateTime.parse(argResults!['date']);

    List<Task> tasks = await Data.getTasksOnDate(date: date);

    printHeadingAndList(
        heading: date.format('yyyy-MM-dd'),
        list: tasks.map((task) => task.description));
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
    argParser.addOption('date',
        abbr: 'd',
        help: 'The date of the entry.',
        valueHelp: 'YYYY-MM-DD',
        defaultsTo: DateTime.now().format('yyyy-MM-dd'));
  }

  @override
  void run() async {
    DateTime dateOfEntryToEdit = DateTime.parse(argResults!['date']);

    List<Task> tasks = await Data.getTasksOnDate(date: dateOfEntryToEdit);

    if (tasks.isEmpty) {
      stdout.writeln('Nothing to edit'.yellow());
      return;
    }

    stdout.writeln('');
    int entryToEditIndex = Select(
      prompt: 'Please select an entry:',
      options: tasks.map((task) => task.description).toList(),
    ).interact();

    String newDescription = argResults?.rest.isNotEmpty ?? false
        ? argResults!.rest.join(' ')
        : Input(
                prompt: 'New Description:',
                initialText: tasks[entryToEditIndex].description,
                validator: isRequired)
            .interact();

    await Data.editTaskOnDate(
        date: dateOfEntryToEdit,
        index: entryToEditIndex,
        task: Task(description: newDescription));

    stdout.writeln('Entry updated'.green());
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
  }

  @override
  void run() async {
    DateTime dateOfEntryToRemove = DateTime.parse(argResults!['date']);

    List<Task> tasks = await Data.getTasksOnDate(date: dateOfEntryToRemove);

    if (tasks.isEmpty) {
      stdout.writeln('Nothing to remove'.yellow());
      return;
    }

    stdout.writeln('');
    int entryToRemoveIndex = Select(
      prompt: 'Please select an entry to remove:',
      options: tasks.map((task) => task.description).toList(),
    ).interact();

    await Data.removeTaskOnDate(
      date: dateOfEntryToRemove,
      index: entryToRemoveIndex,
    );

    stdout.writeln('Entry removed'.green());
  }
}

bool isRequired(String val) {
  if (val.isNotEmpty) {
    return true;
  }

  throw ValidationError('A description is required');
}
