import 'package:args/command_runner.dart';
import 'package:dart_date/dart_date.dart';

import '/src/models/models.dart';
import 'sprint_commands.dart' as sprint;
import 'task_commands.dart' as task;

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
    argParser.addFlag('goal',
        abbr: 'g', negatable: false, help: 'Add a Goal entry');
  }

  @override
  Future<void> run() async {
    if (await Data.sprintStatus() != SprintStatus.active) {
      await sprint.noActiveSprint();
    }

    if (argResults!['goal']) {
      return sprint.addGoal(argResults);
    }

    return task.add(argResults);
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
    await task.view(argResults);
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
    await task.edit(argResults);
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
    await task.remove(argResults);
  }
}
