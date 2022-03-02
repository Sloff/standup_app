import 'dart:io';

import 'package:tint/tint.dart';

void printHeadingAndList(
    {required String heading,
    required Iterable<String> list,
    bool leadingSpace = true}) {
  if (leadingSpace) {
    stdout.writeln();
  }

  stdout.writeln('$heading:'.green());

  if (list.isEmpty) {
    stdout.writeln('Nothing yet...'.yellow());
  } else {
    list.map((e) => '  - ${e}').forEach(stdout.writeln);
  }
}
