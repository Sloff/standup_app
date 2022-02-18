// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Data _$DataFromJson(Map<String, dynamic> json) => Data(
      days: (json['days'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            DateTime.parse(k), Task.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'days': instance.days.map((k, e) => MapEntry(k.toIso8601String(), e)),
    };
