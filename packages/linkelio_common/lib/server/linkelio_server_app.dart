// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'package:linkelio_common/constants.dart';
import 'package:linkelio_common/firestore/firestore_database.dart';
import 'package:linkelio_common/html/html.dart';
import 'package:linkelio_common/model/all_models.dart';
import 'package:tekartik_app_http/app_http.dart';
import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tkcms_common/tkcms_common.dart';
import 'package:tkcms_common/tkcms_flavor.dart';
import 'package:tkcms_common/tkcms_server.dart';

typedef CreateServerAppFunction = CommonServerApp Function(
    TkCmsServerAppContext context, String app);
CommonServerApp linkelioCreateServerAppLocalClient(
    TkCmsServerAppContext context, String app) {
  return LinkelioServerApp(context: context, app: app);
}

abstract class CommonServerApp {
  void initFunctions();
}

class LinkelioServerApp extends TkCmsServerApp implements CommonServerApp {
  final String app;
  LinkelioServerApp({required super.context, required this.app}) {
    linkelioInitAllBuilders();
  }

  late String link;
  HttpsFunction get linkV1 => functions.https.onRequest(
        linkHttp,
        httpsOptions: HttpsOptions(cors: true, region: regionBelgium),
      );

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
        link = functionLinkV1Prod;

        break;
      case FlavorContext.dev:
      case FlavorContext.devx:
      default:
        link = functionLinkV1Dev;
        break;
    }
    functions[link] = linkV1;
    super.initFunctions();
  }

  @override
  Future<bool> handleCustom(ExpressHttpRequest request) async {
    var uri = request.uri;
    if (uri.pathSegments.isNotEmpty) {
      var command = uri.pathSegments.last;
      switch (command) {
        /*
        case commandAddParticipant:
          await AddParticipantCommandHandler(
            firebaseContext: firebaseContext,
            request: request,
            serverApp: this,
          ).handle();
          return true;*/
      }
    }
    return false;
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
