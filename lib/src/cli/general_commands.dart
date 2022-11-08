import 'package:args/args.dart';
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
    _addGeneralOptionsAndFlags(argParser,
        dateHelp: 'The date of the entry.',
        goalHelp: 'Add a Goal entry.',
        wentWellHelp: 'Add something that went well.',
        improveHelp: 'Add something that could be improved.');
  }

  @override
  Future<void> run() async {
    if (await Data.sprintStatus() != SprintStatus.active) {
      await sprint.noActiveSprint();
    }

    return _runFunctionBySetFlag(argResults,
        goalFn: sprint.addGoal,
        wentWellFn: sprint.addWentWell,
        improveFn: sprint.addImprove,
        taskFn: task.add);
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
    _addGeneralOptionsAndFlags(argParser,
        dateHelp: 'The date of the entry.',
        defaultDate: false,
        goalHelp: 'View the Goal entries.',
        wentWellHelp: 'View what went well during the Sprint.',
        improveHelp: 'View what could be improved.');
  }

  @override
  Future<void> run() async {
    return _runFunctionBySetFlag(argResults,
        goalFn: sprint.viewGoals,
        wentWellFn: sprint.viewWentWell,
        improveFn: sprint.viewImprove,
        taskFn: task.view,
        sendArgResultsThrough: false);
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
    _addGeneralOptionsAndFlags(argParser,
        dateHelp: 'The date of the entry.',
        goalHelp: 'Edit a Goal entry.',
        wentWellHelp: 'Edit something that went well.',
        improveHelp: 'Edit something that could be improved.',
        addIndex: true);
  }

  @override
  Future<void> run() async {
    return _runFunctionBySetFlag(argResults,
        goalFn: sprint.editGoal,
        wentWellFn: sprint.editWentWell,
        improveFn: sprint.editImprove,
        taskFn: task.edit);
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
    _addGeneralOptionsAndFlags(
      argParser,
      dateHelp: 'The date of the entry.',
      goalHelp: 'Remove a Goal entry.',
      wentWellHelp: 'Remove something that went well.',
      improveHelp: 'Remove something that could be improved.',
      addIndex: true,
    );
  }

  @override
  Future<void> run() async {
    return _runFunctionBySetFlag(argResults,
        goalFn: sprint.removeGoal,
        wentWellFn: sprint.removeWentWell,
        improveFn: sprint.removeImprove,
        taskFn: task.remove);
  }
}

class CopyCommand extends Command {
  @override
  final name = 'copy';

  @override
  final aliases = ['c'];

  @override
  final description = 'Copy an Entry';

  CopyCommand() {
    argParser.addOption('dateFrom',
        abbr: 'f',
        help: 'Date to copy from.',
        valueHelp: 'YYYY-MM-DD or (p|prev|y|yesterday|t|today)');
    argParser.addOption('dateTo',
        abbr: 't',
        help: 'Date to copy to.',
        valueHelp: 'YYYY-MM-DD or (p|prev|y|yesterday|t|today)');
    argParser.addOption(
      'index',
      abbr: 'n',
      help: 'The zero based index of the entry.',
    );
  }

  @override
  Future<void> run() async {
    return task.copy(argResults);
  }
}

class MoveCommand extends Command {
  @override
  final name = 'move';

  @override
  final aliases = ['m'];

  @override
  final description = 'Move an Entry';

  MoveCommand() {
    argParser.addOption('dateFrom',
        abbr: 'f', help: 'Date to copy from.', valueHelp: 'YYYY-MM-DD');
    argParser.addOption('dateTo',
        abbr: 't', help: 'Date to copy to.', valueHelp: 'YYYY-MM-DD');
    argParser.addOption(
      'index',
      abbr: 'n',
      help: 'The zero based index of the entry.',
    );
  }

  @override
  Future<void> run() async {
    return task.move(argResults);
  }
}

void _addGeneralOptionsAndFlags(
  ArgParser argParser, {
  required String dateHelp,
  bool defaultDate = true,
  required String goalHelp,
  required String wentWellHelp,
  required String improveHelp,
  bool addIndex = false,
  String indexHelp = 'The zero based index of the entry.',
}) {
  argParser.addOption('date',
      abbr: 'd',
      help: dateHelp,
      valueHelp: 'YYYY-MM-DD or (p|prev|y|yesterday|t|today)',
      defaultsTo: defaultDate ? DateTime.now().format('yyyy-MM-dd') : null);
  argParser.addFlag('goal', abbr: 'g', negatable: false, help: goalHelp);
  argParser.addFlag('well', abbr: 'w', negatable: false, help: wentWellHelp);
  argParser.addFlag('improve', abbr: 'i', negatable: false, help: improveHelp);

  if (addIndex) {
    argParser.addOption(
      'index',
      abbr: 'n',
      help: indexHelp,
    );
  }
}

Future<void> _runFunctionBySetFlag(
  ArgResults? argResults, {
  required Function goalFn,
  required Function wentWellFn,
  required Function improveFn,
  required Function taskFn,
  bool sendArgResultsThrough = true,
}) {
  if (argResults!['goal']) {
    return sendArgResultsThrough ? goalFn(argResults) : goalFn();
  }

  if (argResults['well']) {
    return sendArgResultsThrough ? wentWellFn(argResults) : wentWellFn();
  }

  if (argResults['improve']) {
    return sendArgResultsThrough ? improveFn(argResults) : improveFn();
  }

  return taskFn(argResults);
}
