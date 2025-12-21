import 'dart:convert';

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

    var document = {};
    return Response.ok('User registered');
  });
}
