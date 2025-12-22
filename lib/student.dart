import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

void submit(Router app, DbCollection usersSessions, DbCollection submissions) {
  app.post('/submit', (Request request) async {
    final data = jsonDecode(await request.readAsString());
    final session = data['session'];
    final submission = data['submission'];

    final decodedSession = json.decode(utf8.decode(base64.decode(session)));
  });
}
