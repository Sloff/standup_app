import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:tint/tint.dart';

import 'general_commands.dart' as general;
import 'sprint_commands.dart' as sprint;

void commandRunner(List<String> args) {
  var runner =
      CommandRunner('standup', 'Assists with keeping track of work for standup')
        ..addCommand(general.AddCommand())
        ..addCommand(general.ViewCommand())
        ..addCommand(general.EditCommand())
        ..addCommand(general.RemoveCommand())
        ..addCommand(general.CopyCommand())
        ..addCommand(general.MoveCommand())
        ..addCommand(sprint.NewCommand())
        ..addCommand(sprint.SprintCommand());

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
      case RangeError:
        {
          stderr.writeln('Index provided out of bounds'.yellow());
          exit(64);
        }
      default:
        throw error;
    }
  });
}
