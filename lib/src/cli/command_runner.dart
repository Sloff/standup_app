import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:tint/tint.dart';

import './task_commands.dart';

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
