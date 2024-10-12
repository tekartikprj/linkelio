// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'package:linkelio_common/constants.dart';
import 'package:linkelio_common/firestore/firestore_database.dart';
import 'package:linkelio_common/html/html.dart';
import 'package:linkelio_common/model/all_models.dart';
import 'package:tkcms_common/tkcms_common.dart';
import 'package:tkcms_common/tkcms_flavor.dart';
import 'package:tkcms_common/tkcms_server.dart';

/// Linkelio server app
class LinkelioServerApp extends TkCmsServerAppV2 {
  /// The app
  final String app;

  /// Constructor
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
          flavorContext:
              AppFlavorContext(app: app, flavorContext: flavorContext));
      var id = url.basename(request.uri.path);
      if (id != '/' && id.isNotEmpty) {
        var link = await databaseService.getLink(id);
        var redirectUrl = link.url.v;
        if (redirectUrl?.isNotEmpty ?? false) {
          await res.redirect(Uri.parse(redirectUrl!), status: 301);
          return;
        }
      }

      res.headers.set(httpHeaderContentType, httpContentTypeHtml);
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
