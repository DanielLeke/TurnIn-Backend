import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

String _hashPassword(String password, String salt) {
  var key = utf8.encode(password);
  var bytes = utf8.encode(salt);

  var hmacSha256 = Hmac(sha256, key);
  var digest = hmacSha256.convert(bytes);

  return digest.toString();
}

void register(Router app, DbCollection users, DbCollection usersSessions) {
  app.post('/register', (Request request) async {
    final data = jsonDecode(await request.readAsString());
    var username = data['username'];
    var password = data['password'];
    var role = data['role'];

    var rand = Random();
    var saltBytes = List<int>.generate(32, (_) => rand.nextInt(256));
    var salt = base64.encode(saltBytes);

    var hashedPassword = _hashPassword(password, salt);

    var userDocument = {
      'username': username,
      'hashedPassword': hashedPassword,
      'salt': salt,
      'role': role,
    };
    await users.insertOne({
      'username': userDocument['username'],
      'hashedPassword': userDocument['hashedPassword'],
      'salt': userDocument['salt'],
      'role': userDocument['role'],
    });

    var userSession = {
      'username': username,
      'sessionToken': Uuid().v4(),
      'role': role,
    };
    var encodedSession = base64.encode(utf8.encode(json.encode(userSession)));

    await usersSessions.insertOne({
      'username': userSession['username'],
      'sessionToken': userSession['sessionToken'],
      'role': userSession['role'],
    });

    return Response.ok(
      "{'session': $encodedSession}",
      headers: {'content-type': 'application/json'},
    );
  });
}

void login(Router app, DbCollection users, DbCollection usersSessions) {
  app.post('/login', (Request request) async {
    final data = jsonDecode(await request.readAsString());
    var username = data['username'];
    var password = data['password'];
    var role = data['role'];

    var user = await users.findOne(where.eq('username', username));
    if (user == null) {
      return Response.notFound(
        'User not found',
        headers: {'content-type': 'application/json'},
      );
    }
    var salt = user['salt'];
    var hashedPassword = user['hashedPassword'];
  });
}
