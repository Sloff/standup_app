// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sprint _$SprintFromJson(Map<String, dynamic> json) => Sprint(
      name: json['name'] as String,
      duration: SprintBounds.fromJson(json['duration'] as Map<String, dynamic>),
      goals:
          (json['goals'] as List<dynamic>?)?.map((e) => e as String).toList(),
      wentWell: (json['wentWell'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      improve:
          (json['improve'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$SprintToJson(Sprint instance) => <String, dynamic>{
      'name': instance.name,
      'duration': instance.duration,
      'goals': instance.goals,
      'wentWell': instance.wentWell,
      'improve': instance.improve,
    };

SprintBounds _$SprintBoundsFromJson(Map<String, dynamic> json) => SprintBounds(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
    );

Map<String, dynamic> _$SprintBoundsToJson(SprintBounds instance) =>
    <String, dynamic>{
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
    };
