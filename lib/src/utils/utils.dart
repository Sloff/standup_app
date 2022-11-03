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

  if (weekDiff <= 7 && weekDiff > 0) {
    return 'Last week ${date.format("EEEE")} I worked on';
  }

  if (weekDiff > 7) {
    String timeAgo = date.timeago();
    timeAgo = timeAgo[0].toUpperCase() + timeAgo.substring(1);
    return '$timeAgo on ${date.format("EEEE")} I worked on';
  }

  return 'On ${date.format("EEEE")} I worked on';
}
