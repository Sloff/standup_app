import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dart_date/dart_date.dart';
import 'package:dcli/dcli.dart';
import 'package:standup_app/src/models/models.dart';
import 'package:standup_app/src/utils/utils.dart' as utils;

import './print.dart';

void commandRunner(List<String> args) {
  var runner =
      CommandRunner("standup", "Assists with keeping track of work for standup")
        ..addCommand(AddCommand())
        ..addCommand(ViewCommand());

  runner.run(args).catchError((error) {
    switch (error.runtimeType) {
      case UsageException:
        {
          stderr.writeln(error);
          exit(64); // Exit code 64 indicates a usage error.
        }
      case FormatException:
        {
          stderr.writeln(red('${error.message}: ${error.source}'));
          exit(64);
        }
      default:
        throw error;
    }
  });
}

class AddCommand extends Command {
  @override
  final name = "add";

  @override
  final description = "Create a new entry";

  AddCommand() {
    argParser.addOption("date",
        abbr: 'd',
        help: 'The date of the entry.',
        valueHelp: 'YYYY-MM-DD',
        defaultsTo: DateTime.now().format('yyyy-MM-dd'));
  }

  @override
  void run() async {
    var entryDescription = argResults?.rest.isNotEmpty ?? false
        ? argResults!.rest.join(' ')
        : ask(green("Description:"), required: true);

    var dateOfEntry = DateTime.parse(argResults!['date']);

    var task = Task(description: entryDescription);

    await Data.addTask(dateOfEntry: dateOfEntry, task: task);

    stdout.writeln(green("Entry added"));
  }
}

class ViewCommand extends Command {
  @override
  final name = "view";

  @override
  final aliases = ["v"];

  @override
  final description = "View entries";

  ViewCommand() {
    argParser.addOption(
      "date",
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
        heading: date.format("yyyy-MM-dd"),
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
