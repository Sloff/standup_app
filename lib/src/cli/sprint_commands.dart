import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dart_date/dart_date.dart';
import 'package:interact/interact.dart';
import 'package:standup_app/src/cli/print.dart';
import 'package:tint/tint.dart';

import '/src/models/models.dart';
import '/src/report/report.dart';
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

    await _generateReport(prompt: true);

    var sprint = buildNewSprint(
        name: sprintName,
        dateStartString: argResults?['dateStart'],
        dateEndString: argResults?['dateEnd']);

    await Data.newSprint(sprint: sprint);

    stdout.writeln('Sprint ${sprint.name} started'.green());
  }
}

class SprintCommand extends Command {
  @override
  final name = 'sprint';

  @override
  final aliases = ['s'];

  @override
  final description = 'Sprint specific functionality';

  SprintCommand() {
    addSubcommand(NewCommand());
    addSubcommand(EditSprintCommand());
    addSubcommand(ViewSprintCommand());
    addSubcommand(GenerateSprintCommand());
  }
}

class EditSprintCommand extends Command {
  @override
  final name = 'edit';

  @override
  final aliases = ['e'];

  @override
  final description = "Edit a Sprint's details";

  EditSprintCommand() {
    argParser.addOption('dateStart',
        abbr: 's',
        help: 'The start date of the Sprint',
        valueHelp: 'YYYY-MM-DD');
    argParser.addOption('dateEnd',
        abbr: 'e', help: 'The end date of the Sprint', valueHelp: 'YYYY-MM-DD');
  }

  @override
  Future<void> run() async {
    var currentSprint = await Data.getCurrentSprintDetails();

    if (currentSprint == null) {
      stdout.writeln('No active Sprint'.yellow());
      return;
    }

    var sprintName = argResults?.rest.isNotEmpty ?? false
        ? argResults!.rest.join(' ')
        : Input(
                prompt: 'Sprint name',
                validator: isRequired,
                initialText: currentSprint.name)
            .interact();

    var dateStart = DateTime.parse(argResults?['dateStart'] ??
        Input(
                prompt: 'Start Date',
                validator: isRequired,
                initialText: currentSprint.duration.start.format('yyyy-MM-dd'))
            .interact());

    var dateEnd = DateTime.parse(argResults?['dateEnd'] ??
        Input(
                prompt: 'End Date',
                validator: isRequired,
                initialText:
                    (dateStart + const Duration(days: 14)).format('yyyy-MM-dd'))
            .interact());

    var sprint = Sprint(
        name: sprintName,
        duration: SprintBounds(start: dateStart, end: dateEnd),
        goals: currentSprint.goals,
        wentWell: currentSprint.wentWell,
        improve: currentSprint.improve);

    await Data.editSprint(sprint: sprint);

    stdout.writeln('Sprint ${sprint.name} updated'.green());
  }
}

class ViewSprintCommand extends Command {
  @override
  final name = 'view';

  @override
  final aliases = ['v'];

  @override
  final description = 'View the Sprint details';

  ViewSprintCommand() {
    argParser.addFlag('select',
        abbr: 's', negatable: false, help: 'Select a previous Sprint');
    argParser.addOption(
      'index',
      abbr: 'n',
      help:
          'The zero based index of the previous Sprint (NOTE: Order is from latest to oldest)',
    );
  }

  @override
  Future<void> run() async {
    Sprint? sprint;

    if (argResults!['select'] || argResults?['index'] != null) {
      var previousSprints = (await Data.getPreviousSprints()).reversed.toList();

      if (previousSprints.isEmpty) {
        stdout.writeln('No previous Sprints'.yellow());
        return;
      }

      int selectedSprintIndex = getSelectedEntryIndex(argResults?['index'],
          previousSprints.map((e) => e!.formattedSprintName()).toList());

      sprint = previousSprints[selectedSprintIndex];
    } else {
      sprint = await Data.getCurrentSprintDetails();
    }

    if (sprint == null) {
      stdout.writeln('No active Sprint'.yellow());
      return;
    }

    stdout.writeln(sprint.formattedSprintName().green());

    if (sprint.goals.isNotEmpty) {
      _printHeadingAndGoals(sprint.goals);
    }

    if (sprint.wentWell.isNotEmpty) {
      _printHeadingAndWhatWentWell(sprint.wentWell);
    }

    if (sprint.improve.isNotEmpty) {
      _printHeadingAndImprove(sprint.improve);
    }

    stdout.writeln('\nDay Entries'.underline().yellow());

    bool entriesExist = false;

    var dateIterator = sprint.duration.start;

    while (dateIterator.isSameOrBefore(sprint.duration.end)) {
      var tasks = await Data.getTasksOnDate(date: dateIterator);

      if (tasks.isNotEmpty) {
        entriesExist = true;

        printHeadingAndList(
            heading: dateIterator.format('yyyy-MM-dd'),
            list: tasks.map((e) => e.description));
      }

      dateIterator = dateIterator.addDays(1);
    }

    if (!entriesExist) {
      stdout.writeln('Nothing yet...'.yellow());
    }
  }
}

class GenerateSprintCommand extends Command {
  @override
  final name = 'generate';

  @override
  final aliases = ['g'];

  @override
  final description = 'Generate a markdown report of the Sprint';

  GenerateSprintCommand() {
    argParser.addFlag('select',
        abbr: 's', negatable: false, help: 'Select a previous Sprint');
    argParser.addOption(
      'index',
      abbr: 'n',
      help:
          'The zero based index of the previous Sprint (NOTE: Order is from latest to oldest)',
    );
  }

  @override
  Future<void> run() async {
    Sprint? sprint;

    if (argResults!['select'] || argResults?['index'] != null) {
      var previousSprints = (await Data.getPreviousSprints()).reversed.toList();

      if (previousSprints.isEmpty) {
        stdout.writeln('No previous Sprints'.yellow());
        return;
      }

      int selectedSprintIndex = getSelectedEntryIndex(argResults?['index'],
          previousSprints.map((e) => e!.formattedSprintName()).toList());

      sprint = previousSprints[selectedSprintIndex];
    } else {
      sprint = await Data.getCurrentSprintDetails();
    }

    if (sprint == null) {
      stdout.writeln('No active Sprint'.yellow());
      return;
    }

    await _generateReport(sprint: sprint);
  }
}

Future<void> _generateReport({Sprint? sprint, bool prompt = false}) async {
  var sprintToGenerate = sprint ?? await Data.getCurrentSprintDetails();

  if (sprintToGenerate == null) {
    return;
  }

  if (prompt) {
    if (!Confirm(
      prompt: 'Generate a Report of the current Sprint?',
      defaultValue: true,
      waitForNewLine: true,
    ).interact()) {
      return;
    }
  }

  stdout.writeln('Generating report...');

  await generateReport(sprintToGenerate);

  stdout.writeln('Report saved');
}

Future<void> noActiveSprint() async {
  bool createNewSprint = Confirm(
    prompt: 'No current active Sprint, do you want to create a new Sprint?',
    defaultValue: true,
    waitForNewLine: true,
  ).interact();

  if (createNewSprint) {
    await _generateReport(prompt: true);
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

Future<void> addGoal(ArgResults? argResults) async {
  await genericAdd(
      argResults, 'Goal Description', Data.addGoal, _printHeadingAndGoals);
}

Future<void> viewGoals() async {
  await genericView(Data.getGoals, _printHeadingAndGoals);
}

Future<void> editGoal(ArgResults? argResults) async {
  await genericEdit(argResults, 'Goal', Data.getGoals, Data.editGoalWithIndex,
      _printHeadingAndGoals);
}

Future<void> removeGoal(ArgResults? argResults) async {
  await genericRemove(argResults, Data.getGoals, Data.removeGoalWithIndex,
      _printHeadingAndGoals);
}

Future<void> addWentWell(ArgResults? argResults) async {
  await genericAdd(argResults, 'What went well', Data.addWentWell,
      _printHeadingAndWhatWentWell);
}

Future<void> viewWentWell() async {
  await genericView(Data.getWentWell, _printHeadingAndWhatWentWell);
}

Future<void> editWentWell(ArgResults? argResults) async {
  await genericEdit(argResults, 'New Description', Data.getWentWell,
      Data.editWentWellWithIndex, _printHeadingAndWhatWentWell);
}

Future<void> removeWentWell(ArgResults? argResults) async {
  await genericRemove(argResults, Data.getWentWell,
      Data.removeWentWellWithIndex, _printHeadingAndWhatWentWell);
}

Future<void> addImprove(ArgResults? argResults) async {
  await genericAdd(argResults, 'What could be Improved', Data.addImprove,
      _printHeadingAndImprove);
}

Future<void> viewImprove() async {
  await genericView(Data.getImprove, _printHeadingAndImprove);
}

Future<void> editImprove(ArgResults? argResults) async {
  await genericEdit(argResults, 'New Description', Data.getImprove,
      Data.editImproveWithIndex, _printHeadingAndImprove);
}

Future<void> removeImprove(ArgResults? argResults) async {
  await genericRemove(argResults, Data.getImprove, Data.removeImproveWithIndex,
      _printHeadingAndImprove);
}

Future<void> genericAdd(ArgResults? argResults, String prompt, Function addFn,
    Function printFn) async {
  var newEntry = argResults?.rest.isNotEmpty ?? false
      ? argResults!.rest.join(' ')
      : Input(prompt: prompt, validator: isRequired).interact();

  var entries = await addFn(newEntry);

  printFn(entries);
}

Future<void> genericView(Function getEntriesFn, Function printFn) async {
  var entries = await getEntriesFn();

  printFn(entries);
}

Future<void> genericEdit(
    ArgResults? argResults,
    String prompt,
    Function getEntriesFn,
    Function editEntryWithIndex,
    Function printFn) async {
  List<String> entries = await getEntriesFn();

  if (entries.isEmpty) {
    stdout.writeln('Nothing to edit'.yellow());
    return;
  }

  stdout.writeln('');
  int entryToEditIndex = getSelectedEntryIndex(argResults?['index'], entries);

  String newEntry = argResults?.rest.isNotEmpty ?? false
      ? argResults!.rest.join(' ')
      : Input(
              prompt: prompt,
              initialText: entries[entryToEditIndex],
              validator: isRequired)
          .interact();

  var newEntries = await editEntryWithIndex(entryToEditIndex, newEntry);

  printFn(newEntries);
}

Future<void> genericRemove(ArgResults? argResults, Function getEntriesFn,
    Function removeEntryFn, Function printFn) async {
  List<String> entries = await getEntriesFn();

  if (entries.isEmpty) {
    stdout.writeln('Nothing to remove'.yellow());
    return;
  }

  int entryToRemoveIndex = getSelectedEntryIndex(argResults?['index'], entries);

  var newEntries = await removeEntryFn(entryToRemoveIndex);

  printFn(newEntries);
}

void _printHeadingAndGoals(List<String> goals) {
  printHeadingAndList(heading: 'Sprint Goals', list: goals);
}

void _printHeadingAndWhatWentWell(List<String> wentWell) {
  printHeadingAndList(heading: 'What went well', list: wentWell);
}

void _printHeadingAndImprove(List<String> improved) {
  printHeadingAndList(heading: 'Could be Improved', list: improved);
}
