// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Data _$DataFromJson(Map<String, dynamic> json) => Data(
      days: (json['days'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(DateTime.parse(k),
            (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      tasks: (json['tasks'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Task.fromJson(e as Map<String, dynamic>)),
      ),
      currentSprint: json['currentSprint'] == null
          ? null
          : Sprint.fromJson(json['currentSprint'] as Map<String, dynamic>),
      previousSprints: (json['previousSprints'] as List<dynamic>?)
          ?.map((e) => Sprint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'days': instance.days.map((k, e) => MapEntry(k.toIso8601String(), e)),
      'tasks': instance.tasks,
      'currentSprint': instance.currentSprint,
      'previousSprints': instance.previousSprints,
    };
