import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

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

    var document = {
      'username': username,
      'hashedPassword': hashedPassword,
      'salt': salt,
      'role': role,
    };
    await users.insertOne({
      'username': document['username'],
      'hashedPassword': document['hashedPassword'],
      'salt': document['salt'],
      'role': document['role'],
    });
    return Response.ok('User registered');
  });
}
