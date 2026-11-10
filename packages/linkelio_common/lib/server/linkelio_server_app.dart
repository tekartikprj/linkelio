// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'package:linkelio_common/constants.dart';
import 'package:linkelio_common/firestore/firestore_database.dart';
import 'package:linkelio_common/html/html.dart';
import 'package:linkelio_common/model/all_models.dart';
import 'package:tkcms_common/tkcms_common.dart';
import 'package:tkcms_common/tkcms_firestore.dart' show tkCmsIsValidDocumentId;
import 'package:tkcms_common/tkcms_flavor.dart';
import 'package:tkcms_common/tkcms_server.dart';

/// Linkelio server app
class LinkelioServerApp extends TkCmsServerAppV2 {
  /// The app
  final String app;

  /// Creates a [LinkelioServerApp] instance with [context] and [app] identifier.
  LinkelioServerApp({required super.context, required this.app})
    : super(apiVersion: apiVersion2) {
    linkelioInitAllBuilders();
  }

  /// Link function
  late String _link;

  /// Link function
  HttpsFunction get linkV1 => functions.https.onRequest(
    linkHttp,
    httpsOptions: HttpsOptions(cors: true, region: regionBelgium),
  );

  /// Link http
  Future<void> linkHttp(ExpressHttpRequest request) async {
    try {
      var res = request.response;

      var databaseService = LinkelioFirestoreDatabaseService(
        firebaseContext: firebaseContext,
        flavorContext: AppFlavorContext(app: app, flavorContext: flavorContext),
      );
      // The decoded last path segment: `Uri.path` is percent encoded, an id
      // holding a space or an accent would never be found.
      var segments = request.uri.pathSegments.where(
        (segment) => segment.isNotEmpty,
      );
      var id = segments.isEmpty ? '' : segments.last;
      // A document id, never a path (a decoded %2F would name a deeper
      // document).
      if (tkCmsIsValidDocumentId(id)) {
        var link = await databaseService.getLink(id);
        var redirectUrl = link.url.v;
        // An inactive link (switched off in the admin app) is not found.
        if (link.isActive && (redirectUrl?.isNotEmpty ?? false)) {
          // 302, not 301: browsers keep a 301 forever, a link whose target
          // changes would keep sending them to the old one.
          await res.redirect(Uri.parse(redirectUrl!), status: 302);
          return;
        }
      }

      // utf-8: dart:io writes a plain text/html body as latin1.
      res.headers.set(httpHeaderContentType, httpContentTypeHtmlStrict);
      await res.send(linkNotFoundContent(id));
    } catch (e, st) {
      // devPrint(st);
      await sendCatchErrorResponse(request, e, st);
    }
  }

  /// Initialize all functions
  @override
  void initFunctions() {
    switch (flavorContext) {
      case FlavorContext.prod:
      case FlavorContext.prodx:
        _link = functionLinkV1Prod;

        break;
      case FlavorContext.dev:
      case FlavorContext.devx:
      default:
        _link = functionLinkV1Dev;
        break;
    }
    functions[_link] = linkV1;
    super.initFunctions();
  }
}

/*
class AddParticipantCommandHandler extends CommandHandler {
  final FirebaseContext firebaseContext;

  AddParticipantCommandHandler(
      {required this.firebaseContext,
      required super.request,
      required super.serverApp});

  // Read clientDateTime and return client and server date time
  Future<void> handle() async {
    var apiRequest = bodyAsMap(request).cv<LinkelioApiAddParticipantRequest>();
    ensureFields(apiRequest, [
      apiRequest.enc,
      apiRequest.app,
      apiRequest.uid,
      apiRequest.sessionId,
      apiRequest.deviceId,
      apiRequest.timestamp,
    ]);
    if (apiRequest.computeEnc() != apiRequest.enc.v) {
      throw ArgumentError('invalid enc');
    }

    var participant = FsParticipant()
      ..copyFrom(apiRequest,
          columns: apiRequest.participantMixinFields.columns);
    var app = apiRequest.app.v!;
    var database =
        FirestoreDatabaseService(firebaseContext: firebaseContext, app: app);

    var participantId = await database.addParticipant(participant);

    await sendResponse(LinkelioApiAddParticipantResponse()..id.v = participantId);
  }
}
*/
