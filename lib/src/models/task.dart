import 'package:json_annotation/json_annotation.dart';

part 'task.g.dart';

@JsonSerializable()
class Task {
  String description;
  String? details;

  Task({required this.description, this.details});

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToJson(this);
}

class TaskWithId extends Task {
  String id;

  TaskWithId({required this.id, required String description, details})
      : super(description: description, details: details);

  factory TaskWithId.fromTask({required String id, required Task task}) {
    return TaskWithId(
        id: id, description: task.description, details: task.details);
  }
}
