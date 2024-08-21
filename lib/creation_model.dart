import 'package:flutter/material.dart';

class CreationModel {
  const CreationModel({required this.data});

  factory CreationModel.fromJson(Map<String, dynamic> source) {
    if (source case {'data': final List<dynamic> data}) {
      return CreationModel(
        data: data
            .map((c) => (c as List<dynamic>).cast<int?>())
            .map(
              (r) => r
                  .map((value) => value == null ? null : Color(value))
                  .toList(),
            )
            .toList(),
      );
    }

    throw UnsupportedError(
      'The format of the response is not supported.\n$source',
    );
  }
  final List<List<Color?>> data;
}
