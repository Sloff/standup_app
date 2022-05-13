import 'package:json_annotation/json_annotation.dart';

part 'sprint.g.dart';

@JsonSerializable()
class Sprint {
  String name;
  SprintBounds duration;
  List<String> goal = [];
  List<String> wentWell = [];
  List<String> improve = [];

  Sprint(
      {required this.name,
      required this.duration,
      List<String>? goal,
      List<String>? wentWell,
      List<String>? improve})
      : goal = goal ?? [],
        wentWell = wentWell ?? [],
        improve = improve ?? [];

  factory Sprint.fromJson(Map<String, dynamic> json) => _$SprintFromJson(json);

  Map<String, dynamic> toJson() => _$SprintToJson(this);
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
