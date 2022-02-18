import 'dart:io';
import 'dart:convert';
import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';
import 'package:dart_date/dart_date.dart';

import 'package:standup_app/src/entry/entry.dart';

void commandRunner(List<String> args) {
  var runner =
      CommandRunner("standup", "Assists with keeping track of work for standup")
        ..addCommand(AddCommand());

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
  void run() {
    var entryDescription = argResults?.rest.isNotEmpty ?? false
        ? argResults!.rest.join(' ')
        : ask(green("Description:"), required: true);

    var dateOfEntry = DateTime.parse(argResults!['date']);

    var task = Task(description: entryDescription, date: dateOfEntry);
    print(json.encode(task));
  }
}
