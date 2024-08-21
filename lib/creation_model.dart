import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class CreationModel {
  const CreationModel({
    required this.data,
    this.user,
  });

  factory CreationModel.fromJson(Map<String, dynamic> source) {
    final maybeUser = source['user'];
    String? username;
    if (maybeUser is List<RecordModel>) {
      final maybeUsername = maybeUser.firstOrNull?.data['username'];
      if (maybeUsername is String) username = maybeUsername;
    }
    if (source case {'data': final List<dynamic> data}) {
      return CreationModel(
        user: username,
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
  final String? user;
}
