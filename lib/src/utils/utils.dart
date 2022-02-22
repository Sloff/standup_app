import 'package:dart_date/dart_date.dart';

String getRelativeDateHeading(DateTime date) {
  if (date.isYesterday) {
    return 'Yesterday I worked on';
  }

  // subDays used to shift the first day of a week to Monday, instead of Sunday
  var weekDiff = Date.startOfToday
      .subDays(1)
      .startOfWeek
      .diff(date.subDays(1).startOfWeek)
      .inDays;

  if (weekDiff <= 7) {
    return 'Last week on ${date.format("EEEE")} I worked on';
  }

  if (weekDiff > 7) {
    return '${date.timeago()} on ${date.format("EEEE")} I worked on';
  }

  return 'On ${date.format("EEEE")} I worked on';
}
