import 'dart:convert';
import 'dart:io';

import 'package:pocketbase/pocketbase.dart';

void main(List<String> args) async {
  final pb = PocketBase('https://falling-san.pockethost.io');
  stdout.write('email: ');
  final email = stdin.readLineSync();

  stdout.write('password: ');
  final password = stdin.readLineSync();

  await pb.admins.authWithPassword(email?.trim() ?? '', password?.trim() ?? '');
  final collections = await pb.collections.getFullList();
  File('pb_schema.json').writeAsStringSync(json.encode(collections));
}
