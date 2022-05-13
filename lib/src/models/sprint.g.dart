// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sprint _$SprintFromJson(Map<String, dynamic> json) => Sprint(
      name: json['name'] as String,
      duration: Duration.fromJson(json['duration'] as Map<String, dynamic>),
      goal: (json['goal'] as List<dynamic>?)?.map((e) => e as String).toList(),
      wentWell: (json['wentWell'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      improve:
          (json['improve'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$SprintToJson(Sprint instance) => <String, dynamic>{
      'name': instance.name,
      'duration': instance.duration,
      'goal': instance.goal,
      'wentWell': instance.wentWell,
      'improve': instance.improve,
    };

Duration _$DurationFromJson(Map<String, dynamic> json) => Duration(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
    );

Map<String, dynamic> _$DurationToJson(Duration instance) => <String, dynamic>{
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
    };
