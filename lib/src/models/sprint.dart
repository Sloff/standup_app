import 'package:json_annotation/json_annotation.dart';

part 'sprint.g.dart';

@JsonSerializable()
class Sprint {
  String name;
  Duration duration;
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
class Duration {
  DateTime start;
  DateTime end;

  Duration({required this.start, required this.end});

  factory Duration.fromJson(Map<String, dynamic> json) =>
      _$DurationFromJson(json);

  Map<String, dynamic> toJson() => _$DurationToJson(this);
}
