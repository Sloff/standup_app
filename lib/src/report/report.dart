import 'dart:io';

import 'package:dart_date/dart_date.dart';

import '../models/models.dart';

Future<void> generateReport(Sprint sprint) async {
  String report = '''
${_markdownHeadingAndList(heading: sprint.formattedSprintName(), list: const Iterable.empty())}

${_markdownHeadingAndList(heading: 'Sprint Goals', headingLevel: 2, list: sprint.goals)}

${_markdownHeadingAndList(heading: 'What went well', headingLevel: 2, list: sprint.wentWell)}

${_markdownHeadingAndList(heading: 'Could be improved', headingLevel: 2, list: sprint.improve)}

${_markdownHeadingAndList(heading: 'Day Entries', headingLevel: 2, list: const Iterable.empty())}
''';

  var dateIterator = sprint.duration.start;

  while (dateIterator.isSameOrBefore(sprint.duration.end)) {
    var tasks = await Data.getTasksOnDate(date: dateIterator);

    if (tasks.isNotEmpty) {
      report += '''

${_markdownHeadingAndList(heading: dateIterator.format('yyyy-MM-dd'), headingLevel: 3, list: tasks.map((e) => e.description))}
''';
    }

    dateIterator = dateIterator.addDays(1);
  }

  var reportsDirectory =
      Directory(Platform.environment['STANDUP_REPORT_DIR'] ?? '.');

  if (!await reportsDirectory.exists()) {
    await reportsDirectory.create(recursive: true);
  }

  final reportFile =
      File('${reportsDirectory.path}/${sprint.formattedSprintName()}.md');

  await reportFile.writeAsString(report);
}

String _markdownHeadingAndList({
  required String heading,
  int headingLevel = 1,
  required Iterable<String> list,
}) {
  String result = '';

  for (int i = 0; i < headingLevel; i++) {
    result += '#';
  }

  result += ' $heading';

  if (list.isNotEmpty) {
    result += '\n';
  }

  list.forEach((element) {
    result += '\n- $element';
  });

  return result;
}
