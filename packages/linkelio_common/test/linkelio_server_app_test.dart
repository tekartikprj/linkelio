import 'dart:typed_data';

import 'package:linkelio_common/firestore/firestore_database.dart';
import 'package:linkelio_common/model/fs_link.dart';
import 'package:linkelio_common/server/linkelio_server_app.dart';
import 'package:test/test.dart';
import 'package:tkcms_common/tkcms_firebase.dart';
import 'package:tkcms_common/tkcms_flavor.dart';
import 'package:tkcms_common/tkcms_server.dart';

/// The request the link function gets, [uri] as the runtime gives it
/// (percent encoded).
class _Request implements ExpressHttpRequest {
  @override
  final Uri uri;

  @override
  final _Response response = _Response();

  _Request(this.uri);

  @override
  Object? get body => null;

  @override
  HttpHeaders get headers => HttpHeaders();

  @override
  String get method => 'GET';

  @override
  Uri get requestedUri => uri;
}

/// Records the answer of the link function.
class _Response implements ExpressHttpResponse {
  Uri? redirectLocation;
  Object? body;

  @override
  final headers = HttpHeaders();

  @override
  int statusCode = 200;

  @override
  Future<void> redirect(Uri location, {int? status}) async {
    redirectLocation = location;
    statusCode = status ?? 302;
  }

  @override
  Future<void> send([Object? body]) async {
    this.body = body;
  }

  @override
  void add(Uint8List bytes) => throw UnimplementedError();

  @override
  Future<void> close() async {}

  @override
  void write(String content) => throw UnimplementedError();

  @override
  void writeln(String content) => throw UnimplementedError();
}

void main() {
  const app = 'linkelio_test';
  late FirebaseContext firebaseContext;
  late LinkelioServerApp serverApp;
  setUpAll(() async {
    firebaseContext = await (await initFirebaseServicesMemory()).init();
    serverApp = LinkelioServerApp(
      app: app,
      context: TkCmsServerAppContext(
        firebaseContext: firebaseContext,
        flavorContext: FlavorContext.dev,
      ),
    );
    var database = LinkelioFirestoreDatabaseService(
      firebaseContext: firebaseContext,
      flavorContext: AppFlavorContext(
        app: app,
        flavorContext: FlavorContext.dev,
      ),
    );
    for (var id in ['simple', 'a b', 'café']) {
      await database
          .fsLinkRef(id)
          .set(database.firestore, FsLink()..url.v = 'https://example.com/$id');
    }
  });
  tearDownAll(() async {
    await firebaseContext.close();
  });

  Future<_Response> get(String encodedPath) async {
    var request = _Request(Uri.parse(encodedPath));
    await serverApp.linkHttp(request);
    return request.response;
  }

  group('link', () {
    for (var entry in {
      '/simple': 'simple',
      // The id is the decoded last segment.
      '/a%20b': 'a b',
      '/caf%C3%A9': 'café',
      '/l/caf%C3%A9/': 'café',
    }.entries) {
      test('${entry.key} redirects', () async {
        var response = await get(entry.key);
        expect(response.statusCode, 302);
        expect(
          response.redirectLocation,
          Uri.parse('https://example.com/${entry.value}'),
        );
      });
    }

    test('not found page', () async {
      var response = await get('/caf%C3%A9-none');
      expect(response.redirectLocation, isNull);
      expect(response.body, contains('Link café-none not found'));
      expect(
        response.headers.value(httpHeaderContentType),
        'text/html; charset=utf-8',
      );
    });

    // Not a document id: not found, without reading another document.
    for (var path in ['/', '/..', '/simple%2Fsub', '/%2Fsimple']) {
      test('$path not found', () async {
        var response = await get(path);
        expect(response.redirectLocation, isNull);
        expect(response.body, contains('not found'));
      });
    }
  });
}
