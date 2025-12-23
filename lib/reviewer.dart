import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

void getAnySubmissions(
  Router app,
  DbCollection usersSessions,
  DbCollection submissions,
) {
  app.get('/submissions/<id>', (Request request, String id) async {
    final data = jsonDecode(await request.readAsString());
    final session = data['session'];

    if (session == null) {
      return Response.forbidden(
        jsonEncode({'message': 'No session provided'}),
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
        jsonEncode({'message': 'Unauthorized user'}),
        headers: {'content-type': 'application/json'},
      );
    } else {
      if (role != "Reviewer") {
        return Response.forbidden(
          jsonEncode({'message': 'Unauthorized for this request'}),
        );
      }
      var theSubmissions = id == "all"
          ? await submissions.find().toList()
          : await submissions.findOne(
              where.eq('_id', ObjectId.fromHexString(id)),
            );
      return Response.ok(
        jsonEncode(theSubmissions),
        headers: {'content-type': 'application/json'},
      );
    }
  });
}

void updateStatus(
  Router app,
  DbCollection usersSessions,
  DbCollection submissions,
) {
  app.patch('/submissions/<id>', (Request request, String id) async {
    final data = jsonDecode(await request.readAsString());
    final session = data['session'];

    if (session == null) {
      return Response.forbidden(
        jsonEncode({'message': 'No session provided'}),
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
        jsonEncode({'message': 'Unauthorized user'}),
        headers: {'content-type': 'application/json'},
      );
    } else {
      if (role != "Reviewer") {
        return Response.forbidden(
          jsonEncode({'message': 'Unauthorized for this request'}),
        );
      }

      await submissions.updateOne(where.eq('_id', ObjectId.fromHexString(id)), {
        r'$set: {status: Reviewed}',
      });
      return Response.ok(
        jsonEncode({'success': 'status updated'}),
        headers: {'content-type': 'application/json'},
      );
    }
  });
}
