import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

import './task.dart';

part 'data.g.dart';

@JsonSerializable()
class Data {
  Map<DateTime, List<Task>> days;

  Data({required this.days});

  Data.empty() : days = {};

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);

  static Future<Data> loadDataFile() async {
    final dataFile = File('data.json');

    if (!await dataFile.exists()) {
      return Data.empty();
    }

    final jsonData = await dataFile.readAsString();

    return Data.fromJson(json.decode(jsonData));
  }

  Future<void> save() async {
    final dataFile = File('data.json');

    JsonEncoder encoder = const JsonEncoder.withIndent('  ');

    await dataFile.writeAsString(encoder.convert(this));
  }
}
