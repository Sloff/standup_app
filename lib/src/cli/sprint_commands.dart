import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dart_date/dart_date.dart';
import 'package:interact/interact.dart';
import 'package:standup_app/src/cli/print.dart';
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
  await genericAdd(argResults, 'What Went Well', Data.addWentWell,
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
  printHeadingAndList(heading: 'What Went Well', list: wentWell);
}

void _printHeadingAndImproved(List<String> improved) {
  printHeadingAndList(heading: 'Could be Improved', list: improved);
}
