import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

void submit(Router app, DbCollection usersSessions, DbCollection submissions) {
  app.post('/submit', (Request request) async {
    final data = json.decode(await request.readAsString());
    final session = data['session'];
    final submission = data['submission'];

    if (session == null) {
      return Response.forbidden(
        json.encode({'message': 'No session provided'}),
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
        json.encode({'message': 'Unauthorized user'}),
        headers: {'content-type': 'application/json'},
      );
    } else {
      var userSubmission = {
        'username': username,
        'role': role,
        'submission': submission,
        'status': 'Pending Review',
      };

      await submissions.insertOne({
        'username': userSubmission['username'],
        'role': userSubmission['role'],
        'submission': userSubmission['submission'],
        'status': userSubmission['status'],
      });

      return Response.ok(
        json.encode({'message': 'Submission saved'}),
        headers: {'content-type': 'application/json'},
      );
    }
  });
}

void getUserSubmission(
  Router app,
  DbCollection usersSessions,
  DbCollection submissions,
) {
  app.get('/submissions', (Request request) async {
    final data = json.decode(await request.readAsString());
    final session = data['session'];

    if (session == null) {
      return Response.forbidden(
        json.encode({'message': 'No session provided'}),
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
        json.encode({'message': 'Unauthorized user'}),
        headers: {'content-type': 'application/json'},
      );
    } else {
      var userSubmissions = await submissions
          .find(where.eq('username', username).eq('role', role))
          .toList();
      return Response.ok(
        json.encode(userSubmissions),
        headers: {'content-type': 'application/json'},
      );
    }
  });
}
