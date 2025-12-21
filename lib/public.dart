import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

void register(Router app, DbCollection users, DbCollection usersSessions) {
  app.post('/register', (Request request) async {
    final data = jsonDecode(await request.readAsString());
    var username = data['username'];
    var password = data['password'];
    var role = data['role'];

    var document = {};
    return Response.ok('User registered');
  });
}
