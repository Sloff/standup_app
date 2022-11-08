import 'dart:io';

import 'package:dart_date/dart_date.dart';
import 'package:interact/interact.dart';

import '/src/utils/utils.dart' as utils;

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

Future<DateTime> parseDateTime(String dateString) async {
  if (dateString == 'p' || dateString == 'prev') {
    return (await utils.getPreviousDayDate())!;
  } else if (dateString == 'y' || dateString == 'yesterday') {
    return Date.startOfToday.subDays(1);
  } else if (dateString == 't' || dateString == 'today') {
    return Date.startOfToday;
  }

  return DateTime.parse(dateString);
}
