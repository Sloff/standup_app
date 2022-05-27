import 'package:dart_date/dart_date.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sprint.g.dart';

@JsonSerializable()
class Sprint {
  String name;
  SprintBounds duration;
  List<String> goals = [];
  List<String> wentWell = [];
  List<String> improve = [];

  Sprint(
      {required this.name,
      required this.duration,
      List<String>? goals,
      List<String>? wentWell,
      List<String>? improve})
      : goals = goals ?? [],
        wentWell = wentWell ?? [],
        improve = improve ?? [];

  factory Sprint.fromJson(Map<String, dynamic> json) => _$SprintFromJson(json);

  Map<String, dynamic> toJson() => _$SprintToJson(this);

  String formattedSprintName() {
    return 'Sprint $name (${duration.start.format('yyyy-MM-dd')} - ${duration.end.format('yyyy-MM-dd')})';
  }
}

@JsonSerializable()
class SprintBounds {
  DateTime start;
  DateTime end;

  SprintBounds({required this.start, required this.end});

  factory SprintBounds.fromJson(Map<String, dynamic> json) =>
      _$SprintBoundsFromJson(json);

  Map<String, dynamic> toJson() => _$SprintBoundsToJson(this);
}
