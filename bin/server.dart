import 'dart:io';
import 'package:dotenv/dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:turnin_backend/public.dart';
import 'package:turnin_backend/reviewer.dart';
import 'package:turnin_backend/student.dart';

// Configure routes.
final _router = Router();

void main(List<String> args) async {
  var env = DotEnv(includePlatformEnvironment: true)
    ..load(['C:\\Users\\USER\\turnin_backend\\.env']);

  var dbString = env['TurnInDB'];
  Db db = Db(dbString as String);

  await db.open();
  print('Database connected');

  DbCollection users = DbCollection(db, 'users');
  DbCollection usersSessions = DbCollection(db, 'usersSessions');
  DbCollection submissions = DbCollection(db, 'submissions');

  register(_router, users, usersSessions);
  login(_router, users, usersSessions);
  submit(_router, usersSessions, submissions);
  getUserSubmission(_router, usersSessions, submissions);
  getAnySubmissions(_router, usersSessions, submissions);

  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(_router.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
