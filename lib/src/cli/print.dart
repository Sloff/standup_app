import 'dart:io';

import 'package:dcli/dcli.dart';

void printHeadingAndList(
    {required String heading,
    required Iterable<String> list,
    bool leadingSpace = true}) {
  if (leadingSpace) {
    stdout.writeln();
  }

  stdout.writeln(green("$heading:"));

  if (list.isEmpty) {
    stdout.writeln(yellow("Nothing yet..."));
  } else {
    list.map((e) => "  - ${e}").forEach(stdout.writeln);
  }
}
