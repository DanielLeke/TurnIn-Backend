import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

void getAllSubmissions(
  Router app,
  DbCollection usersSessions,
  DbCollection submissions,
) {
  app.get('/submissions/all', (Request request) async {
    final data = jsonDecode(await request.readAsString());
    final session = data['session'];

    if (session == null) {
      return Response.forbidden(
        'No session provided',
        headers: {'content-type': 'application/json'},
      );
    }

    final decodedSession = json.decode(utf8.decode(base64.decode(session)));
    final username = decodedSession['username'];
    final sessionToken = decodedSession['sessionToken'];
    final role = decodedSession['role'];

    var userSession = await usersSessions.findOne(
      where
          .eq('username', username)
          .eq('sessionToken', sessionToken)
          .eq('role', role),
    );

    if (userSession == null) {
      return Response.forbidden(
        'Unauthorized user',
        headers: {'content-type': 'application/json'},
      );
    }
  });
}
