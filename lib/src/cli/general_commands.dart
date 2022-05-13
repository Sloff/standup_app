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
    argParser.addFlag('well',
        abbr: 'w', negatable: false, help: 'Add something that went well');
    argParser.addFlag('improve',
        abbr: 'i',
        negatable: false,
        help: 'Add something that could be improved');
  }

  @override
  Future<void> run() async {
    if (await Data.sprintStatus() != SprintStatus.active) {
      await sprint.noActiveSprint();
    }

    if (argResults!['goal']) {
      return sprint.addGoal(argResults);
    }

    if (argResults!['well']) {
      return sprint.addWentWell(argResults);
    }

    if (argResults!['improve']) {
      return sprint.addImprove(argResults);
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
    argParser.addFlag('goal',
        abbr: 'g', negatable: false, help: 'View the Goal entries');
    argParser.addFlag('well',
        abbr: 'w',
        negatable: false,
        help: 'View what went well during the Sprint');
    argParser.addFlag('improve',
        abbr: 'i', negatable: false, help: 'View what could be improved');
  }

  @override
  Future<void> run() async {
    if (argResults!['goal']) {
      return sprint.viewGoals();
    }

    if (argResults!['well']) {
      return sprint.viewWentWell();
    }

    if (argResults!['improve']) {
      return sprint.viewImprove();
    }

    return task.view(argResults);
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
      abbr: 'n',
      help: 'The zero based index of the entry',
    );
    argParser.addFlag('goal',
        abbr: 'g', negatable: false, help: 'Edit a Goal entry');
    argParser.addFlag('well',
        abbr: 'w', negatable: false, help: 'Edit something that went well');
    argParser.addFlag('improve',
        abbr: 'i',
        negatable: false,
        help: 'Edit something that could be improved');
  }

  @override
  Future<void> run() async {
    if (argResults!['goal']) {
      return sprint.editGoal(argResults);
    }

    if (argResults!['well']) {
      return sprint.editWentWell(argResults);
    }

    if (argResults!['improve']) {
      return sprint.editImprove(argResults);
    }

    return task.edit(argResults);
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
      abbr: 'n',
      help: 'The zero based index of the entry',
    );
    argParser.addFlag('goal',
        abbr: 'g', negatable: false, help: 'Remove a Goal entry');
    argParser.addFlag('well',
        abbr: 'w', negatable: false, help: 'Remove something that went well');
    argParser.addFlag('improve',
        abbr: 'i',
        negatable: false,
        help: 'Remove something that could be improved');
  }

  @override
  Future<void> run() async {
    if (argResults!['goal']) {
      return sprint.removeGoal(argResults);
    }

    if (argResults!['well']) {
      return sprint.removeWentWell(argResults);
    }

    if (argResults!['improve']) {
      return sprint.removeImprove(argResults);
    }

    return task.remove(argResults);
  }
}
