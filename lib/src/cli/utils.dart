import 'dart:io';

import 'package:interact/interact.dart';

bool isRequired(String val) {
  if (val.isNotEmpty) {
    return true;
  }

  throw ValidationError('A description is required');
}

int getSelectedEntryIndex(String? indexString, List<String> entries) {
  int selectedEntryIndex;

  if ((indexString ?? '').isNotEmpty) {
    selectedEntryIndex = int.parse(indexString!);
  } else {
    stdout.writeln('');
    selectedEntryIndex = Select(
      prompt: 'Please select an entry',
      options: entries,
    ).interact();
  }

  return selectedEntryIndex;
}
