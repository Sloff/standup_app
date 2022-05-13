import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dart_date/dart_date.dart';
import 'package:interact/interact.dart';
import 'package:tint/tint.dart';

import '/src/models/models.dart';
import 'utils.dart';

class NewCommand extends Command {
  @override
  final name = 'new';

  @override
  final aliases = ['n'];

  @override
  final description = 'Start a new Sprint';

  NewCommand() {
    argParser.addOption('dateStart',
        abbr: 's',
        help: 'The start date of the Sprint',
        valueHelp: 'YYYY-MM-DD');
    argParser.addOption('dateEnd',
        abbr: 'e', help: 'The end date of the Sprint', valueHelp: 'YYYY-MM-DD');
  }

  @override
  void run() async {
    var sprintName = argResults?.rest.isNotEmpty ?? false
        ? argResults!.rest.join(' ')
        : null;

    var sprint = buildNewSprint(
        name: sprintName,
        dateStartString: argResults?['dateStart'],
        dateEndString: argResults?['dateEnd']);

    await Data.newSprint(sprint: sprint);

    stdout.writeln('Sprint ${sprint.name} started'.green());
  }
}

Future<void> noActiveSprint() async {
  bool createNewSprint = Confirm(
    prompt: 'No current active Sprint, do you want to create a new Sprint?',
    defaultValue: true,
    waitForNewLine: true,
  ).interact();

  if (createNewSprint) {
    Sprint sprint = buildNewSprint();
    await Data.newSprint(sprint: sprint);

    stdout.writeln('Sprint ${sprint.name} started'.green());
  }
}

Sprint buildNewSprint(
    {String? name, String? dateStartString, String? dateEndString}) {
  var sprintName =
      name ?? Input(prompt: 'Sprint name', validator: isRequired).interact();

  var dateStart = DateTime.parse(dateStartString ??
      Input(
              prompt: 'Start Date',
              validator: isRequired,
              initialText: DateTime.now().format('yyyy-MM-dd'))
          .interact());

  var dateEnd = DateTime.parse(dateEndString ??
      Input(
              prompt: 'End Date',
              validator: isRequired,
              initialText:
                  (dateStart + const Duration(days: 14)).format('yyyy-MM-dd'))
          .interact());

  return Sprint(
      name: sprintName, duration: SprintBounds(start: dateStart, end: dateEnd));
}
